#include <defs.h>      // 基本类型定义
#include <stdio.h>     // 标准输入输出
#include <string.h>    // 字符串操作
#include <console.h>   // 控制台驱动
#include <kdebug.h>    // 内核调试功能
#include <picirq.h>    // 可编程中断控制器
#include <trap.h>      // 陷阱/异常处理
#include <clock.h>     // 时钟中断
#include <intr.h>      // 中断管理
#include <pmm.h>       // 物理内存管理
#include <vmm.h>       // 虚拟内存管理
#include <proc.h>      // 进程管理
#include <kmonitor.h>  // 内核监视器
#include <dtb.h>       // 设备树

// 函数声明：内核初始化函数，不返回
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);  // 用于评分的回溯函数

// 内核初始化主函数 - 操作系统启动入口
int kern_init(void)
{
    // 声明外部变量：edata指向BSS段开始，end指向内核结束地址
    extern char edata[], end[];
    
    // 清零BSS段（未初始化数据段）
    memset(edata, 0, end - edata);
    
    // 初始化设备树（Device Tree Blob）
    dtb_init();
    
    // 初始化控制台，使内核可以输出信息
    cons_init();

    // 显示操作系统启动信息
    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);

    // 打印内核信息（符号表、代码位置等）
    print_kerninfo();

    // 用于评分的内存回溯测试（当前被注释）
    // grade_backtrace();

    // 初始化物理内存管理
    pmm_init();

    // 初始化可编程中断控制器（PIC）
    pic_init();
    // 初始化中断描述符表（IDT）
    idt_init();

    // 初始化虚拟内存管理
    vmm_init();
    // 初始化进程表，创建初始进程
    proc_init();

    // 初始化时钟中断，启动定时器
    clock_init();
    // 启用中断响应
    intr_enable();

    // 运行空闲进程，进入进程调度循环
    // 此函数不会返回，操作系统开始正常运行
    cpu_idle();
}

// 实验1的辅助函数：打印当前状态
// 当前为空实现，仅用于演示框架
static void
lab1_print_cur_status(void)
{
    static int round = 0;  // 静态变量记录调用次数
    round++;  // 每次调用递增
}