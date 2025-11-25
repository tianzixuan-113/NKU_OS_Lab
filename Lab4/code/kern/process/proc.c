#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

/* ------------- process/thread mechanism design&implementation -------------
(简化的Linux进程/线程机制)
介绍：
  ucore实现了一个简单的进程/线程机制。进程包含独立的内存空间、至少一个执行线程、
  内核数据（用于管理）、处理器状态（用于上下文切换）、文件（在lab6中）等。
  ucore需要高效管理所有这些细节。在ucore中，线程只是一种特殊的进程（共享进程内存）。
------------------------------
进程状态       :     含义                -- 原因
    PROC_UNINIT     :  未初始化           -- alloc_proc
    PROC_SLEEPING   :  睡眠中            -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :  可运行（可能正在运行） -- proc_init, wakeup_proc,
    PROC_ZOMBIE     :  几乎死亡           -- do_exit

-----------------------------
进程状态转换:

  alloc_proc                                 运行中
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  +
                                           -----------------------wakeup_proc----------------------------------
-----------------------------
进程关系
父进程:           proc->parent  (proc是子进程)
子进程:           proc->cptr    (proc是父进程)
哥哥进程:         proc->optr    (proc是弟弟进程)
弟弟进程:         proc->yptr    (proc是哥哥进程)
-----------------------------
相关的进程系统调用:
SYS_exit        : 进程退出,                           -->do_exit
SYS_fork        : 创建子进程, 复制内存管理结构        -->do_fork-->wakeup_proc
SYS_wait        : 等待进程                            -->do_wait
SYS_exec        : fork后, 进程执行程序   -->加载程序并刷新内存管理结构
SYS_clone       : 创建子线程                     -->do_fork-->wakeup_proc
SYS_yield       : 进程标记自身需要重新调度, -- proc->need_sched=1, 然后调度器会重新调度这个进程
SYS_sleep       : 进程睡眠                           -->do_sleep
SYS_kill        : 杀死进程                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit
SYS_getpid      : 获取进程的pid
*/

// 进程集合的链表
list_entry_t proc_list;

#define HASH_SHIFT 10
#define HASH_LIST_SIZE (1 << HASH_SHIFT)
#define pid_hashfn(x) (hash32(x, HASH_SHIFT))

// 基于pid的进程集合哈希链表
static list_entry_t hash_list[HASH_LIST_SIZE];

// 空闲进程（idle进程）
struct proc_struct *idleproc = NULL;
// 初始化进程
struct proc_struct *initproc = NULL;
// 当前运行的进程
struct proc_struct *current = NULL;

// 进程数量
static int nr_process = 0;

// 函数声明
void kernel_thread_entry(void);
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - 分配一个proc_struct并初始化所有字段
static struct proc_struct *
alloc_proc(void)
{
    // 分配进程控制块内存
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL)
    {
        // LAB4:EXERCISE1 YOUR CODE
        /*
         * 以下proc_struct中的字段需要被初始化
         *       enum proc_state state;                      // 进程状态
         *       int pid;                                    // 进程ID
         *       int runs;                                   // 进程运行次数
         *       uintptr_t kstack;                           // 进程内核栈
         *       volatile bool need_resched;                 // 布尔值：是否需要被重新调度以释放CPU?
         *       struct proc_struct *parent;                 // 父进程
         *       struct mm_struct *mm;                       // 进程内存管理字段
         *       struct context context;                     // 上下文切换的上下文
         *       struct trapframe *tf;                       // 当前中断的陷阱帧
         *       uintptr_t pgdir;                            // 页目录表(PDT)的基地址
         *       uint32_t flags;                             // 进程标志
         *       char name[PROC_NAME_LEN + 1];               // 进程名称
         */
        proc->state = PROC_UNINIT;        // 设置为未初始化状态
        proc->pid = -1;                   // 初始pid为-1，表示无效
        proc->runs = 0;                   // 运行次数初始为0
        proc->pgdir = boot_pgdir_pa;      // 使用启动页目录
        proc->kstack = 0;                 // 内核栈初始为0
        proc->need_resched = 0;           // 不需要重新调度
        proc->parent = NULL;              // 父进程为空
        proc->mm = NULL;                  // 内存管理结构为空
        proc->tf = NULL;                  // 陷阱帧为空
        proc->flags = 0;                  // 标志位初始为0
        memset(&proc->name, 0, PROC_NAME_LEN);  // 清空进程名
        memset(&proc->context, 0, sizeof(struct context));  // 清空上下文
    }
    return proc;
}

