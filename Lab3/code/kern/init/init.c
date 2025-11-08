#include <clock.h>
#include <console.h>
#include <defs.h>
#include <intr.h>
#include <kdebug.h>
#include <kmonitor.h>
#include <pmm.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <dtb.h>

// 内核初始化函数声明，noreturn属性表示该函数不会返回
int kern_init(void) __attribute__((noreturn));

// 调试用的回溯函数声明
void grade_backtrace(void);

/**
 * kern_init - 内核主初始化函数
 * 从entry.S跳转过来，完成内核的主要初始化工作
 * 该函数不会返回，最终会进入空闲循环
 */
int kern_init(void) {
    // 获取BSS段的起始和结束地址（edata到end之间是未初始化的全局变量区域）
    extern char edata[], end[];
    
    // 清零BSS段（将未初始化的全局变量初始化为0）
    memset(edata, 0, end - edata);
    
    // 初始化设备树（Device Tree Blob），获取硬件信息
    dtb_init();
    
    // 初始化控制台，为后续输出做准备
    cons_init();
    
    // 内核启动消息
    const char *message = "(THU.CST) os is loading ...\0";
    cputs(message);  // 输出启动消息

    // 打印内核信息（符号表、代码段位置等）
    print_kerninfo();

    // 调试用的函数调用回溯（当前被注释掉）
    // grade_backtrace();
    
    // 第一次初始化中断描述符表
    idt_init();  // 初始化中断描述符表

    // 初始化物理内存管理
    pmm_init();  // 初始化物理内存管理

    // 第二次初始化中断描述符表（可能是为了确保在内存管理初始化后重新设置）
    idt_init();  // 初始化中断描述符表

    // 初始化时钟中断
    clock_init();   // 初始化时钟中断
    
    // 开启中断使能，允许CPU响应中断
    intr_enable();  // 开启中断响应

    // 以下两条汇编指令存在问题：
    // mret - 从机器模式返回，但当前可能不在机器模式，会导致异常
    // ebreak - 断点指令，会触发调试异常
    //asm("mret");
    //asm("ebreak");

    /* 进入空闲循环，内核主要工作由中断驱动 */
    while (1)
        ;  // 无限循环，等待中断发生
}

/**
 * grade_backtrace2 - 二级回溯函数
 * @arg0-arg3: 测试参数
 * 用于演示函数调用栈的回溯
 */
void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
    // 调用监控器的回溯功能，打印调用栈信息
    mon_backtrace(0, NULL, NULL);
}

/**
 * grade_backtrace1 - 一级回溯函数  
 * @arg0, arg1: 测试参数
 * 调用二级回溯函数，形成调用链
 */
void __attribute__((noinline)) grade_backtrace1(int arg0, int arg1) {
    // 传递参数并调用二级回溯，其中&arg0获取参数的地址用于调试
    grade_backtrace2(arg0, (uintptr_t)&arg0, arg1, (uintptr_t)&arg1);
}

/**
 * grade_backtrace0 - 初级回溯函数
 * @arg0, arg1, arg2: 测试参数
 * 调用一级回溯函数
 */
void __attribute__((noinline)) grade_backtrace0(int arg0, int arg1, int arg2) {
    grade_backtrace1(arg0, arg2);
}

/**
 * grade_backtrace - 回溯测试入口函数
 * 初始化一个调用链：grade_backtrace → grade_backtrace0 → grade_backtrace1 → grade_backtrace2
 * 用于测试调试和栈回溯功能
 */
void grade_backtrace(void) { 
    // 以kern_init函数的地址作为参数开始回溯
    grade_backtrace0(0, (uintptr_t)kern_init, 0xffff0000); 
}