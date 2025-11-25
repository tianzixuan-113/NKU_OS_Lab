#include <riscv.h>  // 包含RISC-V相关定义

.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # 保存from进程的寄存器到其上下文结构中
    # a0寄存器包含from进程的context指针
    STORE ra, 0*REGBYTES(a0)   # 保存返回地址寄存器
    STORE sp, 1*REGBYTES(a0)   # 保存栈指针寄存器  
    STORE s0, 2*REGBYTES(a0)   # 保存s0寄存器
    STORE s1, 3*REGBYTES(a0)   # 保存s1寄存器
    STORE s2, 4*REGBYTES(a0)   # 保存s2寄存器
    STORE s3, 5*REGBYTES(a0)   # 保存s3寄存器
    STORE s4, 6*REGBYTES(a0)   # 保存s4寄存器
    STORE s5, 7*REGBYTES(a0)   # 保存s5寄存器
    STORE s6, 8*REGBYTES(a0)   # 保存s6寄存器
    STORE s7, 9*REGBYTES(a0)   # 保存s7寄存器
    STORE s8, 10*REGBYTES(a0)  # 保存s8寄存器
    STORE s9, 11*REGBYTES(a0)  # 保存s9寄存器
    STORE s10, 12*REGBYTES(a0) # 保存s10寄存器
    STORE s11, 13*REGBYTES(a0) # 保存s11寄存器

    # 从to进程的上下文结构中恢复寄存器
    # a1寄存器包含to进程的context指针
    LOAD ra, 0*REGBYTES(a1)    # 恢复返回地址寄存器
    LOAD sp, 1*REGBYTES(a1)    # 恢复栈指针寄存器
    LOAD s0, 2*REGBYTES(a1)    # 恢复s0寄存器
    LOAD s1, 3*REGBYTES(a1)    # 恢复s1寄存器
    LOAD s2, 4*REGBYTES(a1)    # 恢复s2寄存器
    LOAD s3, 5*REGBYTES(a1)    # 恢复s3寄存器
    LOAD s4, 6*REGBYTES(a1)    # 恢复s4寄存器
    LOAD s5, 7*REGBYTES(a1)    # 恢复s5寄存器
    LOAD s6, 8*REGBYTES(a1)    # 恢复s6寄存器
    LOAD s7, 9*REGBYTES(a1)    # 恢复s7寄存器
    LOAD s8, 10*REGBYTES(a1)   # 恢复s8寄存器
    LOAD s9, 11*REGBYTES(a1)   # 恢复s9寄存器
    LOAD s10, 12*REGBYTES(a1)  # 恢复s10寄存器
    LOAD s11, 13*REGBYTES(a1)  # 恢复s11寄存器

    ret  # 返回到新进程的ra地址（即新进程的执行点）