#include <assert.h>
#include <clock.h>
#include <console.h>
#include <defs.h>
#include <kdebug.h>
#include <memlayout.h>
#include <mmu.h>
#include <riscv.h>
#include <stdio.h>
#include <trap.h>
#include <sbi.h> 

#define TICK_NUM 100  // 定义时钟中断计数周期，每100次中断输出一次信息

// 全局变量声明
static int num = 0;    // 记录打印次数的计数器

/**
 * print_ticks - 打印时钟中断计数信息
 * 每TICK_NUM次中断调用一次，用于调试和测试
 */
static void print_ticks() {
    cprintf("%d ticks\n", TICK_NUM);  // 输出中断计数
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");  // 调试模式下触发panic以结束测试
#endif
}

/**
 * idt_init - 初始化中断描述符表（实际为RISC-V的陷阱向量表）
 * 设置sscratch和stvec寄存器，建立中断处理机制
 */
void idt_init(void) {
    extern void __alltraps(void);  // 声明陷阱处理总入口点
    
    /* 设置sscratch寄存器为0，表示当前在内核态执行
     * 约定：
     * - 中断前处于S态（内核态）：sscratch = 0
     * - 中断前处于U态（用户态）：sscratch = 内核栈地址
     * 通过sscratch值可判断中断来源是内核态还是用户态
     */
    write_csr(sscratch, 0);
    
    /* 设置陷阱向量地址到stvec寄存器
     * __alltraps是所有中断/异常的统一入口点
     * 保证地址四字节对齐以满足RISC-V架构要求
     */
    write_csr(stvec, &__alltraps);
}

/**
 * trap_in_kernel - 判断陷阱是否发生在内核态
 * @tf: 陷阱帧指针
 * 返回值: true-内核态, false-用户态
 * 原理：检查sstatus寄存器的SPP位，SPP=1表示陷入前处于内核态
 */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
}

/**
 * print_trapframe - 打印完整的陷阱帧信息
 * @tf: 陷阱帧指针
 * 用于调试，显示所有寄存器和关键CSR状态
 */
void print_trapframe(struct trapframe *tf) {
    cprintf("trapframe at %p\n", tf);  // 输出陷阱帧地址
    print_regs(&tf->gpr);              // 打印通用寄存器
    cprintf("  status   0x%08x\n", tf->status);   // sstatus寄存器
    cprintf("  epc      0x%08x\n", tf->epc);      // sepc寄存器（异常程序计数器）
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr); // stval寄存器（错误地址）
    cprintf("  cause    0x%08x\n", tf->cause);    // scause寄存器（陷阱原因）
}

/**
 * print_regs - 打印所有通用寄存器的值
 * @gpr: 通用寄存器结构体指针
 * 按顺序输出32个通用寄存器的十六进制值
 */
void print_regs(struct pushregs *gpr) {
    // 依次输出所有通用寄存器，便于调试和分析程序状态
    cprintf("  zero     0x%08x\n", gpr->zero);  // 硬连线零寄存器
    cprintf("  ra       0x%08x\n", gpr->ra);    // 返回地址寄存器
    cprintf("  sp       0x%08x\n", gpr->sp);    // 栈指针寄存器
    cprintf("  gp       0x%08x\n", gpr->gp);    // 全局指针寄存器
    cprintf("  tp       0x%08x\n", gpr->tp);    // 线程指针寄存器
    cprintf("  t0       0x%08x\n", gpr->t0);    // 临时寄存器
    cprintf("  t1       0x%08x\n", gpr->t1);    // 临时寄存器
    cprintf("  t2       0x%08x\n", gpr->t2);    // 临时寄存器
    cprintf("  s0       0x%08x\n", gpr->s0);    // 保存寄存器/帧指针
    cprintf("  s1       0x%08x\n", gpr->s1);    // 保存寄存器
    cprintf("  a0       0x%08x\n", gpr->a0);    // 函数参数/返回值
    cprintf("  a1       0x%08x\n", gpr->a1);    // 函数参数/返回值
    cprintf("  a2       0x%08x\n", gpr->a2);    // 函数参数
    cprintf("  a3       0x%08x\n", gpr->a3);    // 函数参数
    cprintf("  a4       0x%08x\n", gpr->a4);    // 函数参数
    cprintf("  a5       0x%08x\n", gpr->a5);    // 函数参数
    cprintf("  a6       0x%08x\n", gpr->a6);    // 函数参数
    cprintf("  a7       0x%08x\n", gpr->a7);    // 函数参数
    cprintf("  s2       0x%08x\n", gpr->s2);    // 保存寄存器
    cprintf("  s3       0x%08x\n", gpr->s3);    // 保存寄存器
    cprintf("  s4       0x%08x\n", gpr->s4);    // 保存寄存器
    cprintf("  s5       0x%08x\n", gpr->s5);    // 保存寄存器
    cprintf("  s6       0x%08x\n", gpr->s6);    // 保存寄存器
    cprintf("  s7       0x%08x\n", gpr->s7);    // 保存寄存器
    cprintf("  s8       0x%08x\n", gpr->s8);    // 保存寄存器
    cprintf("  s9       0x%08x\n", gpr->s9);    // 保存寄存器
    cprintf("  s10      0x%08x\n", gpr->s10);   // 保存寄存器
    cprintf("  s11      0x%08x\n", gpr->s11);   // 保存寄存器
    cprintf("  t3       0x%08x\n", gpr->t3);    // 临时寄存器
    cprintf("  t4       0x%08x\n", gpr->t4);    // 临时寄存器
    cprintf("  t5       0x%08x\n", gpr->t5);    // 临时寄存器
    cprintf("  t6       0x%08x\n", gpr->t6);    // 临时寄存器
}

