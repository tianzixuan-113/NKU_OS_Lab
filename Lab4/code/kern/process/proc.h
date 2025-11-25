#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>

// 进程在其生命周期中的状态
enum proc_state
{
    PROC_UNINIT = 0, // 未初始化
    PROC_SLEEPING,   // 睡眠中
    PROC_RUNNABLE,   // 可运行（可能正在运行）
    PROC_ZOMBIE,     // 几乎死亡，等待父进程回收其资源
};

// 进程上下文结构，用于保存寄存器状态
struct context
{
    uintptr_t ra;   // 返回地址寄存器
    uintptr_t sp;   // 栈指针寄存器
    uintptr_t s0;   // 保存寄存器s0-s11
    uintptr_t s1;
    uintptr_t s2;
    uintptr_t s3;
    uintptr_t s4;
    uintptr_t s5;
    uintptr_t s6;
    uintptr_t s7;
    uintptr_t s8;
    uintptr_t s9;
    uintptr_t s10;
    uintptr_t s11;
};

#define PROC_NAME_LEN 15    // 进程名称最大长度
#define MAX_PROCESS 4096    // 最大进程数
#define MAX_PID (MAX_PROCESS * 2)  // 最大PID值

extern list_entry_t proc_list;  // 声明外部变量：进程链表

// 进程控制块结构
struct proc_struct
{
    enum proc_state state;        // 进程状态
    int pid;                      // 进程ID
    int runs;                     // 进程运行次数
    uintptr_t kstack;             // 进程内核栈
    volatile bool need_resched;   // 布尔值：是否需要被重新调度以释放CPU?
    struct proc_struct *parent;   // 父进程
    struct mm_struct *mm;         // 进程内存管理字段
    struct context context;       // 上下文切换的上下文
    struct trapframe *tf;         // 当前中断的陷阱帧
    uintptr_t pgdir;              // 页目录表(PDT)的基地址
    uint32_t flags;               // 进程标志
    char name[PROC_NAME_LEN + 1]; // 进程名称
    list_entry_t list_link;       // 进程链表链接
    list_entry_t hash_link;       // 进程哈希链表链接
};

// 从链表节点获取进程结构的宏
#define le2proc(le, member) \
    to_struct((le), struct proc_struct, member)

// 声明外部全局变量
extern struct proc_struct *idleproc, *initproc, *current;

// 函数声明
void proc_init(void);  // 进程初始化
void proc_run(struct proc_struct *proc);  // 运行指定进程
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);  // 创建内核线程

char *set_proc_name(struct proc_struct *proc, const char *name);  // 设置进程名
char *get_proc_name(struct proc_struct *proc);  // 获取进程名
void cpu_idle(void) __attribute__((noreturn));  // CPU空闲循环，不返回

struct proc_struct *find_proc(int pid);  // 根据PID查找进程
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);  // 执行fork操作
int do_exit(int error_code);  // 执行exit操作

#endif /* !__KERN_PROCESS_PROC_H__ */