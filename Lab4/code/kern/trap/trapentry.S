#include <riscv.h>  // 包含RISC-V相关寄存器定义

    // 宏定义：保存所有寄存器到栈中（陷阱帧）
    .macro SAVE_ALL
    .align 2  // 按2字节对齐

    // 将当前栈指针保存到sscratch寄存器（用于内核栈切换）
    csrw sscratch, sp

    // 在栈上分配36个寄存器大小的空间（陷阱帧）
    addi sp, sp, -36 * REGBYTES
    
    // 保存通用寄存器到栈中（x0是零寄存器，不需要保存）
    # save gprs
    STORE  x1,1*REGBYTES(sp)   // 保存返回地址寄存器(ra)
    STORE  x3,3*REGBYTES(sp)   // 保存gp寄存器
    STORE  x4,4*REGBYTES(sp)   // 保存tp寄存器
    STORE  x5,5*REGBYTES(sp)   // 保存t0寄存器
    STORE  x6,6*REGBYTES(sp)   // 保存t1寄存器
    STORE  x7,7*REGBYTES(sp)   // 保存t2寄存器
    STORE  x8,8*REGBYTES(sp)   // 保存s0/fp寄存器
    STORE  x9,9*REGBYTES(sp)   // 保存s1寄存器
    STORE  x10,10*REGBYTES(sp) // 保存a0寄存器
    STORE  x11,11*REGBYTES(sp) // 保存a1寄存器
    STORE  x12,12*REGBYTES(sp) // 保存a2寄存器
    STORE  x13,13*REGBYTES(sp) // 保存a3寄存器
    STORE  x14,14*REGBYTES(sp) // 保存a4寄存器
    STORE  x15,15*REGBYTES(sp) // 保存a5寄存器
    STORE  x16,16*REGBYTES(sp) // 保存a6寄存器
    STORE  x17,17*REGBYTES(sp) // 保存a7寄存器
    STORE  x18,18*REGBYTES(sp) // 保存s2寄存器
    STORE  x19,19*REGBYTES(sp) // 保存s3寄存器
    STORE  x20,20*REGBYTES(sp) // 保存s4寄存器
    STORE  x21,21*REGBYTES(sp) // 保存s5寄存器
    STORE  x22,22*REGBYTES(sp) // 保存s6寄存器
    STORE  x23,23*REGBYTES(sp) // 保存s7寄存器
    STORE  x24,24*REGBYTES(sp) // 保存s8寄存器
    STORE  x25,25*REGBYTES(sp) // 保存s9寄存器
    STORE  x26,26*REGBYTES(sp) // 保存s10寄存器
    STORE  x27,27*REGBYTES(sp) // 保存s11寄存器
    STORE  x28,28*REGBYTES(sp) // 保存t3寄存器
    STORE  x29,29*REGBYTES(sp) // 保存t4寄存器
    STORE  x30,30*REGBYTES(sp) // 保存t5寄存器
    STORE  x31,31*REGBYTES(sp) // 保存t6寄存器

    // 获取特殊寄存器值
    # get sr, epc, badvaddr, cause
    csrr s0, sscratch   // 恢复原来的栈指针
    csrr s1, sstatus    // 保存状态寄存器
    csrr s2, sepc       // 保存异常程序计数器
    csrr s3, 0x143      // 保存stval（错误地址寄存器），0x143是stval的CSR地址
    csrr s4, scause     // 保存异常原因寄存器

    // 保存特殊寄存器到栈中
    STORE s0, 2*REGBYTES(sp)   // 保存原始sp（x2寄存器位置）
    STORE s1, 32*REGBYTES(sp)  // 保存sstatus
    STORE s2, 33*REGBYTES(sp)  // 保存sepc
    STORE s3, 34*REGBYTES(sp)  // 保存stval（badvaddr）
    STORE s4, 35*REGBYTES(sp)  // 保存scause
    .endm

    // 宏定义：从栈中恢复所有寄存器
    .macro RESTORE_ALL

    // 从栈中加载状态寄存器和异常程序计数器
    LOAD s1, 32*REGBYTES(sp)  // 加载sstatus
    LOAD s2, 33*REGBYTES(sp)  // 加载sepc

    // 恢复控制状态寄存器
    csrw sstatus, s1  // 恢复状态寄存器
    csrw sepc, s2     // 恢复异常程序计数器

    // 恢复通用寄存器
    // restore x registers
    LOAD  x1,1*REGBYTES(sp)   // 恢复ra寄存器
    LOAD  x3,3*REGBYTES(sp)   // 恢复gp寄存器
    LOAD  x4,4*REGBYTES(sp)   // 恢复tp寄存器
    LOAD  x5,5*REGBYTES(sp)   // 恢复t0寄存器
    LOAD  x6,6*REGBYTES(sp)   // 恢复t1寄存器
    LOAD  x7,7*REGBYTES(sp)   // 恢复t2寄存器
    LOAD  x8,8*REGBYTES(sp)   // 恢复s0/fp寄存器
    LOAD  x9,9*REGBYTES(sp)   // 恢复s1寄存器
    LOAD  x10,10*REGBYTES(sp) // 恢复a0寄存器
    LOAD  x11,11*REGBYTES(sp) // 恢复a1寄存器
    LOAD  x12,12*REGBYTES(sp) // 恢复a2寄存器
    LOAD  x13,13*REGBYTES(sp) // 恢复a3寄存器
    LOAD  x14,14*REGBYTES(sp) // 恢复a4寄存器
    LOAD  x15,15*REGBYTES(sp) // 恢复a5寄存器
    LOAD  x16,16*REGBYTES(sp) // 恢复a6寄存器
    LOAD  x17,17*REGBYTES(sp) // 恢复a7寄存器
    LOAD  x18,18*REGBYTES(sp) // 恢复s2寄存器
    LOAD  x19,19*REGBYTES(sp) // 恢复s3寄存器
    LOAD  x20,20*REGBYTES(sp) // 恢复s4寄存器
    LOAD  x21,21*REGBYTES(sp) // 恢复s5寄存器
    LOAD  x22,22*REGBYTES(sp) // 恢复s6寄存器
    LOAD  x23,23*REGBYTES(sp) // 恢复s7寄存器
    LOAD  x24,24*REGBYTES(sp) // 恢复s8寄存器
    LOAD  x25,25*REGBYTES(sp) // 恢复s9寄存器
    LOAD  x26,26*REGBYTES(sp) // 恢复s10寄存器
    LOAD  x27,27*REGBYTES(sp) // 恢复s11寄存器
    LOAD  x28,28*REGBYTES(sp) // 恢复t3寄存器
    LOAD  x29,29*REGBYTES(sp) // 恢复t4寄存器
    LOAD  x30,30*REGBYTES(sp) // 恢复t5寄存器
    LOAD  x31,31*REGBYTES(sp) // 恢复t6寄存器
    
    # restore sp last  // 最后恢复栈指针
    LOAD  x2,2*REGBYTES(sp)   // 恢复sp寄存器
    .endm

    // 全局陷阱处理入口点
    .globl __alltraps
__alltraps:
    // 保存所有寄存器到栈中（构建陷阱帧）
    SAVE_ALL

    // 设置C函数trap的参数（陷阱帧指针）
    move  a0, sp
    // 调用C语言陷阱处理函数
    jal trap
    // trap函数返回后，栈指针应该保持不变

    // 全局陷阱返回点
    .globl __trapret
__trapret:
    // 从栈中恢复所有寄存器
    RESTORE_ALL
    // 从监管者模式返回到发生异常/中断的代码位置
    # go back from supervisor call
    sret
 
    // 全局fork返回点（用于新创建进程的第一次执行）
    .globl forkrets
forkrets:
    // 设置栈指针为新进程的陷阱帧地址（参数a0）
    # set stack to this new process's trapframe
    move sp, a0
    // 跳转到陷阱返回代码
    j __trapret