// set_proc_name - 设置进程名称
char *
set_proc_name(struct proc_struct *proc, const char *name)
{
    memset(proc->name, 0, sizeof(proc->name));  // 先清空名称缓冲区
    return memcpy(proc->name, name, PROC_NAME_LEN);  // 复制新名称
}

// get_proc_name - 获取进程名称
char *
get_proc_name(struct proc_struct *proc)
{
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));  // 清空静态缓冲区
    return memcpy(name, proc->name, PROC_NAME_LEN);  // 复制进程名称
}

// get_pid - 为进程分配唯一pid
static int
get_pid(void)
{
    static_assert(MAX_PID > MAX_PROCESS);  // 确保最大PID大于最大进程数
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;  // 静态变量保存状态
    
    if (++last_pid >= MAX_PID)  // 如果last_pid超过最大值
    {
        last_pid = 1;  // 回绕到1
        goto inside;
    }
    if (last_pid >= next_safe)  // 如果last_pid超过安全值
    {
    inside:
        next_safe = MAX_PID;  // 重置安全值为最大
    repeat:
        le = list;
        // 遍历进程链表
        while ((le = list_next(le)) != list)
        {
            proc = le2proc(le, list_link);  // 获取进程结构
            if (proc->pid == last_pid)  // 如果pid冲突
            {
                if (++last_pid >= next_safe)  // 尝试下一个pid
                {
                    if (last_pid >= MAX_PID)  // 如果超过最大值
                    {
                        last_pid = 1;  // 回绕到1
                    }
                    next_safe = MAX_PID;  // 重置安全值
                    goto repeat;  // 重新开始查找
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid)
            {
                next_safe = proc->pid;  // 更新安全值为下一个更大的pid
            }
        }
    }
    return last_pid;  // 返回找到的可用pid
}

// proc_run - 让进程"proc"在CPU上运行
// 注意：在调用switch_to之前，应该加载"proc"的新PDT基地址
void proc_run(struct proc_struct *proc)
{
    if (proc != current)  // 如果要运行的进程不是当前进程
    {
        // LAB4:EXERCISE3 YOUR CODE
        /*
         * 一些有用的宏、函数和定义，你可以在下面的实现中使用它们
         * 宏或函数：
         *   local_intr_save():        禁用中断
         *   local_intr_restore():     启用中断
         *   lsatp():                  修改satp寄存器的值
         *   switch_to():              两个进程之间的上下文切换
         */
        bool intr_flag;
        local_intr_save(intr_flag);  // 保存中断状态并禁用中断
        {
            struct proc_struct *curr_proc = current;  // 保存当前进程
            current = proc;  // 设置当前进程为目标进程
            switch_to(&(curr_proc->context), &(proc->context));  // 执行上下文切换
        }
        local_intr_restore(intr_flag);  // 恢复中断状态
    }
}

// forkret -- 新线程/进程的第一个内核入口点
// 注意：forkret的地址在copy_thread函数中设置
//       在switch_to之后，当前进程将在这里执行
static void
forkret(void)
{
    forkrets(current->tf);  // 从陷阱帧返回到用户空间
}

// hash_proc - 将进程添加到进程哈希链表中
static void
hash_proc(struct proc_struct *proc)
{
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));  // 根据pid哈希值添加到对应链表
}

// find_proc - 根据pid从进程哈希链表中查找进程
struct proc_struct *
find_proc(int pid)
{
    if (0 < pid && pid < MAX_PID)  // 检查pid有效性
    {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;  // 获取对应哈希桶
        while ((le = list_next(le)) != list)  // 遍历哈希链表
        {
            struct proc_struct *proc = le2proc(le, hash_link);  // 获取进程结构
            if (proc->pid == pid)  // 如果pid匹配
            {
                return proc;  // 返回找到的进程
            }
        }
    }
    return NULL;  // 未找到返回NULL
}