/**
 * interrupt_handler - 中断处理函数
 * @tf: 陷阱帧指针
 * 处理各种类型的中断，包括软件中断、定时器中断、外部中断等
 */
void interrupt_handler(struct trapframe *tf) {
    // 清除cause寄存器的高位，获取纯中断原因码
    intptr_t cause = (tf->cause << 1) >> 1;
    
    switch (cause) {
        // 软件中断处理（各级特权模式）
        case IRQ_U_SOFT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_SOFT:
            cprintf("Supervisor software interrupt\n");
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
            break;
            
        // 定时器中断处理
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
            break;
        case IRQ_S_TIMER:
            /* LAB3 EXERCISE1 定时器中断处理 */
            /* 
             * (1) 设置下次时钟中断 - clock_set_next_event()
             * (2) 计数器（ticks）加一
             * (3) 当计数器加到100的倍数时，输出`100ticks`，同时打印次数（num）加一
             * (4) 当打印次数为10时，调用关机函数关机
             */
            clock_set_next_event();  // 设置下次时钟中断，维持定时器周期
            ticks++;  // 全局时钟计数器加1
            
            if (ticks % TICK_NUM == 0) {  // 每100次时钟中断执行一次
                print_ticks();  // 输出"100 ticks"信息
                num++;  // 打印次数计数器加1
                if (num == 10) {  // 如果已经打印了10次（即1000次中断）
                    sbi_shutdown();  // 调用SBI关机函数，结束程序运行
                }
            }
            break;
        case IRQ_H_TIMER:
            cprintf("Hypervisor timer interrupt\n");
            break;
        case IRQ_M_TIMER:
            cprintf("Machine timer interrupt\n");
            break;
            
        // 外部中断处理
        case IRQ_U_EXT:
            cprintf("User external interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
            break;
        case IRQ_H_EXT:
            cprintf("Hypervisor external interrupt\n");
            break;
        case IRQ_M_EXT:
            cprintf("Machine external interrupt\n");
            break;
            
        default:
            // 未知中断类型，打印陷阱帧信息用于调试
            print_trapframe(tf);
            break;
    }
}

/**
 * exception_handler - 异常处理函数
 * @tf: 陷阱帧指针
 * 处理各种类型的同步异常，如非法指令、断点、缺页等
 */
void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
        // 取指相关异常
        case CAUSE_MISALIGNED_FETCH:
            // 取指地址不对齐异常
            break;
        case CAUSE_FAULT_FETCH:
            // 取指缺页异常
            break;
            
        case CAUSE_ILLEGAL_INSTRUCTION:
            /* LAB3 CHALLENGE3 非法指令异常处理 */
            /*
             * (1) 输出指令异常类型（Illegal instruction）
             * (2) 输出异常指令地址
             * (3) 更新 tf->epc寄存器，跳过当前非法指令
             */
            cprintf("Exception type: Illegal instruction\n");
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
            // RISC-V指令通常是4字节或2字节，这里假设是4字节指令
            tf->epc += 4;  // 跳过当前非法指令，继续执行下一条指令
            break;
            
        case CAUSE_BREAKPOINT:
            /* LAB3 CHALLENGE3 断点异常处理 */
            /*
             * (1) 输出指令异常类型（breakpoint）
             * (2) 输出异常指令地址
             * (3) 更新 tf->epc寄存器，跳过断点指令
             */
            cprintf("Exception type: breakpoint\n");
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
            // ebreak指令通常是2字节（c.ebreak）或4字节（ebreak）
            tf->epc += 2;  // 跳过断点指令，继续执行下一条指令
            break;
            
        // 访存相关异常
        case CAUSE_MISALIGNED_LOAD:
            // 加载地址不对齐异常
            break;
        case CAUSE_FAULT_LOAD:
            // 加载缺页异常
            break;
        case CAUSE_MISALIGNED_STORE:
            // 存储地址不对齐异常
            break;
        case CAUSE_FAULT_STORE:
            // 存储缺页异常
            break;
            
        // 环境调用（系统调用）异常
        case CAUSE_USER_ECALL:
            // 用户模式环境调用
            break;
        case CAUSE_SUPERVISOR_ECALL:
            // 监管者模式环境调用
            break;
        case CAUSE_HYPERVISOR_ECALL:
            // 虚拟监管者模式环境调用
            break;
        case CAUSE_MACHINE_ECALL:
            // 机器模式环境调用
            break;
            
        default:
            // 未知异常类型，打印陷阱帧信息用于调试
            print_trapframe(tf);
            break;
    }
}

/**
 * trap_dispatch - 陷阱分发函数
 * @tf: 陷阱帧指针
 * 根据陷阱原因判断是中断还是异常，并分发给相应的处理函数
 */
static inline void trap_dispatch(struct trapframe *tf) {
    // 根据RISC-V规范，cause寄存器最高位为1表示中断，为0表示异常
    if ((intptr_t)tf->cause < 0) {
        // 中断处理
        interrupt_handler(tf);
    } else {
        // 异常处理
        exception_handler(tf);
    }
}

/**
 * trap - 陷阱处理主函数
 * @tf: 陷阱帧指针
 * 
 * 处理或分发异常/中断。当trap()返回时，
 * kern/trap/trapentry.S中的代码会恢复保存在trapframe中的旧CPU状态，
 * 然后使用sret指令从异常返回。
 */
void trap(struct trapframe *tf) {
    // 基于陷阱类型进行分发处理
    trap_dispatch(tf);
}