.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1           # 将参数从s1寄存器移动到a0寄存器（函数第一个参数）
	jalr s0               # 跳转到s0寄存器中的函数地址执行（内核线程的主函数）

	jal do_exit           # 线程函数返回后，调用do_exit结束线程