// kernel_thread - 使用"fn"函数创建内核线程
// 注意：临时陷阱帧tf的内容将被复制到proc->tf（在do_fork-->copy_thread函数中）
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));  // 清空陷阱帧
    tf.gpr.s0 = (uintptr_t)fn;     // 将函数指针保存在s0寄存器
    tf.gpr.s1 = (uintptr_t)arg;    // 将参数指针保存在s1寄存器
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;  // 设置状态寄存器
    tf.epc = (uintptr_t)kernel_thread_entry;  // 设置入口点为kernel_thread_entry
    return do_fork(clone_flags | CLONE_VM, 0, &tf);  // 调用do_fork创建线程
}

// setup_kstack - 分配KSTACKPAGE大小的页面作为进程内核栈
static int
setup_kstack(struct proc_struct *proc)
{
    struct Page *page = alloc_pages(KSTACKPAGE);  // 分配内核栈页面
    if (page != NULL)
    {
        proc->kstack = (uintptr_t)page2kva(page);  // 设置内核栈地址为页面内核虚拟地址
        return 0;
    }
    return -E_NO_MEM;  // 内存不足错误
}

// put_kstack - 释放进程内核栈的内存空间
static void
put_kstack(struct proc_struct *proc)
{
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);  // 释放内核栈页面
}

// copy_mm - 进程"proc"根据clone_flags复制或共享进程"current"的mm
//         - 如果clone_flags & CLONE_VM，则"共享"；否则"复制"
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc)
{
    assert(current->mm == NULL);  // 断言当前进程没有内存管理结构（内核线程）
    /* 在这个项目中什么都不做 */
    return 0;
}

// copy_thread - 在进程的内核栈顶设置陷阱帧
//             - 设置进程的内核入口点和栈
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf)
{
    // 在内核栈顶分配陷阱帧空间
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
    *(proc->tf) = *tf;  // 复制陷阱帧内容

    // 设置a0为0，让子进程知道它是刚被fork出来的
    proc->tf->gpr.a0 = 0;
    // 设置栈指针，如果esp为0则使用陷阱帧地址
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;

    // 设置上下文返回地址为forkret
    proc->context.ra = (uintptr_t)forkret;
    // 设置上下文栈指针为陷阱帧地址
    proc->context.sp = (uintptr_t)(proc->tf);
}

/* do_fork -     父进程创建新的子进程
 * @clone_flags: 用于指导如何克隆子进程
 * @stack:       父进程的用户栈指针。如果stack==0，表示fork一个内核线程
 * @tf:          陷阱帧信息，将被复制到子进程的proc->tf
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;  // 默认返回错误：无空闲进程
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)  // 检查进程数是否超过最大值
    {
        goto fork_out;
    }
    ret = -E_NO_MEM;  // 设置错误码为内存不足
    // LAB4:EXERCISE2 YOUR CODE
    /*
     * 一些有用的宏、函数和定义，你可以在下面的实现中使用它们
     * 宏或函数：
     *   alloc_proc:   创建proc结构并初始化字段 (lab4:exercise1)
     *   setup_kstack: 分配KSTACKPAGE大小的页面作为进程内核栈
     *   copy_mm:      进程"proc"根据clone_flags复制或共享进程"current"的mm
     *                 如果clone_flags & CLONE_VM，则"共享"；否则"复制"
     *   copy_thread:  在进程的内核栈顶设置陷阱帧并设置内核入口点和栈
     *   hash_proc:    将进程添加到进程哈希链表中
     *   get_pid:      为进程分配唯一pid
     *   wakeup_proc:  设置proc->state = PROC_RUNNABLE
     * 变量:
     *   proc_list:    进程集合的链表
     *   nr_process:   进程集合的数量
     */

    //    1. 调用alloc_proc分配proc_struct
    //    2. 调用setup_kstack为子进程分配内核栈
    //    3. 调用copy_mm根据clone_flag复制或共享内存管理结构
    //    4. 调用copy_thread设置proc_struct中的tf和context
    //    5. 将proc_struct插入hash_list和proc_list
    //    6. 调用wakeup_proc使新的子进程可运行
    //    7. 使用子进程的pid设置返回值
    
    // 1. 调用alloc_proc分配proc_struct
    if ((proc = alloc_proc()) == NULL) {
        goto fork_out;  // 分配失败跳转到出口
    }
    
    // 2. 调用setup_kstack为子进程分配内核栈
    if (setup_kstack(proc) != 0) {
        goto bad_fork_cleanup_proc;  // 分配内核栈失败，清理进程结构
    }
    
    // 3. 调用copy_mm根据clone_flag复制或共享内存管理结构
    if (copy_mm(clone_flags, proc) != 0) {
        goto bad_fork_cleanup_kstack;  // 复制内存管理结构失败，清理内核栈
    }
    
    // 4. 调用copy_thread设置proc_struct中的tf和context
    copy_thread(proc, stack, tf);
    
    // 5. 将proc_struct插入hash_list和proc_list
    proc->pid = get_pid();  // 为进程分配pid
    hash_proc(proc);  // 添加到哈希表
    list_add(&proc_list, &(proc->list_link));  // 添加到进程链表
    nr_process++;  // 增加进程计数
    
    // 6. 调用wakeup_proc使新的子进程可运行
    wakeup_proc(proc);
    
    // 7. 使用子进程的pid设置返回值
    ret = proc->pid;
    
