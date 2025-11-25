#include <list.h>    // 链表操作
#include <sync.h>    // 同步原语（中断控制）
#include <proc.h>    // 进程管理
#include <sched.h>   // 调度器
#include <assert.h>  // 断言检查

// wakeup_proc - 唤醒进程，将其状态设置为可运行
void
wakeup_proc(struct proc_struct *proc) {
    // 断言：进程不能是僵尸状态或已经是可运行状态
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
    // 设置进程状态为可运行
    proc->state = PROC_RUNNABLE;
}

// schedule - 进程调度函数，选择下一个要运行的进程
void
schedule(void) {
    bool intr_flag;           // 中断标志，用于保存中断状态
    list_entry_t *le, *last;  // 链表遍历指针
    struct proc_struct *next = NULL;  // 下一个要运行的进程
    
    // 保存中断状态并禁用中断（临界区开始）
    local_intr_save(intr_flag);
    {
        // 清除当前进程的重新调度标志
        current->need_resched = 0;
        
        // 确定遍历起始位置：如果当前是空闲进程，从链表头开始；否则从当前进程的下一个开始
        last = (current == idleproc) ? &proc_list : &(current->list_link);
        le = last;
        
        // 循环遍历进程链表，寻找可运行进程
        do {
            // 移动到下一个进程
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);  // 获取进程结构
                // 如果找到可运行进程，跳出循环
                if (next->state == PROC_RUNNABLE) {
                    break;
                }
            }
        } while (le != last);  // 遍历直到回到起点
        
        // 如果没有找到可运行进程，使用空闲进程
        if (next == NULL || next->state != PROC_RUNNABLE) {
            next = idleproc;
        }
        
        // 增加选中进程的运行计数
        next->runs ++;
        
        // 如果选中的进程不是当前进程，进行进程切换
        if (next != current) {
            proc_run(next);  // 切换到新进程
        }
    }
    // 恢复中断状态（临界区结束）
    local_intr_restore(intr_flag);
}