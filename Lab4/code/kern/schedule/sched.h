#ifndef __KERN_SCHEDULE_SCHED_H__
#define __KERN_SCHEDULE_SCHED_H__

#include <proc.h>  // 包含进程结构定义

// 函数声明：进程调度函数
void schedule(void);
// 函数声明：唤醒进程函数
void wakeup_proc(struct proc_struct *proc);

#endif /* !__KERN_SCHEDULE_SCHED_H__ */