fork_out:
    return ret;  // 返回结果

bad_fork_cleanup_kstack:
    put_kstack(proc);  // 清理内核栈
bad_fork_cleanup_proc:
    kfree(proc);  // 释放进程结构内存
    goto fork_out;  // 跳转到出口
}

// do_exit - 由sys_exit调用
//   1. 调用exit_mmap & put_pgdir & mm_destroy来释放进程的几乎所有内存空间
//   2. 设置进程状态为PROC_ZOMBIE，然后调用wakeup_proc(parent)要求父进程回收自身
//   3. 调用调度器切换到其他进程
int do_exit(int error_code)
{
    panic("process exit!!.\n");  // 暂时用panic处理，实际实现需要完成上述步骤
}

// init_main - 用于创建user_main内核线程的第二个内核线程
static int
init_main(void *arg)
{
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
    cprintf("To U: \"%s\".\n", (const char *)arg);
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
    return 0;
}

// proc_init - 设置第一个内核线程idleproc "idle"，并创建第二个内核线程init_main
void proc_init(void)
{
    int i;

    // 初始化进程链表
    list_init(&proc_list);
    // 初始化哈希链表数组
    for (i = 0; i < HASH_LIST_SIZE; i++)
    {
        list_init(hash_list + i);
    }

    // 分配空闲进程结构
    if ((idleproc = alloc_proc()) == NULL)
    {
        panic("cannot alloc idleproc.\n");
    }

    // 检查进程结构初始化是否正确
    int *context_mem = (int *)kmalloc(sizeof(struct context));
    memset(context_mem, 0, sizeof(struct context));
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));

    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
    memset(proc_name_mem, 0, PROC_NAME_LEN);
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);

    // 验证所有字段都正确初始化
    if (idleproc->pgdir == boot_pgdir_pa && idleproc->tf == NULL && !context_init_flag && 
        idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0 && 
        idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL && 
        idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag)
    {
        cprintf("alloc_proc() correct!\n");  // 分配进程结构正确
    }

    // 设置空闲进程属性
    idleproc->pid = 0;  // 空闲进程pid为0
    idleproc->state = PROC_RUNNABLE;  // 设置为可运行状态
    idleproc->kstack = (uintptr_t)bootstack;  // 使用启动栈作为内核栈
    idleproc->need_resched = 1;  // 需要调度
    set_proc_name(idleproc, "idle");  // 设置进程名为"idle"
    nr_process++;  // 增加进程计数

    current = idleproc;  // 设置当前进程为空闲进程

    // 创建初始化进程
    int pid = kernel_thread(init_main, "Hello world!!", 0);
    if (pid <= 0)
    {
        panic("create init_main failed.\n");  // 创建失败则panic
    }

    initproc = find_proc(pid);  // 查找初始化进程
    set_proc_name(initproc, "init");  // 设置进程名为"init"

    // 验证空闲进程和初始化进程创建成功
    assert(idleproc != NULL && idleproc->pid == 0);
    assert(initproc != NULL && initproc->pid == 1);
}

// cpu_idle - 在kern_init的最后，第一个内核线程idleproc将执行以下工作
void cpu_idle(void)
{
    while (1)  // 无限循环
    {
        if (current->need_resched)  // 如果需要重新调度
        {
            schedule();  // 调用调度器
        }
    }
}