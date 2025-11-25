
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00009297          	auipc	t0,0x9
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0209000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00009297          	auipc	t0,0x9
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0209008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02082b7          	lui	t0,0xc0208
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c0208137          	lui	sp,0xc0208

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
{
    // 声明外部变量：edata指向BSS段开始，end指向内核结束地址
    extern char edata[], end[];
    
    // 清零BSS段（未初始化数据段）
    memset(edata, 0, end - edata);
ffffffffc020004a:	00009517          	auipc	a0,0x9
ffffffffc020004e:	fe650513          	addi	a0,a0,-26 # ffffffffc0209030 <buf>
ffffffffc0200052:	0000d617          	auipc	a2,0xd
ffffffffc0200056:	49e60613          	addi	a2,a2,1182 # ffffffffc020d4f0 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc0207ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	4d9030ef          	jal	ffffffffc0203d3a <memset>
    
    // 初始化设备树（Device Tree Blob）
    dtb_init();
ffffffffc0200066:	4c2000ef          	jal	ffffffffc0200528 <dtb_init>
    
    // 初始化控制台，使内核可以输出信息
    cons_init();
ffffffffc020006a:	44c000ef          	jal	ffffffffc02004b6 <cons_init>

    // 显示操作系统启动信息
    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00004597          	auipc	a1,0x4
ffffffffc0200072:	d1a58593          	addi	a1,a1,-742 # ffffffffc0203d88 <etext>
ffffffffc0200076:	00004517          	auipc	a0,0x4
ffffffffc020007a:	d3250513          	addi	a0,a0,-718 # ffffffffc0203da8 <etext+0x20>
ffffffffc020007e:	116000ef          	jal	ffffffffc0200194 <cprintf>

    // 打印内核信息（符号表、代码位置等）
    print_kerninfo();
ffffffffc0200082:	158000ef          	jal	ffffffffc02001da <print_kerninfo>

    // 用于评分的内存回溯测试（当前被注释）
    // grade_backtrace();

    // 初始化物理内存管理
    pmm_init();
ffffffffc0200086:	008020ef          	jal	ffffffffc020208e <pmm_init>

    // 初始化可编程中断控制器（PIC）
    pic_init();
ffffffffc020008a:	7f0000ef          	jal	ffffffffc020087a <pic_init>
    // 初始化中断描述符表（IDT）
    idt_init();
ffffffffc020008e:	7ee000ef          	jal	ffffffffc020087c <idt_init>

    // 初始化虚拟内存管理
    vmm_init();
ffffffffc0200092:	579020ef          	jal	ffffffffc0202e0a <vmm_init>
    // 初始化进程表，创建初始进程
    proc_init();
ffffffffc0200096:	46c030ef          	jal	ffffffffc0203502 <proc_init>

    // 初始化时钟中断，启动定时器
    clock_init();
ffffffffc020009a:	3ca000ef          	jal	ffffffffc0200464 <clock_init>
    // 启用中断响应
    intr_enable();
ffffffffc020009e:	7d0000ef          	jal	ffffffffc020086e <intr_enable>

    // 运行空闲进程，进入进程调度循环
    // 此函数不会返回，操作系统开始正常运行
    cpu_idle();
ffffffffc02000a2:	6b8030ef          	jal	ffffffffc020375a <cpu_idle>

ffffffffc02000a6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02000a6:	7179                	addi	sp,sp,-48
ffffffffc02000a8:	f406                	sd	ra,40(sp)
ffffffffc02000aa:	f022                	sd	s0,32(sp)
ffffffffc02000ac:	ec26                	sd	s1,24(sp)
ffffffffc02000ae:	e84a                	sd	s2,16(sp)
ffffffffc02000b0:	e44e                	sd	s3,8(sp)
    if (prompt != NULL) {
ffffffffc02000b2:	c901                	beqz	a0,ffffffffc02000c2 <readline+0x1c>
        cprintf("%s", prompt);
ffffffffc02000b4:	85aa                	mv	a1,a0
ffffffffc02000b6:	00004517          	auipc	a0,0x4
ffffffffc02000ba:	cfa50513          	addi	a0,a0,-774 # ffffffffc0203db0 <etext+0x28>
ffffffffc02000be:	0d6000ef          	jal	ffffffffc0200194 <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc02000c2:	4481                	li	s1,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c4:	497d                	li	s2,31
            buf[i ++] = c;
ffffffffc02000c6:	00009997          	auipc	s3,0x9
ffffffffc02000ca:	f6a98993          	addi	s3,s3,-150 # ffffffffc0209030 <buf>
        c = getchar();
ffffffffc02000ce:	0fc000ef          	jal	ffffffffc02001ca <getchar>
ffffffffc02000d2:	842a                	mv	s0,a0
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000d4:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d8:	3ff4a713          	slti	a4,s1,1023
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000dc:	ff650693          	addi	a3,a0,-10
ffffffffc02000e0:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc02000e4:	02054963          	bltz	a0,ffffffffc0200116 <readline+0x70>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000e8:	02a95f63          	bge	s2,a0,ffffffffc0200126 <readline+0x80>
ffffffffc02000ec:	cf0d                	beqz	a4,ffffffffc0200126 <readline+0x80>
            cputchar(c);
ffffffffc02000ee:	0da000ef          	jal	ffffffffc02001c8 <cputchar>
            buf[i ++] = c;
ffffffffc02000f2:	009987b3          	add	a5,s3,s1
ffffffffc02000f6:	00878023          	sb	s0,0(a5)
ffffffffc02000fa:	2485                	addiw	s1,s1,1
        c = getchar();
ffffffffc02000fc:	0ce000ef          	jal	ffffffffc02001ca <getchar>
ffffffffc0200100:	842a                	mv	s0,a0
        else if (c == '\b' && i > 0) {
ffffffffc0200102:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200106:	3ff4a713          	slti	a4,s1,1023
        else if (c == '\n' || c == '\r') {
ffffffffc020010a:	ff650693          	addi	a3,a0,-10
ffffffffc020010e:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc0200112:	fc055be3          	bgez	a0,ffffffffc02000e8 <readline+0x42>
            cputchar(c);
            buf[i] = '\0';
            return buf;
        }
    }
}
ffffffffc0200116:	70a2                	ld	ra,40(sp)
ffffffffc0200118:	7402                	ld	s0,32(sp)
ffffffffc020011a:	64e2                	ld	s1,24(sp)
ffffffffc020011c:	6942                	ld	s2,16(sp)
ffffffffc020011e:	69a2                	ld	s3,8(sp)
            return NULL;
ffffffffc0200120:	4501                	li	a0,0
}
ffffffffc0200122:	6145                	addi	sp,sp,48
ffffffffc0200124:	8082                	ret
        else if (c == '\b' && i > 0) {
ffffffffc0200126:	eb81                	bnez	a5,ffffffffc0200136 <readline+0x90>
            cputchar(c);
ffffffffc0200128:	4521                	li	a0,8
        else if (c == '\b' && i > 0) {
ffffffffc020012a:	00905663          	blez	s1,ffffffffc0200136 <readline+0x90>
            cputchar(c);
ffffffffc020012e:	09a000ef          	jal	ffffffffc02001c8 <cputchar>
            i --;
ffffffffc0200132:	34fd                	addiw	s1,s1,-1
ffffffffc0200134:	bf69                	j	ffffffffc02000ce <readline+0x28>
        else if (c == '\n' || c == '\r') {
ffffffffc0200136:	c291                	beqz	a3,ffffffffc020013a <readline+0x94>
ffffffffc0200138:	fa59                	bnez	a2,ffffffffc02000ce <readline+0x28>
            cputchar(c);
ffffffffc020013a:	8522                	mv	a0,s0
ffffffffc020013c:	08c000ef          	jal	ffffffffc02001c8 <cputchar>
            buf[i] = '\0';
ffffffffc0200140:	00009517          	auipc	a0,0x9
ffffffffc0200144:	ef050513          	addi	a0,a0,-272 # ffffffffc0209030 <buf>
ffffffffc0200148:	94aa                	add	s1,s1,a0
ffffffffc020014a:	00048023          	sb	zero,0(s1)
}
ffffffffc020014e:	70a2                	ld	ra,40(sp)
ffffffffc0200150:	7402                	ld	s0,32(sp)
ffffffffc0200152:	64e2                	ld	s1,24(sp)
ffffffffc0200154:	6942                	ld	s2,16(sp)
ffffffffc0200156:	69a2                	ld	s3,8(sp)
ffffffffc0200158:	6145                	addi	sp,sp,48
ffffffffc020015a:	8082                	ret

ffffffffc020015c <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc020015c:	1101                	addi	sp,sp,-32
ffffffffc020015e:	ec06                	sd	ra,24(sp)
ffffffffc0200160:	e42e                	sd	a1,8(sp)
    cons_putc(c);
ffffffffc0200162:	356000ef          	jal	ffffffffc02004b8 <cons_putc>
    (*cnt)++;
ffffffffc0200166:	65a2                	ld	a1,8(sp)
}
ffffffffc0200168:	60e2                	ld	ra,24(sp)
    (*cnt)++;
ffffffffc020016a:	419c                	lw	a5,0(a1)
ffffffffc020016c:	2785                	addiw	a5,a5,1
ffffffffc020016e:	c19c                	sw	a5,0(a1)
}
ffffffffc0200170:	6105                	addi	sp,sp,32
ffffffffc0200172:	8082                	ret

ffffffffc0200174 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc0200174:	1101                	addi	sp,sp,-32
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fe250513          	addi	a0,a0,-30 # ffffffffc020015c <cputch>
ffffffffc0200182:	006c                	addi	a1,sp,12
{
ffffffffc0200184:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200186:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc0200188:	798030ef          	jal	ffffffffc0203920 <vprintfmt>
    return cnt;
}
ffffffffc020018c:	60e2                	ld	ra,24(sp)
ffffffffc020018e:	4532                	lw	a0,12(sp)
ffffffffc0200190:	6105                	addi	sp,sp,32
ffffffffc0200192:	8082                	ret

ffffffffc0200194 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc0200194:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200196:	02810313          	addi	t1,sp,40
{
ffffffffc020019a:	f42e                	sd	a1,40(sp)
ffffffffc020019c:	f832                	sd	a2,48(sp)
ffffffffc020019e:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001a0:	862a                	mv	a2,a0
ffffffffc02001a2:	004c                	addi	a1,sp,4
ffffffffc02001a4:	00000517          	auipc	a0,0x0
ffffffffc02001a8:	fb850513          	addi	a0,a0,-72 # ffffffffc020015c <cputch>
ffffffffc02001ac:	869a                	mv	a3,t1
{
ffffffffc02001ae:	ec06                	sd	ra,24(sp)
ffffffffc02001b0:	e0ba                	sd	a4,64(sp)
ffffffffc02001b2:	e4be                	sd	a5,72(sp)
ffffffffc02001b4:	e8c2                	sd	a6,80(sp)
ffffffffc02001b6:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc02001b8:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc02001ba:	e41a                	sd	t1,8(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001bc:	764030ef          	jal	ffffffffc0203920 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001c0:	60e2                	ld	ra,24(sp)
ffffffffc02001c2:	4512                	lw	a0,4(sp)
ffffffffc02001c4:	6125                	addi	sp,sp,96
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc02001c8:	acc5                	j	ffffffffc02004b8 <cons_putc>

ffffffffc02001ca <getchar>:
}

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc02001ca:	1141                	addi	sp,sp,-16
ffffffffc02001cc:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02001ce:	31e000ef          	jal	ffffffffc02004ec <cons_getc>
ffffffffc02001d2:	dd75                	beqz	a0,ffffffffc02001ce <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02001d4:	60a2                	ld	ra,8(sp)
ffffffffc02001d6:	0141                	addi	sp,sp,16
ffffffffc02001d8:	8082                	ret

ffffffffc02001da <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc02001da:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001dc:	00004517          	auipc	a0,0x4
ffffffffc02001e0:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0203db8 <etext+0x30>
{
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001e6:	fafff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc02001ea:	00000597          	auipc	a1,0x0
ffffffffc02001ee:	e6058593          	addi	a1,a1,-416 # ffffffffc020004a <kern_init>
ffffffffc02001f2:	00004517          	auipc	a0,0x4
ffffffffc02001f6:	be650513          	addi	a0,a0,-1050 # ffffffffc0203dd8 <etext+0x50>
ffffffffc02001fa:	f9bff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc02001fe:	00004597          	auipc	a1,0x4
ffffffffc0200202:	b8a58593          	addi	a1,a1,-1142 # ffffffffc0203d88 <etext>
ffffffffc0200206:	00004517          	auipc	a0,0x4
ffffffffc020020a:	bf250513          	addi	a0,a0,-1038 # ffffffffc0203df8 <etext+0x70>
ffffffffc020020e:	f87ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200212:	00009597          	auipc	a1,0x9
ffffffffc0200216:	e1e58593          	addi	a1,a1,-482 # ffffffffc0209030 <buf>
ffffffffc020021a:	00004517          	auipc	a0,0x4
ffffffffc020021e:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0203e18 <etext+0x90>
ffffffffc0200222:	f73ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200226:	0000d597          	auipc	a1,0xd
ffffffffc020022a:	2ca58593          	addi	a1,a1,714 # ffffffffc020d4f0 <end>
ffffffffc020022e:	00004517          	auipc	a0,0x4
ffffffffc0200232:	c0a50513          	addi	a0,a0,-1014 # ffffffffc0203e38 <etext+0xb0>
ffffffffc0200236:	f5fff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020023a:	00000717          	auipc	a4,0x0
ffffffffc020023e:	e1070713          	addi	a4,a4,-496 # ffffffffc020004a <kern_init>
ffffffffc0200242:	0000d797          	auipc	a5,0xd
ffffffffc0200246:	6ad78793          	addi	a5,a5,1709 # ffffffffc020d8ef <end+0x3ff>
ffffffffc020024a:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020024c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200250:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200252:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200256:	95be                	add	a1,a1,a5
ffffffffc0200258:	85a9                	srai	a1,a1,0xa
ffffffffc020025a:	00004517          	auipc	a0,0x4
ffffffffc020025e:	bfe50513          	addi	a0,a0,-1026 # ffffffffc0203e58 <etext+0xd0>
}
ffffffffc0200262:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200264:	bf05                	j	ffffffffc0200194 <cprintf>

ffffffffc0200266 <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc0200266:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc0200268:	00004617          	auipc	a2,0x4
ffffffffc020026c:	c2060613          	addi	a2,a2,-992 # ffffffffc0203e88 <etext+0x100>
ffffffffc0200270:	04900593          	li	a1,73
ffffffffc0200274:	00004517          	auipc	a0,0x4
ffffffffc0200278:	c2c50513          	addi	a0,a0,-980 # ffffffffc0203ea0 <etext+0x118>
{
ffffffffc020027c:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc020027e:	188000ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0200282 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200282:	1101                	addi	sp,sp,-32
ffffffffc0200284:	e822                	sd	s0,16(sp)
ffffffffc0200286:	e426                	sd	s1,8(sp)
ffffffffc0200288:	ec06                	sd	ra,24(sp)
ffffffffc020028a:	00005417          	auipc	s0,0x5
ffffffffc020028e:	35640413          	addi	s0,s0,854 # ffffffffc02055e0 <commands>
ffffffffc0200292:	00005497          	auipc	s1,0x5
ffffffffc0200296:	39648493          	addi	s1,s1,918 # ffffffffc0205628 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020029a:	6410                	ld	a2,8(s0)
ffffffffc020029c:	600c                	ld	a1,0(s0)
ffffffffc020029e:	00004517          	auipc	a0,0x4
ffffffffc02002a2:	c1a50513          	addi	a0,a0,-998 # ffffffffc0203eb8 <etext+0x130>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002a6:	0461                	addi	s0,s0,24
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002a8:	eedff0ef          	jal	ffffffffc0200194 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ac:	fe9417e3          	bne	s0,s1,ffffffffc020029a <mon_help+0x18>
    }
    return 0;
}
ffffffffc02002b0:	60e2                	ld	ra,24(sp)
ffffffffc02002b2:	6442                	ld	s0,16(sp)
ffffffffc02002b4:	64a2                	ld	s1,8(sp)
ffffffffc02002b6:	4501                	li	a0,0
ffffffffc02002b8:	6105                	addi	sp,sp,32
ffffffffc02002ba:	8082                	ret

ffffffffc02002bc <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002bc:	1141                	addi	sp,sp,-16
ffffffffc02002be:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc02002c0:	f1bff0ef          	jal	ffffffffc02001da <print_kerninfo>
    return 0;
}
ffffffffc02002c4:	60a2                	ld	ra,8(sp)
ffffffffc02002c6:	4501                	li	a0,0
ffffffffc02002c8:	0141                	addi	sp,sp,16
ffffffffc02002ca:	8082                	ret

ffffffffc02002cc <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002cc:	1141                	addi	sp,sp,-16
ffffffffc02002ce:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc02002d0:	f97ff0ef          	jal	ffffffffc0200266 <print_stackframe>
    return 0;
}
ffffffffc02002d4:	60a2                	ld	ra,8(sp)
ffffffffc02002d6:	4501                	li	a0,0
ffffffffc02002d8:	0141                	addi	sp,sp,16
ffffffffc02002da:	8082                	ret

ffffffffc02002dc <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002dc:	7131                	addi	sp,sp,-192
ffffffffc02002de:	e952                	sd	s4,144(sp)
ffffffffc02002e0:	8a2a                	mv	s4,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002e2:	00004517          	auipc	a0,0x4
ffffffffc02002e6:	be650513          	addi	a0,a0,-1050 # ffffffffc0203ec8 <etext+0x140>
kmonitor(struct trapframe *tf) {
ffffffffc02002ea:	fd06                	sd	ra,184(sp)
ffffffffc02002ec:	f922                	sd	s0,176(sp)
ffffffffc02002ee:	f526                	sd	s1,168(sp)
ffffffffc02002f0:	f14a                	sd	s2,160(sp)
ffffffffc02002f2:	e556                	sd	s5,136(sp)
ffffffffc02002f4:	e15a                	sd	s6,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002f6:	e9fff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002fa:	00004517          	auipc	a0,0x4
ffffffffc02002fe:	bf650513          	addi	a0,a0,-1034 # ffffffffc0203ef0 <etext+0x168>
ffffffffc0200302:	e93ff0ef          	jal	ffffffffc0200194 <cprintf>
    if (tf != NULL) {
ffffffffc0200306:	000a0563          	beqz	s4,ffffffffc0200310 <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc020030a:	8552                	mv	a0,s4
ffffffffc020030c:	758000ef          	jal	ffffffffc0200a64 <print_trapframe>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200310:	4501                	li	a0,0
ffffffffc0200312:	4581                	li	a1,0
ffffffffc0200314:	4601                	li	a2,0
ffffffffc0200316:	48a1                	li	a7,8
ffffffffc0200318:	00000073          	ecall
ffffffffc020031c:	00005a97          	auipc	s5,0x5
ffffffffc0200320:	2c4a8a93          	addi	s5,s5,708 # ffffffffc02055e0 <commands>
        if (argc == MAXARGS - 1) {
ffffffffc0200324:	493d                	li	s2,15
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200326:	00004517          	auipc	a0,0x4
ffffffffc020032a:	bf250513          	addi	a0,a0,-1038 # ffffffffc0203f18 <etext+0x190>
ffffffffc020032e:	d79ff0ef          	jal	ffffffffc02000a6 <readline>
ffffffffc0200332:	842a                	mv	s0,a0
ffffffffc0200334:	d96d                	beqz	a0,ffffffffc0200326 <kmonitor+0x4a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200336:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020033a:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020033c:	e99d                	bnez	a1,ffffffffc0200372 <kmonitor+0x96>
    int argc = 0;
ffffffffc020033e:	8b26                	mv	s6,s1
    if (argc == 0) {
ffffffffc0200340:	fe0b03e3          	beqz	s6,ffffffffc0200326 <kmonitor+0x4a>
ffffffffc0200344:	00005497          	auipc	s1,0x5
ffffffffc0200348:	29c48493          	addi	s1,s1,668 # ffffffffc02055e0 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020034c:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020034e:	6582                	ld	a1,0(sp)
ffffffffc0200350:	6088                	ld	a0,0(s1)
ffffffffc0200352:	17b030ef          	jal	ffffffffc0203ccc <strcmp>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200356:	478d                	li	a5,3
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200358:	c149                	beqz	a0,ffffffffc02003da <kmonitor+0xfe>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020035a:	2405                	addiw	s0,s0,1
ffffffffc020035c:	04e1                	addi	s1,s1,24
ffffffffc020035e:	fef418e3          	bne	s0,a5,ffffffffc020034e <kmonitor+0x72>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200362:	6582                	ld	a1,0(sp)
ffffffffc0200364:	00004517          	auipc	a0,0x4
ffffffffc0200368:	be450513          	addi	a0,a0,-1052 # ffffffffc0203f48 <etext+0x1c0>
ffffffffc020036c:	e29ff0ef          	jal	ffffffffc0200194 <cprintf>
    return 0;
ffffffffc0200370:	bf5d                	j	ffffffffc0200326 <kmonitor+0x4a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200372:	00004517          	auipc	a0,0x4
ffffffffc0200376:	bae50513          	addi	a0,a0,-1106 # ffffffffc0203f20 <etext+0x198>
ffffffffc020037a:	1af030ef          	jal	ffffffffc0203d28 <strchr>
ffffffffc020037e:	c901                	beqz	a0,ffffffffc020038e <kmonitor+0xb2>
ffffffffc0200380:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200384:	00040023          	sb	zero,0(s0)
ffffffffc0200388:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	d9d5                	beqz	a1,ffffffffc020033e <kmonitor+0x62>
ffffffffc020038c:	b7dd                	j	ffffffffc0200372 <kmonitor+0x96>
        if (*buf == '\0') {
ffffffffc020038e:	00044783          	lbu	a5,0(s0)
ffffffffc0200392:	d7d5                	beqz	a5,ffffffffc020033e <kmonitor+0x62>
        if (argc == MAXARGS - 1) {
ffffffffc0200394:	03248b63          	beq	s1,s2,ffffffffc02003ca <kmonitor+0xee>
        argv[argc ++] = buf;
ffffffffc0200398:	00349793          	slli	a5,s1,0x3
ffffffffc020039c:	978a                	add	a5,a5,sp
ffffffffc020039e:	e380                	sd	s0,0(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a0:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003a4:	2485                	addiw	s1,s1,1
ffffffffc02003a6:	8b26                	mv	s6,s1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003a8:	e591                	bnez	a1,ffffffffc02003b4 <kmonitor+0xd8>
ffffffffc02003aa:	bf59                	j	ffffffffc0200340 <kmonitor+0x64>
ffffffffc02003ac:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003b0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003b2:	d5d1                	beqz	a1,ffffffffc020033e <kmonitor+0x62>
ffffffffc02003b4:	00004517          	auipc	a0,0x4
ffffffffc02003b8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0203f20 <etext+0x198>
ffffffffc02003bc:	16d030ef          	jal	ffffffffc0203d28 <strchr>
ffffffffc02003c0:	d575                	beqz	a0,ffffffffc02003ac <kmonitor+0xd0>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003c2:	00044583          	lbu	a1,0(s0)
ffffffffc02003c6:	dda5                	beqz	a1,ffffffffc020033e <kmonitor+0x62>
ffffffffc02003c8:	b76d                	j	ffffffffc0200372 <kmonitor+0x96>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02003ca:	45c1                	li	a1,16
ffffffffc02003cc:	00004517          	auipc	a0,0x4
ffffffffc02003d0:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0203f28 <etext+0x1a0>
ffffffffc02003d4:	dc1ff0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc02003d8:	b7c1                	j	ffffffffc0200398 <kmonitor+0xbc>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003da:	00141793          	slli	a5,s0,0x1
ffffffffc02003de:	97a2                	add	a5,a5,s0
ffffffffc02003e0:	078e                	slli	a5,a5,0x3
ffffffffc02003e2:	97d6                	add	a5,a5,s5
ffffffffc02003e4:	6b9c                	ld	a5,16(a5)
ffffffffc02003e6:	fffb051b          	addiw	a0,s6,-1
ffffffffc02003ea:	8652                	mv	a2,s4
ffffffffc02003ec:	002c                	addi	a1,sp,8
ffffffffc02003ee:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003f0:	f2055be3          	bgez	a0,ffffffffc0200326 <kmonitor+0x4a>
}
ffffffffc02003f4:	70ea                	ld	ra,184(sp)
ffffffffc02003f6:	744a                	ld	s0,176(sp)
ffffffffc02003f8:	74aa                	ld	s1,168(sp)
ffffffffc02003fa:	790a                	ld	s2,160(sp)
ffffffffc02003fc:	6a4a                	ld	s4,144(sp)
ffffffffc02003fe:	6aaa                	ld	s5,136(sp)
ffffffffc0200400:	6b0a                	ld	s6,128(sp)
ffffffffc0200402:	6129                	addi	sp,sp,192
ffffffffc0200404:	8082                	ret

ffffffffc0200406 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200406:	0000d317          	auipc	t1,0xd
ffffffffc020040a:	06232303          	lw	t1,98(t1) # ffffffffc020d468 <is_panic>
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020040e:	715d                	addi	sp,sp,-80
ffffffffc0200410:	ec06                	sd	ra,24(sp)
ffffffffc0200412:	f436                	sd	a3,40(sp)
ffffffffc0200414:	f83a                	sd	a4,48(sp)
ffffffffc0200416:	fc3e                	sd	a5,56(sp)
ffffffffc0200418:	e0c2                	sd	a6,64(sp)
ffffffffc020041a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020041c:	02031e63          	bnez	t1,ffffffffc0200458 <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200420:	4705                	li	a4,1

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200422:	103c                	addi	a5,sp,40
ffffffffc0200424:	e822                	sd	s0,16(sp)
ffffffffc0200426:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200428:	862e                	mv	a2,a1
ffffffffc020042a:	85aa                	mv	a1,a0
ffffffffc020042c:	00004517          	auipc	a0,0x4
ffffffffc0200430:	bc450513          	addi	a0,a0,-1084 # ffffffffc0203ff0 <etext+0x268>
    is_panic = 1;
ffffffffc0200434:	0000d697          	auipc	a3,0xd
ffffffffc0200438:	02e6aa23          	sw	a4,52(a3) # ffffffffc020d468 <is_panic>
    va_start(ap, fmt);
ffffffffc020043c:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020043e:	d57ff0ef          	jal	ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200442:	65a2                	ld	a1,8(sp)
ffffffffc0200444:	8522                	mv	a0,s0
ffffffffc0200446:	d2fff0ef          	jal	ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc020044a:	00004517          	auipc	a0,0x4
ffffffffc020044e:	bc650513          	addi	a0,a0,-1082 # ffffffffc0204010 <etext+0x288>
ffffffffc0200452:	d43ff0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0200456:	6442                	ld	s0,16(sp)
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200458:	41c000ef          	jal	ffffffffc0200874 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc020045c:	4501                	li	a0,0
ffffffffc020045e:	e7fff0ef          	jal	ffffffffc02002dc <kmonitor>
    while (1) {
ffffffffc0200462:	bfed                	j	ffffffffc020045c <__panic+0x56>

ffffffffc0200464 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc0200464:	67e1                	lui	a5,0x18
ffffffffc0200466:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020046a:	0000d717          	auipc	a4,0xd
ffffffffc020046e:	00f73323          	sd	a5,6(a4) # ffffffffc020d470 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200472:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200476:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200478:	953e                	add	a0,a0,a5
ffffffffc020047a:	4601                	li	a2,0
ffffffffc020047c:	4881                	li	a7,0
ffffffffc020047e:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200482:	02000793          	li	a5,32
ffffffffc0200486:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020048a:	00004517          	auipc	a0,0x4
ffffffffc020048e:	b8e50513          	addi	a0,a0,-1138 # ffffffffc0204018 <etext+0x290>
    ticks = 0;
ffffffffc0200492:	0000d797          	auipc	a5,0xd
ffffffffc0200496:	fe07b323          	sd	zero,-26(a5) # ffffffffc020d478 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020049a:	b9ed                	j	ffffffffc0200194 <cprintf>

ffffffffc020049c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020049c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02004a0:	0000d797          	auipc	a5,0xd
ffffffffc02004a4:	fd07b783          	ld	a5,-48(a5) # ffffffffc020d470 <timebase>
ffffffffc02004a8:	4581                	li	a1,0
ffffffffc02004aa:	4601                	li	a2,0
ffffffffc02004ac:	953e                	add	a0,a0,a5
ffffffffc02004ae:	4881                	li	a7,0
ffffffffc02004b0:	00000073          	ecall
ffffffffc02004b4:	8082                	ret

ffffffffc02004b6 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc02004b6:	8082                	ret

ffffffffc02004b8 <cons_putc>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004b8:	100027f3          	csrr	a5,sstatus
ffffffffc02004bc:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc02004be:	0ff57513          	zext.b	a0,a0
ffffffffc02004c2:	e799                	bnez	a5,ffffffffc02004d0 <cons_putc+0x18>
ffffffffc02004c4:	4581                	li	a1,0
ffffffffc02004c6:	4601                	li	a2,0
ffffffffc02004c8:	4885                	li	a7,1
ffffffffc02004ca:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc02004ce:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc02004d0:	1101                	addi	sp,sp,-32
ffffffffc02004d2:	ec06                	sd	ra,24(sp)
ffffffffc02004d4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02004d6:	39e000ef          	jal	ffffffffc0200874 <intr_disable>
ffffffffc02004da:	6522                	ld	a0,8(sp)
ffffffffc02004dc:	4581                	li	a1,0
ffffffffc02004de:	4601                	li	a2,0
ffffffffc02004e0:	4885                	li	a7,1
ffffffffc02004e2:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02004e6:	60e2                	ld	ra,24(sp)
ffffffffc02004e8:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02004ea:	a651                	j	ffffffffc020086e <intr_enable>

ffffffffc02004ec <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02004ec:	100027f3          	csrr	a5,sstatus
ffffffffc02004f0:	8b89                	andi	a5,a5,2
ffffffffc02004f2:	eb89                	bnez	a5,ffffffffc0200504 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02004f4:	4501                	li	a0,0
ffffffffc02004f6:	4581                	li	a1,0
ffffffffc02004f8:	4601                	li	a2,0
ffffffffc02004fa:	4889                	li	a7,2
ffffffffc02004fc:	00000073          	ecall
ffffffffc0200500:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200502:	8082                	ret
int cons_getc(void) {
ffffffffc0200504:	1101                	addi	sp,sp,-32
ffffffffc0200506:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200508:	36c000ef          	jal	ffffffffc0200874 <intr_disable>
ffffffffc020050c:	4501                	li	a0,0
ffffffffc020050e:	4581                	li	a1,0
ffffffffc0200510:	4601                	li	a2,0
ffffffffc0200512:	4889                	li	a7,2
ffffffffc0200514:	00000073          	ecall
ffffffffc0200518:	2501                	sext.w	a0,a0
ffffffffc020051a:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020051c:	352000ef          	jal	ffffffffc020086e <intr_enable>
}
ffffffffc0200520:	60e2                	ld	ra,24(sp)
ffffffffc0200522:	6522                	ld	a0,8(sp)
ffffffffc0200524:	6105                	addi	sp,sp,32
ffffffffc0200526:	8082                	ret

ffffffffc0200528 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200528:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc020052a:	00004517          	auipc	a0,0x4
ffffffffc020052e:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0204038 <etext+0x2b0>
void dtb_init(void) {
ffffffffc0200532:	f406                	sd	ra,40(sp)
ffffffffc0200534:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc0200536:	c5fff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc020053a:	00009597          	auipc	a1,0x9
ffffffffc020053e:	ac65b583          	ld	a1,-1338(a1) # ffffffffc0209000 <boot_hartid>
ffffffffc0200542:	00004517          	auipc	a0,0x4
ffffffffc0200546:	b0650513          	addi	a0,a0,-1274 # ffffffffc0204048 <etext+0x2c0>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020054a:	00009417          	auipc	s0,0x9
ffffffffc020054e:	abe40413          	addi	s0,s0,-1346 # ffffffffc0209008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200552:	c43ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200556:	600c                	ld	a1,0(s0)
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204058 <etext+0x2d0>
ffffffffc0200560:	c35ff0ef          	jal	ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200564:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0204070 <etext+0x2e8>
    if (boot_dtb == 0) {
ffffffffc020056e:	10070163          	beqz	a4,ffffffffc0200670 <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200572:	57f5                	li	a5,-3
ffffffffc0200574:	07fa                	slli	a5,a5,0x1e
ffffffffc0200576:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200578:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc020057a:	d00e06b7          	lui	a3,0xd00e0
ffffffffc020057e:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfed29fd>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200582:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200586:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020058a:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020058e:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200592:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200596:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200598:	8e49                	or	a2,a2,a0
ffffffffc020059a:	0ff7f793          	zext.b	a5,a5
ffffffffc020059e:	8dd1                	or	a1,a1,a2
ffffffffc02005a0:	07a2                	slli	a5,a5,0x8
ffffffffc02005a2:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005a4:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc02005a8:	0cd59863          	bne	a1,a3,ffffffffc0200678 <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02005ac:	4710                	lw	a2,8(a4)
ffffffffc02005ae:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02005b0:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005b2:	0086541b          	srliw	s0,a2,0x8
ffffffffc02005b6:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ba:	01865e1b          	srliw	t3,a2,0x18
ffffffffc02005be:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005c2:	0186151b          	slliw	a0,a2,0x18
ffffffffc02005c6:	0186959b          	slliw	a1,a3,0x18
ffffffffc02005ca:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ce:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005d2:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005d6:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02005da:	01c56533          	or	a0,a0,t3
ffffffffc02005de:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005e2:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005e6:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ea:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005ee:	0ff6f693          	zext.b	a3,a3
ffffffffc02005f2:	8c49                	or	s0,s0,a0
ffffffffc02005f4:	0622                	slli	a2,a2,0x8
ffffffffc02005f6:	8fcd                	or	a5,a5,a1
ffffffffc02005f8:	06a2                	slli	a3,a3,0x8
ffffffffc02005fa:	8c51                	or	s0,s0,a2
ffffffffc02005fc:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02005fe:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200600:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200602:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200604:	9381                	srli	a5,a5,0x20
ffffffffc0200606:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc0200608:	4301                	li	t1,0
        switch (token) {
ffffffffc020060a:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020060c:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020060e:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc0200612:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200614:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200616:	0087579b          	srliw	a5,a4,0x8
ffffffffc020061a:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020061e:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200622:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200626:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020062a:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020062e:	8ed1                	or	a3,a3,a2
ffffffffc0200630:	0ff77713          	zext.b	a4,a4
ffffffffc0200634:	8fd5                	or	a5,a5,a3
ffffffffc0200636:	0722                	slli	a4,a4,0x8
ffffffffc0200638:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc020063a:	05178763          	beq	a5,a7,ffffffffc0200688 <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020063e:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc0200640:	00f8e963          	bltu	a7,a5,ffffffffc0200652 <dtb_init+0x12a>
ffffffffc0200644:	07c78d63          	beq	a5,t3,ffffffffc02006be <dtb_init+0x196>
ffffffffc0200648:	4709                	li	a4,2
ffffffffc020064a:	00e79763          	bne	a5,a4,ffffffffc0200658 <dtb_init+0x130>
ffffffffc020064e:	4301                	li	t1,0
ffffffffc0200650:	b7d1                	j	ffffffffc0200614 <dtb_init+0xec>
ffffffffc0200652:	4711                	li	a4,4
ffffffffc0200654:	fce780e3          	beq	a5,a4,ffffffffc0200614 <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200658:	00004517          	auipc	a0,0x4
ffffffffc020065c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0204138 <etext+0x3b0>
ffffffffc0200660:	b35ff0ef          	jal	ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200664:	64e2                	ld	s1,24(sp)
ffffffffc0200666:	6942                	ld	s2,16(sp)
ffffffffc0200668:	00004517          	auipc	a0,0x4
ffffffffc020066c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0204170 <etext+0x3e8>
}
ffffffffc0200670:	7402                	ld	s0,32(sp)
ffffffffc0200672:	70a2                	ld	ra,40(sp)
ffffffffc0200674:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc0200676:	be39                	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200678:	7402                	ld	s0,32(sp)
ffffffffc020067a:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020067c:	00004517          	auipc	a0,0x4
ffffffffc0200680:	a1450513          	addi	a0,a0,-1516 # ffffffffc0204090 <etext+0x308>
}
ffffffffc0200684:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200686:	b639                	j	ffffffffc0200194 <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200688:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020068a:	0087579b          	srliw	a5,a4,0x8
ffffffffc020068e:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200692:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200696:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020069a:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020069e:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006a2:	8ed1                	or	a3,a3,a2
ffffffffc02006a4:	0ff77713          	zext.b	a4,a4
ffffffffc02006a8:	8fd5                	or	a5,a5,a3
ffffffffc02006aa:	0722                	slli	a4,a4,0x8
ffffffffc02006ac:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006ae:	04031463          	bnez	t1,ffffffffc02006f6 <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02006b2:	1782                	slli	a5,a5,0x20
ffffffffc02006b4:	9381                	srli	a5,a5,0x20
ffffffffc02006b6:	043d                	addi	s0,s0,15
ffffffffc02006b8:	943e                	add	s0,s0,a5
ffffffffc02006ba:	9871                	andi	s0,s0,-4
                break;
ffffffffc02006bc:	bfa1                	j	ffffffffc0200614 <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc02006be:	8522                	mv	a0,s0
ffffffffc02006c0:	e01a                	sd	t1,0(sp)
ffffffffc02006c2:	5c4030ef          	jal	ffffffffc0203c86 <strlen>
ffffffffc02006c6:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02006c8:	4619                	li	a2,6
ffffffffc02006ca:	8522                	mv	a0,s0
ffffffffc02006cc:	00004597          	auipc	a1,0x4
ffffffffc02006d0:	9ec58593          	addi	a1,a1,-1556 # ffffffffc02040b8 <etext+0x330>
ffffffffc02006d4:	62c030ef          	jal	ffffffffc0203d00 <strncmp>
ffffffffc02006d8:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02006da:	0411                	addi	s0,s0,4
ffffffffc02006dc:	0004879b          	sext.w	a5,s1
ffffffffc02006e0:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02006e2:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02006e6:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02006e8:	00a36333          	or	t1,t1,a0
                break;
ffffffffc02006ec:	00ff0837          	lui	a6,0xff0
ffffffffc02006f0:	488d                	li	a7,3
ffffffffc02006f2:	4e05                	li	t3,1
ffffffffc02006f4:	b705                	j	ffffffffc0200614 <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006f6:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02006f8:	00004597          	auipc	a1,0x4
ffffffffc02006fc:	9c858593          	addi	a1,a1,-1592 # ffffffffc02040c0 <etext+0x338>
ffffffffc0200700:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200702:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200706:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020070a:	0187169b          	slliw	a3,a4,0x18
ffffffffc020070e:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200712:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200716:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020071a:	8ed1                	or	a3,a3,a2
ffffffffc020071c:	0ff77713          	zext.b	a4,a4
ffffffffc0200720:	0722                	slli	a4,a4,0x8
ffffffffc0200722:	8d55                	or	a0,a0,a3
ffffffffc0200724:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200726:	1502                	slli	a0,a0,0x20
ffffffffc0200728:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020072a:	954a                	add	a0,a0,s2
ffffffffc020072c:	e01a                	sd	t1,0(sp)
ffffffffc020072e:	59e030ef          	jal	ffffffffc0203ccc <strcmp>
ffffffffc0200732:	67a2                	ld	a5,8(sp)
ffffffffc0200734:	473d                	li	a4,15
ffffffffc0200736:	6302                	ld	t1,0(sp)
ffffffffc0200738:	00ff0837          	lui	a6,0xff0
ffffffffc020073c:	488d                	li	a7,3
ffffffffc020073e:	4e05                	li	t3,1
ffffffffc0200740:	f6f779e3          	bgeu	a4,a5,ffffffffc02006b2 <dtb_init+0x18a>
ffffffffc0200744:	f53d                	bnez	a0,ffffffffc02006b2 <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200746:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020074a:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020074e:	00004517          	auipc	a0,0x4
ffffffffc0200752:	97a50513          	addi	a0,a0,-1670 # ffffffffc02040c8 <etext+0x340>
           fdt32_to_cpu(x >> 32);
ffffffffc0200756:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020075a:	0087d31b          	srliw	t1,a5,0x8
ffffffffc020075e:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200762:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200766:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020076a:	0187959b          	slliw	a1,a5,0x18
ffffffffc020076e:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200772:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200776:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020077a:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020077e:	01037333          	and	t1,t1,a6
ffffffffc0200782:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200786:	01e5e5b3          	or	a1,a1,t5
ffffffffc020078a:	0ff7f793          	zext.b	a5,a5
ffffffffc020078e:	01de6e33          	or	t3,t3,t4
ffffffffc0200792:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200796:	01067633          	and	a2,a2,a6
ffffffffc020079a:	0086d31b          	srliw	t1,a3,0x8
ffffffffc020079e:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007a2:	07a2                	slli	a5,a5,0x8
ffffffffc02007a4:	0108d89b          	srliw	a7,a7,0x10
ffffffffc02007a8:	0186df1b          	srliw	t5,a3,0x18
ffffffffc02007ac:	01875e9b          	srliw	t4,a4,0x18
ffffffffc02007b0:	8ddd                	or	a1,a1,a5
ffffffffc02007b2:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007b6:	0186979b          	slliw	a5,a3,0x18
ffffffffc02007ba:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007be:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007c2:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007c6:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007ca:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007ce:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007d2:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007d6:	08a2                	slli	a7,a7,0x8
ffffffffc02007d8:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007dc:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007e0:	0ff6f693          	zext.b	a3,a3
ffffffffc02007e4:	01de6833          	or	a6,t3,t4
ffffffffc02007e8:	0ff77713          	zext.b	a4,a4
ffffffffc02007ec:	01166633          	or	a2,a2,a7
ffffffffc02007f0:	0067e7b3          	or	a5,a5,t1
ffffffffc02007f4:	06a2                	slli	a3,a3,0x8
ffffffffc02007f6:	01046433          	or	s0,s0,a6
ffffffffc02007fa:	0722                	slli	a4,a4,0x8
ffffffffc02007fc:	8fd5                	or	a5,a5,a3
ffffffffc02007fe:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc0200800:	1582                	slli	a1,a1,0x20
ffffffffc0200802:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200804:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200806:	9201                	srli	a2,a2,0x20
ffffffffc0200808:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020080a:	1402                	slli	s0,s0,0x20
ffffffffc020080c:	00b7e4b3          	or	s1,a5,a1
ffffffffc0200810:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200812:	983ff0ef          	jal	ffffffffc0200194 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200816:	85a6                	mv	a1,s1
ffffffffc0200818:	00004517          	auipc	a0,0x4
ffffffffc020081c:	8d050513          	addi	a0,a0,-1840 # ffffffffc02040e8 <etext+0x360>
ffffffffc0200820:	975ff0ef          	jal	ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200824:	01445613          	srli	a2,s0,0x14
ffffffffc0200828:	85a2                	mv	a1,s0
ffffffffc020082a:	00004517          	auipc	a0,0x4
ffffffffc020082e:	8d650513          	addi	a0,a0,-1834 # ffffffffc0204100 <etext+0x378>
ffffffffc0200832:	963ff0ef          	jal	ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200836:	009405b3          	add	a1,s0,s1
ffffffffc020083a:	15fd                	addi	a1,a1,-1
ffffffffc020083c:	00004517          	auipc	a0,0x4
ffffffffc0200840:	8e450513          	addi	a0,a0,-1820 # ffffffffc0204120 <etext+0x398>
ffffffffc0200844:	951ff0ef          	jal	ffffffffc0200194 <cprintf>
        memory_base = mem_base;
ffffffffc0200848:	0000d797          	auipc	a5,0xd
ffffffffc020084c:	c497b023          	sd	s1,-960(a5) # ffffffffc020d488 <memory_base>
        memory_size = mem_size;
ffffffffc0200850:	0000d797          	auipc	a5,0xd
ffffffffc0200854:	c287b823          	sd	s0,-976(a5) # ffffffffc020d480 <memory_size>
ffffffffc0200858:	b531                	j	ffffffffc0200664 <dtb_init+0x13c>

ffffffffc020085a <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020085a:	0000d517          	auipc	a0,0xd
ffffffffc020085e:	c2e53503          	ld	a0,-978(a0) # ffffffffc020d488 <memory_base>
ffffffffc0200862:	8082                	ret

ffffffffc0200864 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc0200864:	0000d517          	auipc	a0,0xd
ffffffffc0200868:	c1c53503          	ld	a0,-996(a0) # ffffffffc020d480 <memory_size>
ffffffffc020086c:	8082                	ret

ffffffffc020086e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020086e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200872:	8082                	ret

ffffffffc0200874 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200874:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200878:	8082                	ret

ffffffffc020087a <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020087a:	8082                	ret

ffffffffc020087c <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020087c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200880:	00000797          	auipc	a5,0x0
ffffffffc0200884:	3fc78793          	addi	a5,a5,1020 # ffffffffc0200c7c <__alltraps>
ffffffffc0200888:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020088c:	000407b7          	lui	a5,0x40
ffffffffc0200890:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200894:	8082                	ret

ffffffffc0200896 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200896:	610c                	ld	a1,0(a0)
{
ffffffffc0200898:	1141                	addi	sp,sp,-16
ffffffffc020089a:	e022                	sd	s0,0(sp)
ffffffffc020089c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020089e:	00004517          	auipc	a0,0x4
ffffffffc02008a2:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0204188 <etext+0x400>
{
ffffffffc02008a6:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02008a8:	8edff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02008ac:	640c                	ld	a1,8(s0)
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	8f250513          	addi	a0,a0,-1806 # ffffffffc02041a0 <etext+0x418>
ffffffffc02008b6:	8dfff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02008ba:	680c                	ld	a1,16(s0)
ffffffffc02008bc:	00004517          	auipc	a0,0x4
ffffffffc02008c0:	8fc50513          	addi	a0,a0,-1796 # ffffffffc02041b8 <etext+0x430>
ffffffffc02008c4:	8d1ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02008c8:	6c0c                	ld	a1,24(s0)
ffffffffc02008ca:	00004517          	auipc	a0,0x4
ffffffffc02008ce:	90650513          	addi	a0,a0,-1786 # ffffffffc02041d0 <etext+0x448>
ffffffffc02008d2:	8c3ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02008d6:	700c                	ld	a1,32(s0)
ffffffffc02008d8:	00004517          	auipc	a0,0x4
ffffffffc02008dc:	91050513          	addi	a0,a0,-1776 # ffffffffc02041e8 <etext+0x460>
ffffffffc02008e0:	8b5ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02008e4:	740c                	ld	a1,40(s0)
ffffffffc02008e6:	00004517          	auipc	a0,0x4
ffffffffc02008ea:	91a50513          	addi	a0,a0,-1766 # ffffffffc0204200 <etext+0x478>
ffffffffc02008ee:	8a7ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02008f2:	780c                	ld	a1,48(s0)
ffffffffc02008f4:	00004517          	auipc	a0,0x4
ffffffffc02008f8:	92450513          	addi	a0,a0,-1756 # ffffffffc0204218 <etext+0x490>
ffffffffc02008fc:	899ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200900:	7c0c                	ld	a1,56(s0)
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	92e50513          	addi	a0,a0,-1746 # ffffffffc0204230 <etext+0x4a8>
ffffffffc020090a:	88bff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc020090e:	602c                	ld	a1,64(s0)
ffffffffc0200910:	00004517          	auipc	a0,0x4
ffffffffc0200914:	93850513          	addi	a0,a0,-1736 # ffffffffc0204248 <etext+0x4c0>
ffffffffc0200918:	87dff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc020091c:	642c                	ld	a1,72(s0)
ffffffffc020091e:	00004517          	auipc	a0,0x4
ffffffffc0200922:	94250513          	addi	a0,a0,-1726 # ffffffffc0204260 <etext+0x4d8>
ffffffffc0200926:	86fff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020092a:	682c                	ld	a1,80(s0)
ffffffffc020092c:	00004517          	auipc	a0,0x4
ffffffffc0200930:	94c50513          	addi	a0,a0,-1716 # ffffffffc0204278 <etext+0x4f0>
ffffffffc0200934:	861ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200938:	6c2c                	ld	a1,88(s0)
ffffffffc020093a:	00004517          	auipc	a0,0x4
ffffffffc020093e:	95650513          	addi	a0,a0,-1706 # ffffffffc0204290 <etext+0x508>
ffffffffc0200942:	853ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200946:	702c                	ld	a1,96(s0)
ffffffffc0200948:	00004517          	auipc	a0,0x4
ffffffffc020094c:	96050513          	addi	a0,a0,-1696 # ffffffffc02042a8 <etext+0x520>
ffffffffc0200950:	845ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200954:	742c                	ld	a1,104(s0)
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	96a50513          	addi	a0,a0,-1686 # ffffffffc02042c0 <etext+0x538>
ffffffffc020095e:	837ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200962:	782c                	ld	a1,112(s0)
ffffffffc0200964:	00004517          	auipc	a0,0x4
ffffffffc0200968:	97450513          	addi	a0,a0,-1676 # ffffffffc02042d8 <etext+0x550>
ffffffffc020096c:	829ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200970:	7c2c                	ld	a1,120(s0)
ffffffffc0200972:	00004517          	auipc	a0,0x4
ffffffffc0200976:	97e50513          	addi	a0,a0,-1666 # ffffffffc02042f0 <etext+0x568>
ffffffffc020097a:	81bff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020097e:	604c                	ld	a1,128(s0)
ffffffffc0200980:	00004517          	auipc	a0,0x4
ffffffffc0200984:	98850513          	addi	a0,a0,-1656 # ffffffffc0204308 <etext+0x580>
ffffffffc0200988:	80dff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020098c:	644c                	ld	a1,136(s0)
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	99250513          	addi	a0,a0,-1646 # ffffffffc0204320 <etext+0x598>
ffffffffc0200996:	ffeff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020099a:	684c                	ld	a1,144(s0)
ffffffffc020099c:	00004517          	auipc	a0,0x4
ffffffffc02009a0:	99c50513          	addi	a0,a0,-1636 # ffffffffc0204338 <etext+0x5b0>
ffffffffc02009a4:	ff0ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02009a8:	6c4c                	ld	a1,152(s0)
ffffffffc02009aa:	00004517          	auipc	a0,0x4
ffffffffc02009ae:	9a650513          	addi	a0,a0,-1626 # ffffffffc0204350 <etext+0x5c8>
ffffffffc02009b2:	fe2ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02009b6:	704c                	ld	a1,160(s0)
ffffffffc02009b8:	00004517          	auipc	a0,0x4
ffffffffc02009bc:	9b050513          	addi	a0,a0,-1616 # ffffffffc0204368 <etext+0x5e0>
ffffffffc02009c0:	fd4ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02009c4:	744c                	ld	a1,168(s0)
ffffffffc02009c6:	00004517          	auipc	a0,0x4
ffffffffc02009ca:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0204380 <etext+0x5f8>
ffffffffc02009ce:	fc6ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02009d2:	784c                	ld	a1,176(s0)
ffffffffc02009d4:	00004517          	auipc	a0,0x4
ffffffffc02009d8:	9c450513          	addi	a0,a0,-1596 # ffffffffc0204398 <etext+0x610>
ffffffffc02009dc:	fb8ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02009e0:	7c4c                	ld	a1,184(s0)
ffffffffc02009e2:	00004517          	auipc	a0,0x4
ffffffffc02009e6:	9ce50513          	addi	a0,a0,-1586 # ffffffffc02043b0 <etext+0x628>
ffffffffc02009ea:	faaff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02009ee:	606c                	ld	a1,192(s0)
ffffffffc02009f0:	00004517          	auipc	a0,0x4
ffffffffc02009f4:	9d850513          	addi	a0,a0,-1576 # ffffffffc02043c8 <etext+0x640>
ffffffffc02009f8:	f9cff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02009fc:	646c                	ld	a1,200(s0)
ffffffffc02009fe:	00004517          	auipc	a0,0x4
ffffffffc0200a02:	9e250513          	addi	a0,a0,-1566 # ffffffffc02043e0 <etext+0x658>
ffffffffc0200a06:	f8eff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a0a:	686c                	ld	a1,208(s0)
ffffffffc0200a0c:	00004517          	auipc	a0,0x4
ffffffffc0200a10:	9ec50513          	addi	a0,a0,-1556 # ffffffffc02043f8 <etext+0x670>
ffffffffc0200a14:	f80ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200a18:	6c6c                	ld	a1,216(s0)
ffffffffc0200a1a:	00004517          	auipc	a0,0x4
ffffffffc0200a1e:	9f650513          	addi	a0,a0,-1546 # ffffffffc0204410 <etext+0x688>
ffffffffc0200a22:	f72ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200a26:	706c                	ld	a1,224(s0)
ffffffffc0200a28:	00004517          	auipc	a0,0x4
ffffffffc0200a2c:	a0050513          	addi	a0,a0,-1536 # ffffffffc0204428 <etext+0x6a0>
ffffffffc0200a30:	f64ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200a34:	746c                	ld	a1,232(s0)
ffffffffc0200a36:	00004517          	auipc	a0,0x4
ffffffffc0200a3a:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0204440 <etext+0x6b8>
ffffffffc0200a3e:	f56ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200a42:	786c                	ld	a1,240(s0)
ffffffffc0200a44:	00004517          	auipc	a0,0x4
ffffffffc0200a48:	a1450513          	addi	a0,a0,-1516 # ffffffffc0204458 <etext+0x6d0>
ffffffffc0200a4c:	f48ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a50:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200a52:	6402                	ld	s0,0(sp)
ffffffffc0200a54:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a56:	00004517          	auipc	a0,0x4
ffffffffc0200a5a:	a1a50513          	addi	a0,a0,-1510 # ffffffffc0204470 <etext+0x6e8>
}
ffffffffc0200a5e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200a60:	f34ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200a64 <print_trapframe>:
{
ffffffffc0200a64:	1141                	addi	sp,sp,-16
ffffffffc0200a66:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a68:	85aa                	mv	a1,a0
{
ffffffffc0200a6a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a6c:	00004517          	auipc	a0,0x4
ffffffffc0200a70:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0204488 <etext+0x700>
{
ffffffffc0200a74:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200a76:	f1eff0ef          	jal	ffffffffc0200194 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200a7a:	8522                	mv	a0,s0
ffffffffc0200a7c:	e1bff0ef          	jal	ffffffffc0200896 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200a80:	10043583          	ld	a1,256(s0)
ffffffffc0200a84:	00004517          	auipc	a0,0x4
ffffffffc0200a88:	a1c50513          	addi	a0,a0,-1508 # ffffffffc02044a0 <etext+0x718>
ffffffffc0200a8c:	f08ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200a90:	10843583          	ld	a1,264(s0)
ffffffffc0200a94:	00004517          	auipc	a0,0x4
ffffffffc0200a98:	a2450513          	addi	a0,a0,-1500 # ffffffffc02044b8 <etext+0x730>
ffffffffc0200a9c:	ef8ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200aa0:	11043583          	ld	a1,272(s0)
ffffffffc0200aa4:	00004517          	auipc	a0,0x4
ffffffffc0200aa8:	a2c50513          	addi	a0,a0,-1492 # ffffffffc02044d0 <etext+0x748>
ffffffffc0200aac:	ee8ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200ab0:	11843583          	ld	a1,280(s0)
}
ffffffffc0200ab4:	6402                	ld	s0,0(sp)
ffffffffc0200ab6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200ab8:	00004517          	auipc	a0,0x4
ffffffffc0200abc:	a3050513          	addi	a0,a0,-1488 # ffffffffc02044e8 <etext+0x760>
}
ffffffffc0200ac0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200ac2:	ed2ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200ac6 <interrupt_handler>:
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause)
ffffffffc0200ac6:	11853783          	ld	a5,280(a0)
ffffffffc0200aca:	472d                	li	a4,11
ffffffffc0200acc:	0786                	slli	a5,a5,0x1
ffffffffc0200ace:	8385                	srli	a5,a5,0x1
ffffffffc0200ad0:	08f76d63          	bltu	a4,a5,ffffffffc0200b6a <interrupt_handler+0xa4>
ffffffffc0200ad4:	00005717          	auipc	a4,0x5
ffffffffc0200ad8:	b5470713          	addi	a4,a4,-1196 # ffffffffc0205628 <commands+0x48>
ffffffffc0200adc:	078a                	slli	a5,a5,0x2
ffffffffc0200ade:	97ba                	add	a5,a5,a4
ffffffffc0200ae0:	439c                	lw	a5,0(a5)
ffffffffc0200ae2:	97ba                	add	a5,a5,a4
ffffffffc0200ae4:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200ae6:	00004517          	auipc	a0,0x4
ffffffffc0200aea:	a7a50513          	addi	a0,a0,-1414 # ffffffffc0204560 <etext+0x7d8>
ffffffffc0200aee:	ea6ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200af2:	00004517          	auipc	a0,0x4
ffffffffc0200af6:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0204540 <etext+0x7b8>
ffffffffc0200afa:	e9aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200afe:	00004517          	auipc	a0,0x4
ffffffffc0200b02:	a0250513          	addi	a0,a0,-1534 # ffffffffc0204500 <etext+0x778>
ffffffffc0200b06:	e8eff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200b0a:	00004517          	auipc	a0,0x4
ffffffffc0200b0e:	a1650513          	addi	a0,a0,-1514 # ffffffffc0204520 <etext+0x798>
ffffffffc0200b12:	e82ff06f          	j	ffffffffc0200194 <cprintf>
{
ffffffffc0200b16:	1141                	addi	sp,sp,-16
ffffffffc0200b18:	e406                	sd	ra,8(sp)
        // In fact, Call sbi_set_timer will clear STIP, or you can clear it
        // directly.
        // clear_csr(sip, SIP_STIP);

        /*LAB3 请补充你在lab3中的代码 */ 
        clock_set_next_event();  // 设置下次时钟中断，维持定时器周期
ffffffffc0200b1a:	983ff0ef          	jal	ffffffffc020049c <clock_set_next_event>
            ticks++;  // 全局时钟计数器加1
ffffffffc0200b1e:	0000d797          	auipc	a5,0xd
ffffffffc0200b22:	95a78793          	addi	a5,a5,-1702 # ffffffffc020d478 <ticks>
ffffffffc0200b26:	6394                	ld	a3,0(a5)
            
            if (ticks % TICK_NUM == 0) {  // 每100次时钟中断执行一次
ffffffffc0200b28:	28f5c737          	lui	a4,0x28f5c
ffffffffc0200b2c:	28f70713          	addi	a4,a4,655 # 28f5c28f <kern_entry-0xffffffff972a3d71>
            ticks++;  // 全局时钟计数器加1
ffffffffc0200b30:	0685                	addi	a3,a3,1
ffffffffc0200b32:	e394                	sd	a3,0(a5)
            if (ticks % TICK_NUM == 0) {  // 每100次时钟中断执行一次
ffffffffc0200b34:	6390                	ld	a2,0(a5)
ffffffffc0200b36:	5c28f6b7          	lui	a3,0x5c28f
ffffffffc0200b3a:	1702                	slli	a4,a4,0x20
ffffffffc0200b3c:	5c368693          	addi	a3,a3,1475 # 5c28f5c3 <kern_entry-0xffffffff63f70a3d>
ffffffffc0200b40:	00265793          	srli	a5,a2,0x2
ffffffffc0200b44:	9736                	add	a4,a4,a3
ffffffffc0200b46:	02e7b7b3          	mulhu	a5,a5,a4
ffffffffc0200b4a:	06400593          	li	a1,100
ffffffffc0200b4e:	8389                	srli	a5,a5,0x2
ffffffffc0200b50:	02b787b3          	mul	a5,a5,a1
ffffffffc0200b54:	00f60c63          	beq	a2,a5,ffffffffc0200b6c <interrupt_handler+0xa6>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200b58:	60a2                	ld	ra,8(sp)
ffffffffc0200b5a:	0141                	addi	sp,sp,16
ffffffffc0200b5c:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200b5e:	00004517          	auipc	a0,0x4
ffffffffc0200b62:	a3250513          	addi	a0,a0,-1486 # ffffffffc0204590 <etext+0x808>
ffffffffc0200b66:	e2eff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200b6a:	bded                	j	ffffffffc0200a64 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200b6c:	00004517          	auipc	a0,0x4
ffffffffc0200b70:	a1450513          	addi	a0,a0,-1516 # ffffffffc0204580 <etext+0x7f8>
ffffffffc0200b74:	e20ff0ef          	jal	ffffffffc0200194 <cprintf>
                num++;  // 打印次数计数器加1
ffffffffc0200b78:	0000d797          	auipc	a5,0xd
ffffffffc0200b7c:	9187a783          	lw	a5,-1768(a5) # ffffffffc020d490 <num>
                if (num == 10) {  // 如果已经打印了10次（即1000次中断）
ffffffffc0200b80:	4729                	li	a4,10
                num++;  // 打印次数计数器加1
ffffffffc0200b82:	2785                	addiw	a5,a5,1
ffffffffc0200b84:	0000d697          	auipc	a3,0xd
ffffffffc0200b88:	90f6a623          	sw	a5,-1780(a3) # ffffffffc020d490 <num>
                if (num == 10) {  // 如果已经打印了10次（即1000次中断）
ffffffffc0200b8c:	fce796e3          	bne	a5,a4,ffffffffc0200b58 <interrupt_handler+0x92>
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200b90:	4501                	li	a0,0
ffffffffc0200b92:	4581                	li	a1,0
ffffffffc0200b94:	4601                	li	a2,0
ffffffffc0200b96:	48a1                	li	a7,8
ffffffffc0200b98:	00000073          	ecall
}
ffffffffc0200b9c:	bf75                	j	ffffffffc0200b58 <interrupt_handler+0x92>

ffffffffc0200b9e <exception_handler>:

void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200b9e:	11853783          	ld	a5,280(a0)
ffffffffc0200ba2:	473d                	li	a4,15
ffffffffc0200ba4:	0cf76563          	bltu	a4,a5,ffffffffc0200c6e <exception_handler+0xd0>
ffffffffc0200ba8:	00005717          	auipc	a4,0x5
ffffffffc0200bac:	ab070713          	addi	a4,a4,-1360 # ffffffffc0205658 <commands+0x78>
ffffffffc0200bb0:	078a                	slli	a5,a5,0x2
ffffffffc0200bb2:	97ba                	add	a5,a5,a4
ffffffffc0200bb4:	439c                	lw	a5,0(a5)
ffffffffc0200bb6:	97ba                	add	a5,a5,a4
ffffffffc0200bb8:	8782                	jr	a5
        break;
    case CAUSE_LOAD_PAGE_FAULT:
        cprintf("Load page fault\n");
        break;
    case CAUSE_STORE_PAGE_FAULT:
        cprintf("Store/AMO page fault\n");
ffffffffc0200bba:	00004517          	auipc	a0,0x4
ffffffffc0200bbe:	b7650513          	addi	a0,a0,-1162 # ffffffffc0204730 <etext+0x9a8>
ffffffffc0200bc2:	dd2ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Instruction address misaligned\n");
ffffffffc0200bc6:	00004517          	auipc	a0,0x4
ffffffffc0200bca:	9ea50513          	addi	a0,a0,-1558 # ffffffffc02045b0 <etext+0x828>
ffffffffc0200bce:	dc6ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Instruction access fault\n");
ffffffffc0200bd2:	00004517          	auipc	a0,0x4
ffffffffc0200bd6:	9fe50513          	addi	a0,a0,-1538 # ffffffffc02045d0 <etext+0x848>
ffffffffc0200bda:	dbaff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Illegal instruction\n");
ffffffffc0200bde:	00004517          	auipc	a0,0x4
ffffffffc0200be2:	a1250513          	addi	a0,a0,-1518 # ffffffffc02045f0 <etext+0x868>
ffffffffc0200be6:	daeff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Breakpoint\n");
ffffffffc0200bea:	00004517          	auipc	a0,0x4
ffffffffc0200bee:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0204608 <etext+0x880>
ffffffffc0200bf2:	da2ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Load address misaligned\n");
ffffffffc0200bf6:	00004517          	auipc	a0,0x4
ffffffffc0200bfa:	a2250513          	addi	a0,a0,-1502 # ffffffffc0204618 <etext+0x890>
ffffffffc0200bfe:	d96ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Load access fault\n");
ffffffffc0200c02:	00004517          	auipc	a0,0x4
ffffffffc0200c06:	a3650513          	addi	a0,a0,-1482 # ffffffffc0204638 <etext+0x8b0>
ffffffffc0200c0a:	d8aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("AMO address misaligned\n");
ffffffffc0200c0e:	00004517          	auipc	a0,0x4
ffffffffc0200c12:	a4250513          	addi	a0,a0,-1470 # ffffffffc0204650 <etext+0x8c8>
ffffffffc0200c16:	d7eff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Store/AMO access fault\n");
ffffffffc0200c1a:	00004517          	auipc	a0,0x4
ffffffffc0200c1e:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0204668 <etext+0x8e0>
ffffffffc0200c22:	d72ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from U-mode\n");
ffffffffc0200c26:	00004517          	auipc	a0,0x4
ffffffffc0200c2a:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0204680 <etext+0x8f8>
ffffffffc0200c2e:	d66ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from S-mode\n");
ffffffffc0200c32:	00004517          	auipc	a0,0x4
ffffffffc0200c36:	a6e50513          	addi	a0,a0,-1426 # ffffffffc02046a0 <etext+0x918>
ffffffffc0200c3a:	d5aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from H-mode\n");
ffffffffc0200c3e:	00004517          	auipc	a0,0x4
ffffffffc0200c42:	a8250513          	addi	a0,a0,-1406 # ffffffffc02046c0 <etext+0x938>
ffffffffc0200c46:	d4eff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Environment call from M-mode\n");
ffffffffc0200c4a:	00004517          	auipc	a0,0x4
ffffffffc0200c4e:	a9650513          	addi	a0,a0,-1386 # ffffffffc02046e0 <etext+0x958>
ffffffffc0200c52:	d42ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Instruction page fault\n");
ffffffffc0200c56:	00004517          	auipc	a0,0x4
ffffffffc0200c5a:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0204700 <etext+0x978>
ffffffffc0200c5e:	d36ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Load page fault\n");
ffffffffc0200c62:	00004517          	auipc	a0,0x4
ffffffffc0200c66:	ab650513          	addi	a0,a0,-1354 # ffffffffc0204718 <etext+0x990>
ffffffffc0200c6a:	d2aff06f          	j	ffffffffc0200194 <cprintf>
        break;
    default:
        print_trapframe(tf);
ffffffffc0200c6e:	bbdd                	j	ffffffffc0200a64 <print_trapframe>

ffffffffc0200c70 <trap>:
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0)
ffffffffc0200c70:	11853783          	ld	a5,280(a0)
ffffffffc0200c74:	0007c363          	bltz	a5,ffffffffc0200c7a <trap+0xa>
        interrupt_handler(tf);
    }
    else
    {
        // exceptions
        exception_handler(tf);
ffffffffc0200c78:	b71d                	j	ffffffffc0200b9e <exception_handler>
        interrupt_handler(tf);
ffffffffc0200c7a:	b5b1                	j	ffffffffc0200ac6 <interrupt_handler>

ffffffffc0200c7c <__alltraps>:

    // 全局陷阱处理入口点
    .globl __alltraps
__alltraps:
    // 保存所有寄存器到栈中（构建陷阱帧）
    SAVE_ALL
ffffffffc0200c7c:	14011073          	csrw	sscratch,sp
ffffffffc0200c80:	712d                	addi	sp,sp,-288
ffffffffc0200c82:	e406                	sd	ra,8(sp)
ffffffffc0200c84:	ec0e                	sd	gp,24(sp)
ffffffffc0200c86:	f012                	sd	tp,32(sp)
ffffffffc0200c88:	f416                	sd	t0,40(sp)
ffffffffc0200c8a:	f81a                	sd	t1,48(sp)
ffffffffc0200c8c:	fc1e                	sd	t2,56(sp)
ffffffffc0200c8e:	e0a2                	sd	s0,64(sp)
ffffffffc0200c90:	e4a6                	sd	s1,72(sp)
ffffffffc0200c92:	e8aa                	sd	a0,80(sp)
ffffffffc0200c94:	ecae                	sd	a1,88(sp)
ffffffffc0200c96:	f0b2                	sd	a2,96(sp)
ffffffffc0200c98:	f4b6                	sd	a3,104(sp)
ffffffffc0200c9a:	f8ba                	sd	a4,112(sp)
ffffffffc0200c9c:	fcbe                	sd	a5,120(sp)
ffffffffc0200c9e:	e142                	sd	a6,128(sp)
ffffffffc0200ca0:	e546                	sd	a7,136(sp)
ffffffffc0200ca2:	e94a                	sd	s2,144(sp)
ffffffffc0200ca4:	ed4e                	sd	s3,152(sp)
ffffffffc0200ca6:	f152                	sd	s4,160(sp)
ffffffffc0200ca8:	f556                	sd	s5,168(sp)
ffffffffc0200caa:	f95a                	sd	s6,176(sp)
ffffffffc0200cac:	fd5e                	sd	s7,184(sp)
ffffffffc0200cae:	e1e2                	sd	s8,192(sp)
ffffffffc0200cb0:	e5e6                	sd	s9,200(sp)
ffffffffc0200cb2:	e9ea                	sd	s10,208(sp)
ffffffffc0200cb4:	edee                	sd	s11,216(sp)
ffffffffc0200cb6:	f1f2                	sd	t3,224(sp)
ffffffffc0200cb8:	f5f6                	sd	t4,232(sp)
ffffffffc0200cba:	f9fa                	sd	t5,240(sp)
ffffffffc0200cbc:	fdfe                	sd	t6,248(sp)
ffffffffc0200cbe:	14002473          	csrr	s0,sscratch
ffffffffc0200cc2:	100024f3          	csrr	s1,sstatus
ffffffffc0200cc6:	14102973          	csrr	s2,sepc
ffffffffc0200cca:	143029f3          	csrr	s3,stval
ffffffffc0200cce:	14202a73          	csrr	s4,scause
ffffffffc0200cd2:	e822                	sd	s0,16(sp)
ffffffffc0200cd4:	e226                	sd	s1,256(sp)
ffffffffc0200cd6:	e64a                	sd	s2,264(sp)
ffffffffc0200cd8:	ea4e                	sd	s3,272(sp)
ffffffffc0200cda:	ee52                	sd	s4,280(sp)

    // 设置C函数trap的参数（陷阱帧指针）
    move  a0, sp
ffffffffc0200cdc:	850a                	mv	a0,sp
    // 调用C语言陷阱处理函数
    jal trap
ffffffffc0200cde:	f93ff0ef          	jal	ffffffffc0200c70 <trap>

ffffffffc0200ce2 <__trapret>:

    // 全局陷阱返回点
    .globl __trapret
__trapret:
    // 从栈中恢复所有寄存器
    RESTORE_ALL
ffffffffc0200ce2:	6492                	ld	s1,256(sp)
ffffffffc0200ce4:	6932                	ld	s2,264(sp)
ffffffffc0200ce6:	10049073          	csrw	sstatus,s1
ffffffffc0200cea:	14191073          	csrw	sepc,s2
ffffffffc0200cee:	60a2                	ld	ra,8(sp)
ffffffffc0200cf0:	61e2                	ld	gp,24(sp)
ffffffffc0200cf2:	7202                	ld	tp,32(sp)
ffffffffc0200cf4:	72a2                	ld	t0,40(sp)
ffffffffc0200cf6:	7342                	ld	t1,48(sp)
ffffffffc0200cf8:	73e2                	ld	t2,56(sp)
ffffffffc0200cfa:	6406                	ld	s0,64(sp)
ffffffffc0200cfc:	64a6                	ld	s1,72(sp)
ffffffffc0200cfe:	6546                	ld	a0,80(sp)
ffffffffc0200d00:	65e6                	ld	a1,88(sp)
ffffffffc0200d02:	7606                	ld	a2,96(sp)
ffffffffc0200d04:	76a6                	ld	a3,104(sp)
ffffffffc0200d06:	7746                	ld	a4,112(sp)
ffffffffc0200d08:	77e6                	ld	a5,120(sp)
ffffffffc0200d0a:	680a                	ld	a6,128(sp)
ffffffffc0200d0c:	68aa                	ld	a7,136(sp)
ffffffffc0200d0e:	694a                	ld	s2,144(sp)
ffffffffc0200d10:	69ea                	ld	s3,152(sp)
ffffffffc0200d12:	7a0a                	ld	s4,160(sp)
ffffffffc0200d14:	7aaa                	ld	s5,168(sp)
ffffffffc0200d16:	7b4a                	ld	s6,176(sp)
ffffffffc0200d18:	7bea                	ld	s7,184(sp)
ffffffffc0200d1a:	6c0e                	ld	s8,192(sp)
ffffffffc0200d1c:	6cae                	ld	s9,200(sp)
ffffffffc0200d1e:	6d4e                	ld	s10,208(sp)
ffffffffc0200d20:	6dee                	ld	s11,216(sp)
ffffffffc0200d22:	7e0e                	ld	t3,224(sp)
ffffffffc0200d24:	7eae                	ld	t4,232(sp)
ffffffffc0200d26:	7f4e                	ld	t5,240(sp)
ffffffffc0200d28:	7fee                	ld	t6,248(sp)
ffffffffc0200d2a:	6142                	ld	sp,16(sp)
    // 从监管者模式返回到发生异常/中断的代码位置
    # go back from supervisor call
    sret
ffffffffc0200d2c:	10200073          	sret

ffffffffc0200d30 <forkrets>:
    // 全局fork返回点（用于新创建进程的第一次执行）
    .globl forkrets
forkrets:
    // 设置栈指针为新进程的陷阱帧地址（参数a0）
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d30:	812a                	mv	sp,a0
    // 跳转到陷阱返回代码
ffffffffc0200d32:	bf45                	j	ffffffffc0200ce2 <__trapret>
ffffffffc0200d34:	0001                	nop

ffffffffc0200d36 <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200d36:	00008797          	auipc	a5,0x8
ffffffffc0200d3a:	6fa78793          	addi	a5,a5,1786 # ffffffffc0209430 <free_area>
ffffffffc0200d3e:	e79c                	sd	a5,8(a5)
ffffffffc0200d40:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200d42:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200d46:	8082                	ret

ffffffffc0200d48 <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200d48:	00008517          	auipc	a0,0x8
ffffffffc0200d4c:	6f856503          	lwu	a0,1784(a0) # ffffffffc0209440 <free_area+0x10>
ffffffffc0200d50:	8082                	ret

ffffffffc0200d52 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200d52:	c145                	beqz	a0,ffffffffc0200df2 <best_fit_alloc_pages+0xa0>
    if (n > nr_free) {
ffffffffc0200d54:	00008817          	auipc	a6,0x8
ffffffffc0200d58:	6ec82803          	lw	a6,1772(a6) # ffffffffc0209440 <free_area+0x10>
ffffffffc0200d5c:	85aa                	mv	a1,a0
ffffffffc0200d5e:	00008617          	auipc	a2,0x8
ffffffffc0200d62:	6d260613          	addi	a2,a2,1746 # ffffffffc0209430 <free_area>
ffffffffc0200d66:	02081793          	slli	a5,a6,0x20
ffffffffc0200d6a:	9381                	srli	a5,a5,0x20
ffffffffc0200d6c:	08a7e163          	bltu	a5,a0,ffffffffc0200dee <best_fit_alloc_pages+0x9c>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200d70:	661c                	ld	a5,8(a2)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d72:	06c78e63          	beq	a5,a2,ffffffffc0200dee <best_fit_alloc_pages+0x9c>
    size_t min_size = nr_free + 1;
ffffffffc0200d76:	0018069b          	addiw	a3,a6,1
ffffffffc0200d7a:	1682                	slli	a3,a3,0x20
ffffffffc0200d7c:	9281                	srli	a3,a3,0x20
    struct Page *page = NULL;
ffffffffc0200d7e:	4501                	li	a0,0
        if (p->property >= n && p->property < min_size) {
ffffffffc0200d80:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200d84:	00d77763          	bgeu	a4,a3,ffffffffc0200d92 <best_fit_alloc_pages+0x40>
ffffffffc0200d88:	00b76563          	bltu	a4,a1,ffffffffc0200d92 <best_fit_alloc_pages+0x40>
            min_size = p->property;
ffffffffc0200d8c:	86ba                	mv	a3,a4
        struct Page *p = le2page(le, page_link);
ffffffffc0200d8e:	fe878513          	addi	a0,a5,-24
ffffffffc0200d92:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d94:	fec796e3          	bne	a5,a2,ffffffffc0200d80 <best_fit_alloc_pages+0x2e>
    if (page != NULL) {
ffffffffc0200d98:	cd21                	beqz	a0,ffffffffc0200df0 <best_fit_alloc_pages+0x9e>
        if (page->property > n) {
ffffffffc0200d9a:	4914                	lw	a3,16(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc0200d9c:	6d18                	ld	a4,24(a0)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200d9e:	711c                	ld	a5,32(a0)
ffffffffc0200da0:	02069893          	slli	a7,a3,0x20
ffffffffc0200da4:	0208d893          	srli	a7,a7,0x20
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200da8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200daa:	e398                	sd	a4,0(a5)
ffffffffc0200dac:	0315f763          	bgeu	a1,a7,ffffffffc0200dda <best_fit_alloc_pages+0x88>
            struct Page *p = page + n;
ffffffffc0200db0:	00659793          	slli	a5,a1,0x6
            p->property = page->property - n;
ffffffffc0200db4:	9e8d                	subw	a3,a3,a1
            struct Page *p = page + n;
ffffffffc0200db6:	97aa                	add	a5,a5,a0
            p->property = page->property - n;
ffffffffc0200db8:	cb94                	sw	a3,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200dba:	00878813          	addi	a6,a5,8
ffffffffc0200dbe:	4689                	li	a3,2
ffffffffc0200dc0:	40d8302f          	amoor.d	zero,a3,(a6)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200dc4:	6714                	ld	a3,8(a4)
            list_add(prev, &(p->page_link));
ffffffffc0200dc6:	01878893          	addi	a7,a5,24
        nr_free -= n;
ffffffffc0200dca:	01062803          	lw	a6,16(a2)
    prev->next = next->prev = elm;
ffffffffc0200dce:	0116b023          	sd	a7,0(a3)
ffffffffc0200dd2:	01173423          	sd	a7,8(a4)
    elm->next = next;
ffffffffc0200dd6:	f394                	sd	a3,32(a5)
    elm->prev = prev;
ffffffffc0200dd8:	ef98                	sd	a4,24(a5)
ffffffffc0200dda:	40b8083b          	subw	a6,a6,a1
ffffffffc0200dde:	01062823          	sw	a6,16(a2)
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200de2:	57f5                	li	a5,-3
ffffffffc0200de4:	00850713          	addi	a4,a0,8
ffffffffc0200de8:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200dec:	8082                	ret
        return NULL;
ffffffffc0200dee:	4501                	li	a0,0
}
ffffffffc0200df0:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc0200df2:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200df4:	00004697          	auipc	a3,0x4
ffffffffc0200df8:	95468693          	addi	a3,a3,-1708 # ffffffffc0204748 <etext+0x9c0>
ffffffffc0200dfc:	00004617          	auipc	a2,0x4
ffffffffc0200e00:	95460613          	addi	a2,a2,-1708 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0200e04:	06b00593          	li	a1,107
ffffffffc0200e08:	00004517          	auipc	a0,0x4
ffffffffc0200e0c:	96050513          	addi	a0,a0,-1696 # ffffffffc0204768 <etext+0x9e0>
best_fit_alloc_pages(size_t n) {
ffffffffc0200e10:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200e12:	df4ff0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0200e16 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc0200e16:	711d                	addi	sp,sp,-96
ffffffffc0200e18:	e0ca                	sd	s2,64(sp)
    return listelm->next;
ffffffffc0200e1a:	00008917          	auipc	s2,0x8
ffffffffc0200e1e:	61690913          	addi	s2,s2,1558 # ffffffffc0209430 <free_area>
ffffffffc0200e22:	00893783          	ld	a5,8(s2)
ffffffffc0200e26:	ec86                	sd	ra,88(sp)
ffffffffc0200e28:	e8a2                	sd	s0,80(sp)
ffffffffc0200e2a:	e4a6                	sd	s1,72(sp)
ffffffffc0200e2c:	fc4e                	sd	s3,56(sp)
ffffffffc0200e2e:	f852                	sd	s4,48(sp)
ffffffffc0200e30:	f456                	sd	s5,40(sp)
ffffffffc0200e32:	f05a                	sd	s6,32(sp)
ffffffffc0200e34:	ec5e                	sd	s7,24(sp)
ffffffffc0200e36:	e862                	sd	s8,16(sp)
ffffffffc0200e38:	e466                	sd	s9,8(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e3a:	29278d63          	beq	a5,s2,ffffffffc02010d4 <best_fit_check+0x2be>
    int count = 0, total = 0;
ffffffffc0200e3e:	4401                	li	s0,0
ffffffffc0200e40:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e42:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e46:	8b09                	andi	a4,a4,2
ffffffffc0200e48:	28070a63          	beqz	a4,ffffffffc02010dc <best_fit_check+0x2c6>
        count ++, total += p->property;
ffffffffc0200e4c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e50:	679c                	ld	a5,8(a5)
ffffffffc0200e52:	2485                	addiw	s1,s1,1
ffffffffc0200e54:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e56:	ff2796e3          	bne	a5,s2,ffffffffc0200e42 <best_fit_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0200e5a:	89a2                	mv	s3,s0
ffffffffc0200e5c:	5b9000ef          	jal	ffffffffc0201c14 <nr_free_pages>
ffffffffc0200e60:	35351e63          	bne	a0,s3,ffffffffc02011bc <best_fit_check+0x3a6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e64:	4505                	li	a0,1
ffffffffc0200e66:	53d000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200e6a:	8a2a                	mv	s4,a0
ffffffffc0200e6c:	38050863          	beqz	a0,ffffffffc02011fc <best_fit_check+0x3e6>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e70:	4505                	li	a0,1
ffffffffc0200e72:	531000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200e76:	89aa                	mv	s3,a0
ffffffffc0200e78:	36050263          	beqz	a0,ffffffffc02011dc <best_fit_check+0x3c6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e7c:	4505                	li	a0,1
ffffffffc0200e7e:	525000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200e82:	8aaa                	mv	s5,a0
ffffffffc0200e84:	2e050c63          	beqz	a0,ffffffffc020117c <best_fit_check+0x366>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e88:	40aa07b3          	sub	a5,s4,a0
ffffffffc0200e8c:	40a98733          	sub	a4,s3,a0
ffffffffc0200e90:	0017b793          	seqz	a5,a5
ffffffffc0200e94:	00173713          	seqz	a4,a4
ffffffffc0200e98:	8fd9                	or	a5,a5,a4
ffffffffc0200e9a:	2c079163          	bnez	a5,ffffffffc020115c <best_fit_check+0x346>
ffffffffc0200e9e:	2b3a0f63          	beq	s4,s3,ffffffffc020115c <best_fit_check+0x346>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ea2:	000a2783          	lw	a5,0(s4)
ffffffffc0200ea6:	24079b63          	bnez	a5,ffffffffc02010fc <best_fit_check+0x2e6>
ffffffffc0200eaa:	0009a783          	lw	a5,0(s3)
ffffffffc0200eae:	24079763          	bnez	a5,ffffffffc02010fc <best_fit_check+0x2e6>
ffffffffc0200eb2:	411c                	lw	a5,0(a0)
ffffffffc0200eb4:	24079463          	bnez	a5,ffffffffc02010fc <best_fit_check+0x2e6>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0200eb8:	0000c797          	auipc	a5,0xc
ffffffffc0200ebc:	6107b783          	ld	a5,1552(a5) # ffffffffc020d4c8 <pages>
ffffffffc0200ec0:	00005617          	auipc	a2,0x5
ffffffffc0200ec4:	9a063603          	ld	a2,-1632(a2) # ffffffffc0205860 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ec8:	0000c697          	auipc	a3,0xc
ffffffffc0200ecc:	5f86b683          	ld	a3,1528(a3) # ffffffffc020d4c0 <npage>
ffffffffc0200ed0:	40fa0733          	sub	a4,s4,a5
ffffffffc0200ed4:	8719                	srai	a4,a4,0x6
ffffffffc0200ed6:	9732                	add	a4,a4,a2
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ed8:	0732                	slli	a4,a4,0xc
ffffffffc0200eda:	06b2                	slli	a3,a3,0xc
ffffffffc0200edc:	26d77063          	bgeu	a4,a3,ffffffffc020113c <best_fit_check+0x326>
    return page - pages + nbase;
ffffffffc0200ee0:	40f98733          	sub	a4,s3,a5
ffffffffc0200ee4:	8719                	srai	a4,a4,0x6
ffffffffc0200ee6:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ee8:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200eea:	40d77963          	bgeu	a4,a3,ffffffffc02012fc <best_fit_check+0x4e6>
    return page - pages + nbase;
ffffffffc0200eee:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ef2:	8799                	srai	a5,a5,0x6
ffffffffc0200ef4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ef6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ef8:	3ed7f263          	bgeu	a5,a3,ffffffffc02012dc <best_fit_check+0x4c6>
    assert(alloc_page() == NULL);
ffffffffc0200efc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200efe:	00093c03          	ld	s8,0(s2)
ffffffffc0200f02:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f06:	00008b17          	auipc	s6,0x8
ffffffffc0200f0a:	53ab2b03          	lw	s6,1338(s6) # ffffffffc0209440 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0200f0e:	01293023          	sd	s2,0(s2)
ffffffffc0200f12:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc0200f16:	00008797          	auipc	a5,0x8
ffffffffc0200f1a:	5207a523          	sw	zero,1322(a5) # ffffffffc0209440 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f1e:	485000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200f22:	38051d63          	bnez	a0,ffffffffc02012bc <best_fit_check+0x4a6>
    free_page(p0);
ffffffffc0200f26:	8552                	mv	a0,s4
ffffffffc0200f28:	4585                	li	a1,1
ffffffffc0200f2a:	4b3000ef          	jal	ffffffffc0201bdc <free_pages>
    free_page(p1);
ffffffffc0200f2e:	854e                	mv	a0,s3
ffffffffc0200f30:	4585                	li	a1,1
ffffffffc0200f32:	4ab000ef          	jal	ffffffffc0201bdc <free_pages>
    free_page(p2);
ffffffffc0200f36:	8556                	mv	a0,s5
ffffffffc0200f38:	4585                	li	a1,1
ffffffffc0200f3a:	4a3000ef          	jal	ffffffffc0201bdc <free_pages>
    assert(nr_free == 3);
ffffffffc0200f3e:	00008717          	auipc	a4,0x8
ffffffffc0200f42:	50272703          	lw	a4,1282(a4) # ffffffffc0209440 <free_area+0x10>
ffffffffc0200f46:	478d                	li	a5,3
ffffffffc0200f48:	34f71a63          	bne	a4,a5,ffffffffc020129c <best_fit_check+0x486>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f4c:	4505                	li	a0,1
ffffffffc0200f4e:	455000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200f52:	89aa                	mv	s3,a0
ffffffffc0200f54:	32050463          	beqz	a0,ffffffffc020127c <best_fit_check+0x466>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f58:	4505                	li	a0,1
ffffffffc0200f5a:	449000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200f5e:	8aaa                	mv	s5,a0
ffffffffc0200f60:	2e050e63          	beqz	a0,ffffffffc020125c <best_fit_check+0x446>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f64:	4505                	li	a0,1
ffffffffc0200f66:	43d000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200f6a:	8a2a                	mv	s4,a0
ffffffffc0200f6c:	2c050863          	beqz	a0,ffffffffc020123c <best_fit_check+0x426>
    assert(alloc_page() == NULL);
ffffffffc0200f70:	4505                	li	a0,1
ffffffffc0200f72:	431000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200f76:	2a051363          	bnez	a0,ffffffffc020121c <best_fit_check+0x406>
    free_page(p0);
ffffffffc0200f7a:	4585                	li	a1,1
ffffffffc0200f7c:	854e                	mv	a0,s3
ffffffffc0200f7e:	45f000ef          	jal	ffffffffc0201bdc <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200f82:	00893783          	ld	a5,8(s2)
ffffffffc0200f86:	19278b63          	beq	a5,s2,ffffffffc020111c <best_fit_check+0x306>
    assert((p = alloc_page()) == p0);
ffffffffc0200f8a:	4505                	li	a0,1
ffffffffc0200f8c:	417000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200f90:	8caa                	mv	s9,a0
ffffffffc0200f92:	54a99563          	bne	s3,a0,ffffffffc02014dc <best_fit_check+0x6c6>
    assert(alloc_page() == NULL);
ffffffffc0200f96:	4505                	li	a0,1
ffffffffc0200f98:	40b000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200f9c:	52051063          	bnez	a0,ffffffffc02014bc <best_fit_check+0x6a6>
    assert(nr_free == 0);
ffffffffc0200fa0:	00008797          	auipc	a5,0x8
ffffffffc0200fa4:	4a07a783          	lw	a5,1184(a5) # ffffffffc0209440 <free_area+0x10>
ffffffffc0200fa8:	4e079a63          	bnez	a5,ffffffffc020149c <best_fit_check+0x686>
    free_page(p);
ffffffffc0200fac:	8566                	mv	a0,s9
ffffffffc0200fae:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200fb0:	01893023          	sd	s8,0(s2)
ffffffffc0200fb4:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0200fb8:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0200fbc:	421000ef          	jal	ffffffffc0201bdc <free_pages>
    free_page(p1);
ffffffffc0200fc0:	8556                	mv	a0,s5
ffffffffc0200fc2:	4585                	li	a1,1
ffffffffc0200fc4:	419000ef          	jal	ffffffffc0201bdc <free_pages>
    free_page(p2);
ffffffffc0200fc8:	8552                	mv	a0,s4
ffffffffc0200fca:	4585                	li	a1,1
ffffffffc0200fcc:	411000ef          	jal	ffffffffc0201bdc <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200fd0:	4515                	li	a0,5
ffffffffc0200fd2:	3d1000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200fd6:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200fd8:	4a050263          	beqz	a0,ffffffffc020147c <best_fit_check+0x666>
ffffffffc0200fdc:	651c                	ld	a5,8(a0)
ffffffffc0200fde:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200fe0:	8b85                	andi	a5,a5,1
ffffffffc0200fe2:	46079d63          	bnez	a5,ffffffffc020145c <best_fit_check+0x646>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200fe6:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fe8:	00093b03          	ld	s6,0(s2)
ffffffffc0200fec:	00893a83          	ld	s5,8(s2)
ffffffffc0200ff0:	01293023          	sd	s2,0(s2)
ffffffffc0200ff4:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc0200ff8:	3ab000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0200ffc:	44051063          	bnez	a0,ffffffffc020143c <best_fit_check+0x626>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0201000:	4589                	li	a1,2
ffffffffc0201002:	04098513          	addi	a0,s3,64
    unsigned int nr_free_store = nr_free;
ffffffffc0201006:	00008b97          	auipc	s7,0x8
ffffffffc020100a:	43abab83          	lw	s7,1082(s7) # ffffffffc0209440 <free_area+0x10>
    free_pages(p0 + 4, 1);
ffffffffc020100e:	10098c13          	addi	s8,s3,256
    nr_free = 0;
ffffffffc0201012:	00008797          	auipc	a5,0x8
ffffffffc0201016:	4207a723          	sw	zero,1070(a5) # ffffffffc0209440 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc020101a:	3c3000ef          	jal	ffffffffc0201bdc <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc020101e:	8562                	mv	a0,s8
ffffffffc0201020:	4585                	li	a1,1
ffffffffc0201022:	3bb000ef          	jal	ffffffffc0201bdc <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201026:	4511                	li	a0,4
ffffffffc0201028:	37b000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc020102c:	3e051863          	bnez	a0,ffffffffc020141c <best_fit_check+0x606>
ffffffffc0201030:	0489b783          	ld	a5,72(s3)
ffffffffc0201034:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0201036:	8b85                	andi	a5,a5,1
ffffffffc0201038:	3c078263          	beqz	a5,ffffffffc02013fc <best_fit_check+0x5e6>
ffffffffc020103c:	0509ac83          	lw	s9,80(s3)
ffffffffc0201040:	4789                	li	a5,2
ffffffffc0201042:	3afc9d63          	bne	s9,a5,ffffffffc02013fc <best_fit_check+0x5e6>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0201046:	4505                	li	a0,1
ffffffffc0201048:	35b000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc020104c:	8a2a                	mv	s4,a0
ffffffffc020104e:	38050763          	beqz	a0,ffffffffc02013dc <best_fit_check+0x5c6>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0201052:	8566                	mv	a0,s9
ffffffffc0201054:	34f000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc0201058:	36050263          	beqz	a0,ffffffffc02013bc <best_fit_check+0x5a6>
    assert(p0 + 4 == p1);
ffffffffc020105c:	354c1063          	bne	s8,s4,ffffffffc020139c <best_fit_check+0x586>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0201060:	854e                	mv	a0,s3
ffffffffc0201062:	4595                	li	a1,5
ffffffffc0201064:	379000ef          	jal	ffffffffc0201bdc <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201068:	4515                	li	a0,5
ffffffffc020106a:	339000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc020106e:	89aa                	mv	s3,a0
ffffffffc0201070:	30050663          	beqz	a0,ffffffffc020137c <best_fit_check+0x566>
    assert(alloc_page() == NULL);
ffffffffc0201074:	4505                	li	a0,1
ffffffffc0201076:	32d000ef          	jal	ffffffffc0201ba2 <alloc_pages>
ffffffffc020107a:	2e051163          	bnez	a0,ffffffffc020135c <best_fit_check+0x546>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc020107e:	00008797          	auipc	a5,0x8
ffffffffc0201082:	3c27a783          	lw	a5,962(a5) # ffffffffc0209440 <free_area+0x10>
ffffffffc0201086:	2a079b63          	bnez	a5,ffffffffc020133c <best_fit_check+0x526>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020108a:	854e                	mv	a0,s3
ffffffffc020108c:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc020108e:	01792823          	sw	s7,16(s2)
    free_list = free_list_store;
ffffffffc0201092:	01693023          	sd	s6,0(s2)
ffffffffc0201096:	01593423          	sd	s5,8(s2)
    free_pages(p0, 5);
ffffffffc020109a:	343000ef          	jal	ffffffffc0201bdc <free_pages>
    return listelm->next;
ffffffffc020109e:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010a2:	01278963          	beq	a5,s2,ffffffffc02010b4 <best_fit_check+0x29e>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc02010a6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02010aa:	679c                	ld	a5,8(a5)
ffffffffc02010ac:	34fd                	addiw	s1,s1,-1
ffffffffc02010ae:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010b0:	ff279be3          	bne	a5,s2,ffffffffc02010a6 <best_fit_check+0x290>
    }
    assert(count == 0);
ffffffffc02010b4:	26049463          	bnez	s1,ffffffffc020131c <best_fit_check+0x506>
    assert(total == 0);
ffffffffc02010b8:	e075                	bnez	s0,ffffffffc020119c <best_fit_check+0x386>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc02010ba:	60e6                	ld	ra,88(sp)
ffffffffc02010bc:	6446                	ld	s0,80(sp)
ffffffffc02010be:	64a6                	ld	s1,72(sp)
ffffffffc02010c0:	6906                	ld	s2,64(sp)
ffffffffc02010c2:	79e2                	ld	s3,56(sp)
ffffffffc02010c4:	7a42                	ld	s4,48(sp)
ffffffffc02010c6:	7aa2                	ld	s5,40(sp)
ffffffffc02010c8:	7b02                	ld	s6,32(sp)
ffffffffc02010ca:	6be2                	ld	s7,24(sp)
ffffffffc02010cc:	6c42                	ld	s8,16(sp)
ffffffffc02010ce:	6ca2                	ld	s9,8(sp)
ffffffffc02010d0:	6125                	addi	sp,sp,96
ffffffffc02010d2:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02010d4:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02010d6:	4401                	li	s0,0
ffffffffc02010d8:	4481                	li	s1,0
ffffffffc02010da:	b349                	j	ffffffffc0200e5c <best_fit_check+0x46>
        assert(PageProperty(p));
ffffffffc02010dc:	00003697          	auipc	a3,0x3
ffffffffc02010e0:	6a468693          	addi	a3,a3,1700 # ffffffffc0204780 <etext+0x9f8>
ffffffffc02010e4:	00003617          	auipc	a2,0x3
ffffffffc02010e8:	66c60613          	addi	a2,a2,1644 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02010ec:	10a00593          	li	a1,266
ffffffffc02010f0:	00003517          	auipc	a0,0x3
ffffffffc02010f4:	67850513          	addi	a0,a0,1656 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02010f8:	b0eff0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02010fc:	00003697          	auipc	a3,0x3
ffffffffc0201100:	73c68693          	addi	a3,a3,1852 # ffffffffc0204838 <etext+0xab0>
ffffffffc0201104:	00003617          	auipc	a2,0x3
ffffffffc0201108:	64c60613          	addi	a2,a2,1612 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020110c:	0d700593          	li	a1,215
ffffffffc0201110:	00003517          	auipc	a0,0x3
ffffffffc0201114:	65850513          	addi	a0,a0,1624 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201118:	aeeff0ef          	jal	ffffffffc0200406 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020111c:	00003697          	auipc	a3,0x3
ffffffffc0201120:	7e468693          	addi	a3,a3,2020 # ffffffffc0204900 <etext+0xb78>
ffffffffc0201124:	00003617          	auipc	a2,0x3
ffffffffc0201128:	62c60613          	addi	a2,a2,1580 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020112c:	0f200593          	li	a1,242
ffffffffc0201130:	00003517          	auipc	a0,0x3
ffffffffc0201134:	63850513          	addi	a0,a0,1592 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201138:	aceff0ef          	jal	ffffffffc0200406 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc020113c:	00003697          	auipc	a3,0x3
ffffffffc0201140:	73c68693          	addi	a3,a3,1852 # ffffffffc0204878 <etext+0xaf0>
ffffffffc0201144:	00003617          	auipc	a2,0x3
ffffffffc0201148:	60c60613          	addi	a2,a2,1548 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020114c:	0d900593          	li	a1,217
ffffffffc0201150:	00003517          	auipc	a0,0x3
ffffffffc0201154:	61850513          	addi	a0,a0,1560 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201158:	aaeff0ef          	jal	ffffffffc0200406 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020115c:	00003697          	auipc	a3,0x3
ffffffffc0201160:	6b468693          	addi	a3,a3,1716 # ffffffffc0204810 <etext+0xa88>
ffffffffc0201164:	00003617          	auipc	a2,0x3
ffffffffc0201168:	5ec60613          	addi	a2,a2,1516 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020116c:	0d600593          	li	a1,214
ffffffffc0201170:	00003517          	auipc	a0,0x3
ffffffffc0201174:	5f850513          	addi	a0,a0,1528 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201178:	a8eff0ef          	jal	ffffffffc0200406 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020117c:	00003697          	auipc	a3,0x3
ffffffffc0201180:	67468693          	addi	a3,a3,1652 # ffffffffc02047f0 <etext+0xa68>
ffffffffc0201184:	00003617          	auipc	a2,0x3
ffffffffc0201188:	5cc60613          	addi	a2,a2,1484 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020118c:	0d400593          	li	a1,212
ffffffffc0201190:	00003517          	auipc	a0,0x3
ffffffffc0201194:	5d850513          	addi	a0,a0,1496 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201198:	a6eff0ef          	jal	ffffffffc0200406 <__panic>
    assert(total == 0);
ffffffffc020119c:	00004697          	auipc	a3,0x4
ffffffffc02011a0:	89468693          	addi	a3,a3,-1900 # ffffffffc0204a30 <etext+0xca8>
ffffffffc02011a4:	00003617          	auipc	a2,0x3
ffffffffc02011a8:	5ac60613          	addi	a2,a2,1452 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02011ac:	14c00593          	li	a1,332
ffffffffc02011b0:	00003517          	auipc	a0,0x3
ffffffffc02011b4:	5b850513          	addi	a0,a0,1464 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02011b8:	a4eff0ef          	jal	ffffffffc0200406 <__panic>
    assert(total == nr_free_pages());
ffffffffc02011bc:	00003697          	auipc	a3,0x3
ffffffffc02011c0:	5d468693          	addi	a3,a3,1492 # ffffffffc0204790 <etext+0xa08>
ffffffffc02011c4:	00003617          	auipc	a2,0x3
ffffffffc02011c8:	58c60613          	addi	a2,a2,1420 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02011cc:	10d00593          	li	a1,269
ffffffffc02011d0:	00003517          	auipc	a0,0x3
ffffffffc02011d4:	59850513          	addi	a0,a0,1432 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02011d8:	a2eff0ef          	jal	ffffffffc0200406 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02011dc:	00003697          	auipc	a3,0x3
ffffffffc02011e0:	5f468693          	addi	a3,a3,1524 # ffffffffc02047d0 <etext+0xa48>
ffffffffc02011e4:	00003617          	auipc	a2,0x3
ffffffffc02011e8:	56c60613          	addi	a2,a2,1388 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02011ec:	0d300593          	li	a1,211
ffffffffc02011f0:	00003517          	auipc	a0,0x3
ffffffffc02011f4:	57850513          	addi	a0,a0,1400 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02011f8:	a0eff0ef          	jal	ffffffffc0200406 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011fc:	00003697          	auipc	a3,0x3
ffffffffc0201200:	5b468693          	addi	a3,a3,1460 # ffffffffc02047b0 <etext+0xa28>
ffffffffc0201204:	00003617          	auipc	a2,0x3
ffffffffc0201208:	54c60613          	addi	a2,a2,1356 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020120c:	0d200593          	li	a1,210
ffffffffc0201210:	00003517          	auipc	a0,0x3
ffffffffc0201214:	55850513          	addi	a0,a0,1368 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201218:	9eeff0ef          	jal	ffffffffc0200406 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020121c:	00003697          	auipc	a3,0x3
ffffffffc0201220:	6bc68693          	addi	a3,a3,1724 # ffffffffc02048d8 <etext+0xb50>
ffffffffc0201224:	00003617          	auipc	a2,0x3
ffffffffc0201228:	52c60613          	addi	a2,a2,1324 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020122c:	0ef00593          	li	a1,239
ffffffffc0201230:	00003517          	auipc	a0,0x3
ffffffffc0201234:	53850513          	addi	a0,a0,1336 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201238:	9ceff0ef          	jal	ffffffffc0200406 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020123c:	00003697          	auipc	a3,0x3
ffffffffc0201240:	5b468693          	addi	a3,a3,1460 # ffffffffc02047f0 <etext+0xa68>
ffffffffc0201244:	00003617          	auipc	a2,0x3
ffffffffc0201248:	50c60613          	addi	a2,a2,1292 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020124c:	0ed00593          	li	a1,237
ffffffffc0201250:	00003517          	auipc	a0,0x3
ffffffffc0201254:	51850513          	addi	a0,a0,1304 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201258:	9aeff0ef          	jal	ffffffffc0200406 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020125c:	00003697          	auipc	a3,0x3
ffffffffc0201260:	57468693          	addi	a3,a3,1396 # ffffffffc02047d0 <etext+0xa48>
ffffffffc0201264:	00003617          	auipc	a2,0x3
ffffffffc0201268:	4ec60613          	addi	a2,a2,1260 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020126c:	0ec00593          	li	a1,236
ffffffffc0201270:	00003517          	auipc	a0,0x3
ffffffffc0201274:	4f850513          	addi	a0,a0,1272 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201278:	98eff0ef          	jal	ffffffffc0200406 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020127c:	00003697          	auipc	a3,0x3
ffffffffc0201280:	53468693          	addi	a3,a3,1332 # ffffffffc02047b0 <etext+0xa28>
ffffffffc0201284:	00003617          	auipc	a2,0x3
ffffffffc0201288:	4cc60613          	addi	a2,a2,1228 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020128c:	0eb00593          	li	a1,235
ffffffffc0201290:	00003517          	auipc	a0,0x3
ffffffffc0201294:	4d850513          	addi	a0,a0,1240 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201298:	96eff0ef          	jal	ffffffffc0200406 <__panic>
    assert(nr_free == 3);
ffffffffc020129c:	00003697          	auipc	a3,0x3
ffffffffc02012a0:	65468693          	addi	a3,a3,1620 # ffffffffc02048f0 <etext+0xb68>
ffffffffc02012a4:	00003617          	auipc	a2,0x3
ffffffffc02012a8:	4ac60613          	addi	a2,a2,1196 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02012ac:	0e900593          	li	a1,233
ffffffffc02012b0:	00003517          	auipc	a0,0x3
ffffffffc02012b4:	4b850513          	addi	a0,a0,1208 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02012b8:	94eff0ef          	jal	ffffffffc0200406 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012bc:	00003697          	auipc	a3,0x3
ffffffffc02012c0:	61c68693          	addi	a3,a3,1564 # ffffffffc02048d8 <etext+0xb50>
ffffffffc02012c4:	00003617          	auipc	a2,0x3
ffffffffc02012c8:	48c60613          	addi	a2,a2,1164 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02012cc:	0e400593          	li	a1,228
ffffffffc02012d0:	00003517          	auipc	a0,0x3
ffffffffc02012d4:	49850513          	addi	a0,a0,1176 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02012d8:	92eff0ef          	jal	ffffffffc0200406 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02012dc:	00003697          	auipc	a3,0x3
ffffffffc02012e0:	5dc68693          	addi	a3,a3,1500 # ffffffffc02048b8 <etext+0xb30>
ffffffffc02012e4:	00003617          	auipc	a2,0x3
ffffffffc02012e8:	46c60613          	addi	a2,a2,1132 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02012ec:	0db00593          	li	a1,219
ffffffffc02012f0:	00003517          	auipc	a0,0x3
ffffffffc02012f4:	47850513          	addi	a0,a0,1144 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02012f8:	90eff0ef          	jal	ffffffffc0200406 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02012fc:	00003697          	auipc	a3,0x3
ffffffffc0201300:	59c68693          	addi	a3,a3,1436 # ffffffffc0204898 <etext+0xb10>
ffffffffc0201304:	00003617          	auipc	a2,0x3
ffffffffc0201308:	44c60613          	addi	a2,a2,1100 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020130c:	0da00593          	li	a1,218
ffffffffc0201310:	00003517          	auipc	a0,0x3
ffffffffc0201314:	45850513          	addi	a0,a0,1112 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201318:	8eeff0ef          	jal	ffffffffc0200406 <__panic>
    assert(count == 0);
ffffffffc020131c:	00003697          	auipc	a3,0x3
ffffffffc0201320:	70468693          	addi	a3,a3,1796 # ffffffffc0204a20 <etext+0xc98>
ffffffffc0201324:	00003617          	auipc	a2,0x3
ffffffffc0201328:	42c60613          	addi	a2,a2,1068 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020132c:	14b00593          	li	a1,331
ffffffffc0201330:	00003517          	auipc	a0,0x3
ffffffffc0201334:	43850513          	addi	a0,a0,1080 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201338:	8ceff0ef          	jal	ffffffffc0200406 <__panic>
    assert(nr_free == 0);
ffffffffc020133c:	00003697          	auipc	a3,0x3
ffffffffc0201340:	5fc68693          	addi	a3,a3,1532 # ffffffffc0204938 <etext+0xbb0>
ffffffffc0201344:	00003617          	auipc	a2,0x3
ffffffffc0201348:	40c60613          	addi	a2,a2,1036 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020134c:	14000593          	li	a1,320
ffffffffc0201350:	00003517          	auipc	a0,0x3
ffffffffc0201354:	41850513          	addi	a0,a0,1048 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201358:	8aeff0ef          	jal	ffffffffc0200406 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020135c:	00003697          	auipc	a3,0x3
ffffffffc0201360:	57c68693          	addi	a3,a3,1404 # ffffffffc02048d8 <etext+0xb50>
ffffffffc0201364:	00003617          	auipc	a2,0x3
ffffffffc0201368:	3ec60613          	addi	a2,a2,1004 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020136c:	13a00593          	li	a1,314
ffffffffc0201370:	00003517          	auipc	a0,0x3
ffffffffc0201374:	3f850513          	addi	a0,a0,1016 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201378:	88eff0ef          	jal	ffffffffc0200406 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020137c:	00003697          	auipc	a3,0x3
ffffffffc0201380:	68468693          	addi	a3,a3,1668 # ffffffffc0204a00 <etext+0xc78>
ffffffffc0201384:	00003617          	auipc	a2,0x3
ffffffffc0201388:	3cc60613          	addi	a2,a2,972 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020138c:	13900593          	li	a1,313
ffffffffc0201390:	00003517          	auipc	a0,0x3
ffffffffc0201394:	3d850513          	addi	a0,a0,984 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201398:	86eff0ef          	jal	ffffffffc0200406 <__panic>
    assert(p0 + 4 == p1);
ffffffffc020139c:	00003697          	auipc	a3,0x3
ffffffffc02013a0:	65468693          	addi	a3,a3,1620 # ffffffffc02049f0 <etext+0xc68>
ffffffffc02013a4:	00003617          	auipc	a2,0x3
ffffffffc02013a8:	3ac60613          	addi	a2,a2,940 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02013ac:	13100593          	li	a1,305
ffffffffc02013b0:	00003517          	auipc	a0,0x3
ffffffffc02013b4:	3b850513          	addi	a0,a0,952 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02013b8:	84eff0ef          	jal	ffffffffc0200406 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc02013bc:	00003697          	auipc	a3,0x3
ffffffffc02013c0:	61c68693          	addi	a3,a3,1564 # ffffffffc02049d8 <etext+0xc50>
ffffffffc02013c4:	00003617          	auipc	a2,0x3
ffffffffc02013c8:	38c60613          	addi	a2,a2,908 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02013cc:	13000593          	li	a1,304
ffffffffc02013d0:	00003517          	auipc	a0,0x3
ffffffffc02013d4:	39850513          	addi	a0,a0,920 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02013d8:	82eff0ef          	jal	ffffffffc0200406 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc02013dc:	00003697          	auipc	a3,0x3
ffffffffc02013e0:	5dc68693          	addi	a3,a3,1500 # ffffffffc02049b8 <etext+0xc30>
ffffffffc02013e4:	00003617          	auipc	a2,0x3
ffffffffc02013e8:	36c60613          	addi	a2,a2,876 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02013ec:	12f00593          	li	a1,303
ffffffffc02013f0:	00003517          	auipc	a0,0x3
ffffffffc02013f4:	37850513          	addi	a0,a0,888 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02013f8:	80eff0ef          	jal	ffffffffc0200406 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc02013fc:	00003697          	auipc	a3,0x3
ffffffffc0201400:	58c68693          	addi	a3,a3,1420 # ffffffffc0204988 <etext+0xc00>
ffffffffc0201404:	00003617          	auipc	a2,0x3
ffffffffc0201408:	34c60613          	addi	a2,a2,844 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020140c:	12d00593          	li	a1,301
ffffffffc0201410:	00003517          	auipc	a0,0x3
ffffffffc0201414:	35850513          	addi	a0,a0,856 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201418:	feffe0ef          	jal	ffffffffc0200406 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020141c:	00003697          	auipc	a3,0x3
ffffffffc0201420:	55468693          	addi	a3,a3,1364 # ffffffffc0204970 <etext+0xbe8>
ffffffffc0201424:	00003617          	auipc	a2,0x3
ffffffffc0201428:	32c60613          	addi	a2,a2,812 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020142c:	12c00593          	li	a1,300
ffffffffc0201430:	00003517          	auipc	a0,0x3
ffffffffc0201434:	33850513          	addi	a0,a0,824 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201438:	fcffe0ef          	jal	ffffffffc0200406 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020143c:	00003697          	auipc	a3,0x3
ffffffffc0201440:	49c68693          	addi	a3,a3,1180 # ffffffffc02048d8 <etext+0xb50>
ffffffffc0201444:	00003617          	auipc	a2,0x3
ffffffffc0201448:	30c60613          	addi	a2,a2,780 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020144c:	12000593          	li	a1,288
ffffffffc0201450:	00003517          	auipc	a0,0x3
ffffffffc0201454:	31850513          	addi	a0,a0,792 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201458:	faffe0ef          	jal	ffffffffc0200406 <__panic>
    assert(!PageProperty(p0));
ffffffffc020145c:	00003697          	auipc	a3,0x3
ffffffffc0201460:	4fc68693          	addi	a3,a3,1276 # ffffffffc0204958 <etext+0xbd0>
ffffffffc0201464:	00003617          	auipc	a2,0x3
ffffffffc0201468:	2ec60613          	addi	a2,a2,748 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020146c:	11700593          	li	a1,279
ffffffffc0201470:	00003517          	auipc	a0,0x3
ffffffffc0201474:	2f850513          	addi	a0,a0,760 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201478:	f8ffe0ef          	jal	ffffffffc0200406 <__panic>
    assert(p0 != NULL);
ffffffffc020147c:	00003697          	auipc	a3,0x3
ffffffffc0201480:	4cc68693          	addi	a3,a3,1228 # ffffffffc0204948 <etext+0xbc0>
ffffffffc0201484:	00003617          	auipc	a2,0x3
ffffffffc0201488:	2cc60613          	addi	a2,a2,716 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020148c:	11600593          	li	a1,278
ffffffffc0201490:	00003517          	auipc	a0,0x3
ffffffffc0201494:	2d850513          	addi	a0,a0,728 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201498:	f6ffe0ef          	jal	ffffffffc0200406 <__panic>
    assert(nr_free == 0);
ffffffffc020149c:	00003697          	auipc	a3,0x3
ffffffffc02014a0:	49c68693          	addi	a3,a3,1180 # ffffffffc0204938 <etext+0xbb0>
ffffffffc02014a4:	00003617          	auipc	a2,0x3
ffffffffc02014a8:	2ac60613          	addi	a2,a2,684 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02014ac:	0f800593          	li	a1,248
ffffffffc02014b0:	00003517          	auipc	a0,0x3
ffffffffc02014b4:	2b850513          	addi	a0,a0,696 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02014b8:	f4ffe0ef          	jal	ffffffffc0200406 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014bc:	00003697          	auipc	a3,0x3
ffffffffc02014c0:	41c68693          	addi	a3,a3,1052 # ffffffffc02048d8 <etext+0xb50>
ffffffffc02014c4:	00003617          	auipc	a2,0x3
ffffffffc02014c8:	28c60613          	addi	a2,a2,652 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02014cc:	0f600593          	li	a1,246
ffffffffc02014d0:	00003517          	auipc	a0,0x3
ffffffffc02014d4:	29850513          	addi	a0,a0,664 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02014d8:	f2ffe0ef          	jal	ffffffffc0200406 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02014dc:	00003697          	auipc	a3,0x3
ffffffffc02014e0:	43c68693          	addi	a3,a3,1084 # ffffffffc0204918 <etext+0xb90>
ffffffffc02014e4:	00003617          	auipc	a2,0x3
ffffffffc02014e8:	26c60613          	addi	a2,a2,620 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02014ec:	0f500593          	li	a1,245
ffffffffc02014f0:	00003517          	auipc	a0,0x3
ffffffffc02014f4:	27850513          	addi	a0,a0,632 # ffffffffc0204768 <etext+0x9e0>
ffffffffc02014f8:	f0ffe0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc02014fc <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc02014fc:	1141                	addi	sp,sp,-16
ffffffffc02014fe:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201500:	14058663          	beqz	a1,ffffffffc020164c <best_fit_free_pages+0x150>
    for (; p != base + n; p ++) {
ffffffffc0201504:	00659713          	slli	a4,a1,0x6
ffffffffc0201508:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc020150c:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc020150e:	c30d                	beqz	a4,ffffffffc0201530 <best_fit_free_pages+0x34>
ffffffffc0201510:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201512:	8b05                	andi	a4,a4,1
ffffffffc0201514:	10071c63          	bnez	a4,ffffffffc020162c <best_fit_free_pages+0x130>
ffffffffc0201518:	6798                	ld	a4,8(a5)
ffffffffc020151a:	8b09                	andi	a4,a4,2
ffffffffc020151c:	10071863          	bnez	a4,ffffffffc020162c <best_fit_free_pages+0x130>
        p->flags = 0;
ffffffffc0201520:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc0201524:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201528:	04078793          	addi	a5,a5,64
ffffffffc020152c:	fed792e3          	bne	a5,a3,ffffffffc0201510 <best_fit_free_pages+0x14>
    base->property = n;
ffffffffc0201530:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201532:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201536:	4789                	li	a5,2
ffffffffc0201538:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020153c:	00008717          	auipc	a4,0x8
ffffffffc0201540:	f0472703          	lw	a4,-252(a4) # ffffffffc0209440 <free_area+0x10>
ffffffffc0201544:	00008697          	auipc	a3,0x8
ffffffffc0201548:	eec68693          	addi	a3,a3,-276 # ffffffffc0209430 <free_area>
    return list->next == list;
ffffffffc020154c:	669c                	ld	a5,8(a3)
ffffffffc020154e:	9f2d                	addw	a4,a4,a1
ffffffffc0201550:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201552:	0ad78163          	beq	a5,a3,ffffffffc02015f4 <best_fit_free_pages+0xf8>
            struct Page* page = le2page(le, page_link);
ffffffffc0201556:	fe878713          	addi	a4,a5,-24
ffffffffc020155a:	4581                	li	a1,0
ffffffffc020155c:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201560:	00e56a63          	bltu	a0,a4,ffffffffc0201574 <best_fit_free_pages+0x78>
    return listelm->next;
ffffffffc0201564:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201566:	04d70c63          	beq	a4,a3,ffffffffc02015be <best_fit_free_pages+0xc2>
    struct Page *p = base;
ffffffffc020156a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020156c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201570:	fee57ae3          	bgeu	a0,a4,ffffffffc0201564 <best_fit_free_pages+0x68>
ffffffffc0201574:	c199                	beqz	a1,ffffffffc020157a <best_fit_free_pages+0x7e>
ffffffffc0201576:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020157a:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020157c:	e390                	sd	a2,0(a5)
ffffffffc020157e:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0201580:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201582:	f11c                	sd	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201584:	00d70d63          	beq	a4,a3,ffffffffc020159e <best_fit_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc0201588:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc020158c:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc0201590:	02059813          	slli	a6,a1,0x20
ffffffffc0201594:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201598:	97b2                	add	a5,a5,a2
ffffffffc020159a:	02f50c63          	beq	a0,a5,ffffffffc02015d2 <best_fit_free_pages+0xd6>
    return listelm->next;
ffffffffc020159e:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02015a0:	00d78c63          	beq	a5,a3,ffffffffc02015b8 <best_fit_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc02015a4:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc02015a6:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc02015aa:	02061593          	slli	a1,a2,0x20
ffffffffc02015ae:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02015b2:	972a                	add	a4,a4,a0
ffffffffc02015b4:	04e68c63          	beq	a3,a4,ffffffffc020160c <best_fit_free_pages+0x110>
}
ffffffffc02015b8:	60a2                	ld	ra,8(sp)
ffffffffc02015ba:	0141                	addi	sp,sp,16
ffffffffc02015bc:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02015be:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015c0:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02015c2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02015c4:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02015c6:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015c8:	02d70f63          	beq	a4,a3,ffffffffc0201606 <best_fit_free_pages+0x10a>
ffffffffc02015cc:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc02015ce:	87ba                	mv	a5,a4
ffffffffc02015d0:	bf71                	j	ffffffffc020156c <best_fit_free_pages+0x70>
            p->property += base->property;
ffffffffc02015d2:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02015d4:	5875                	li	a6,-3
ffffffffc02015d6:	9fad                	addw	a5,a5,a1
ffffffffc02015d8:	fef72c23          	sw	a5,-8(a4)
ffffffffc02015dc:	6108b02f          	amoand.d	zero,a6,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02015e0:	01853803          	ld	a6,24(a0)
ffffffffc02015e4:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02015e6:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc02015e8:	00b83423          	sd	a1,8(a6)
    return listelm->next;
ffffffffc02015ec:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc02015ee:	0105b023          	sd	a6,0(a1)
ffffffffc02015f2:	b77d                	j	ffffffffc02015a0 <best_fit_free_pages+0xa4>
}
ffffffffc02015f4:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02015f6:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc02015fa:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02015fc:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc02015fe:	e398                	sd	a4,0(a5)
ffffffffc0201600:	e798                	sd	a4,8(a5)
}
ffffffffc0201602:	0141                	addi	sp,sp,16
ffffffffc0201604:	8082                	ret
ffffffffc0201606:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201608:	873e                	mv	a4,a5
ffffffffc020160a:	bfad                	j	ffffffffc0201584 <best_fit_free_pages+0x88>
            base->property += p->property;
ffffffffc020160c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201610:	56f5                	li	a3,-3
ffffffffc0201612:	9f31                	addw	a4,a4,a2
ffffffffc0201614:	c918                	sw	a4,16(a0)
ffffffffc0201616:	ff078713          	addi	a4,a5,-16
ffffffffc020161a:	60d7302f          	amoand.d	zero,a3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc020161e:	6398                	ld	a4,0(a5)
ffffffffc0201620:	679c                	ld	a5,8(a5)
}
ffffffffc0201622:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201624:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201626:	e398                	sd	a4,0(a5)
ffffffffc0201628:	0141                	addi	sp,sp,16
ffffffffc020162a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020162c:	00003697          	auipc	a3,0x3
ffffffffc0201630:	41468693          	addi	a3,a3,1044 # ffffffffc0204a40 <etext+0xcb8>
ffffffffc0201634:	00003617          	auipc	a2,0x3
ffffffffc0201638:	11c60613          	addi	a2,a2,284 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020163c:	09200593          	li	a1,146
ffffffffc0201640:	00003517          	auipc	a0,0x3
ffffffffc0201644:	12850513          	addi	a0,a0,296 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201648:	dbffe0ef          	jal	ffffffffc0200406 <__panic>
    assert(n > 0);
ffffffffc020164c:	00003697          	auipc	a3,0x3
ffffffffc0201650:	0fc68693          	addi	a3,a3,252 # ffffffffc0204748 <etext+0x9c0>
ffffffffc0201654:	00003617          	auipc	a2,0x3
ffffffffc0201658:	0fc60613          	addi	a2,a2,252 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020165c:	08f00593          	li	a1,143
ffffffffc0201660:	00003517          	auipc	a0,0x3
ffffffffc0201664:	10850513          	addi	a0,a0,264 # ffffffffc0204768 <etext+0x9e0>
ffffffffc0201668:	d9ffe0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc020166c <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc020166c:	1141                	addi	sp,sp,-16
ffffffffc020166e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201670:	c9e1                	beqz	a1,ffffffffc0201740 <best_fit_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201672:	00659713          	slli	a4,a1,0x6
ffffffffc0201676:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc020167a:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc020167c:	cf11                	beqz	a4,ffffffffc0201698 <best_fit_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020167e:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201680:	8b05                	andi	a4,a4,1
ffffffffc0201682:	cf59                	beqz	a4,ffffffffc0201720 <best_fit_init_memmap+0xb4>
        p->flags = 0;
ffffffffc0201684:	0007b423          	sd	zero,8(a5)
        p->property = 0;
ffffffffc0201688:	0007a823          	sw	zero,16(a5)
ffffffffc020168c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201690:	04078793          	addi	a5,a5,64
ffffffffc0201694:	fed795e3          	bne	a5,a3,ffffffffc020167e <best_fit_init_memmap+0x12>
    base->property = n;
ffffffffc0201698:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020169a:	4789                	li	a5,2
ffffffffc020169c:	00850713          	addi	a4,a0,8
ffffffffc02016a0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02016a4:	00008717          	auipc	a4,0x8
ffffffffc02016a8:	d9c72703          	lw	a4,-612(a4) # ffffffffc0209440 <free_area+0x10>
ffffffffc02016ac:	00008697          	auipc	a3,0x8
ffffffffc02016b0:	d8468693          	addi	a3,a3,-636 # ffffffffc0209430 <free_area>
    return list->next == list;
ffffffffc02016b4:	669c                	ld	a5,8(a3)
ffffffffc02016b6:	9f2d                	addw	a4,a4,a1
ffffffffc02016b8:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02016ba:	04d78663          	beq	a5,a3,ffffffffc0201706 <best_fit_init_memmap+0x9a>
            struct Page* page = le2page(le, page_link);
ffffffffc02016be:	fe878713          	addi	a4,a5,-24
ffffffffc02016c2:	4581                	li	a1,0
ffffffffc02016c4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016c8:	00e56a63          	bltu	a0,a4,ffffffffc02016dc <best_fit_init_memmap+0x70>
    return listelm->next;
ffffffffc02016cc:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list) {
ffffffffc02016ce:	02d70263          	beq	a4,a3,ffffffffc02016f2 <best_fit_init_memmap+0x86>
    struct Page *p = base;
ffffffffc02016d2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016d4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016d8:	fee57ae3          	bgeu	a0,a4,ffffffffc02016cc <best_fit_init_memmap+0x60>
ffffffffc02016dc:	c199                	beqz	a1,ffffffffc02016e2 <best_fit_init_memmap+0x76>
ffffffffc02016de:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016e2:	6398                	ld	a4,0(a5)
}
ffffffffc02016e4:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02016e6:	e390                	sd	a2,0(a5)
ffffffffc02016e8:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc02016ea:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc02016ec:	f11c                	sd	a5,32(a0)
ffffffffc02016ee:	0141                	addi	sp,sp,16
ffffffffc02016f0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02016f2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016f4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02016f6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02016f8:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02016fa:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016fc:	00d70e63          	beq	a4,a3,ffffffffc0201718 <best_fit_init_memmap+0xac>
ffffffffc0201700:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201702:	87ba                	mv	a5,a4
ffffffffc0201704:	bfc1                	j	ffffffffc02016d4 <best_fit_init_memmap+0x68>
}
ffffffffc0201706:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201708:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc020170c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020170e:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201710:	e398                	sd	a4,0(a5)
ffffffffc0201712:	e798                	sd	a4,8(a5)
}
ffffffffc0201714:	0141                	addi	sp,sp,16
ffffffffc0201716:	8082                	ret
ffffffffc0201718:	60a2                	ld	ra,8(sp)
ffffffffc020171a:	e290                	sd	a2,0(a3)
ffffffffc020171c:	0141                	addi	sp,sp,16
ffffffffc020171e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201720:	00003697          	auipc	a3,0x3
ffffffffc0201724:	34868693          	addi	a3,a3,840 # ffffffffc0204a68 <etext+0xce0>
ffffffffc0201728:	00003617          	auipc	a2,0x3
ffffffffc020172c:	02860613          	addi	a2,a2,40 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0201730:	04a00593          	li	a1,74
ffffffffc0201734:	00003517          	auipc	a0,0x3
ffffffffc0201738:	03450513          	addi	a0,a0,52 # ffffffffc0204768 <etext+0x9e0>
ffffffffc020173c:	ccbfe0ef          	jal	ffffffffc0200406 <__panic>
    assert(n > 0);
ffffffffc0201740:	00003697          	auipc	a3,0x3
ffffffffc0201744:	00868693          	addi	a3,a3,8 # ffffffffc0204748 <etext+0x9c0>
ffffffffc0201748:	00003617          	auipc	a2,0x3
ffffffffc020174c:	00860613          	addi	a2,a2,8 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0201750:	04700593          	li	a1,71
ffffffffc0201754:	00003517          	auipc	a0,0x3
ffffffffc0201758:	01450513          	addi	a0,a0,20 # ffffffffc0204768 <etext+0x9e0>
ffffffffc020175c:	cabfe0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0201760 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201760:	c531                	beqz	a0,ffffffffc02017ac <slob_free+0x4c>
		return;

	if (size)
ffffffffc0201762:	e9b9                	bnez	a1,ffffffffc02017b8 <slob_free+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201764:	100027f3          	csrr	a5,sstatus
ffffffffc0201768:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020176a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020176c:	efb1                	bnez	a5,ffffffffc02017c8 <slob_free+0x68>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020176e:	00008797          	auipc	a5,0x8
ffffffffc0201772:	8b27b783          	ld	a5,-1870(a5) # ffffffffc0209020 <slobfree>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201776:	873e                	mv	a4,a5
ffffffffc0201778:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020177a:	02a77a63          	bgeu	a4,a0,ffffffffc02017ae <slob_free+0x4e>
ffffffffc020177e:	00f56463          	bltu	a0,a5,ffffffffc0201786 <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201782:	fef76ae3          	bltu	a4,a5,ffffffffc0201776 <slob_free+0x16>
			break;

	if (b + b->units == cur->next)
ffffffffc0201786:	4110                	lw	a2,0(a0)
ffffffffc0201788:	00461693          	slli	a3,a2,0x4
ffffffffc020178c:	96aa                	add	a3,a3,a0
ffffffffc020178e:	0ad78463          	beq	a5,a3,ffffffffc0201836 <slob_free+0xd6>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201792:	4310                	lw	a2,0(a4)
ffffffffc0201794:	e51c                	sd	a5,8(a0)
ffffffffc0201796:	00461693          	slli	a3,a2,0x4
ffffffffc020179a:	96ba                	add	a3,a3,a4
ffffffffc020179c:	08d50163          	beq	a0,a3,ffffffffc020181e <slob_free+0xbe>
ffffffffc02017a0:	e708                	sd	a0,8(a4)
		cur->next = b->next;
	}
	else
		cur->next = b;

	slobfree = cur;
ffffffffc02017a2:	00008797          	auipc	a5,0x8
ffffffffc02017a6:	86e7bf23          	sd	a4,-1922(a5) # ffffffffc0209020 <slobfree>
    if (flag) {
ffffffffc02017aa:	e9a5                	bnez	a1,ffffffffc020181a <slob_free+0xba>
ffffffffc02017ac:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017ae:	fcf574e3          	bgeu	a0,a5,ffffffffc0201776 <slob_free+0x16>
ffffffffc02017b2:	fcf762e3          	bltu	a4,a5,ffffffffc0201776 <slob_free+0x16>
ffffffffc02017b6:	bfc1                	j	ffffffffc0201786 <slob_free+0x26>
		b->units = SLOB_UNITS(size);
ffffffffc02017b8:	25bd                	addiw	a1,a1,15
ffffffffc02017ba:	8191                	srli	a1,a1,0x4
ffffffffc02017bc:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017be:	100027f3          	csrr	a5,sstatus
ffffffffc02017c2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02017c4:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017c6:	d7c5                	beqz	a5,ffffffffc020176e <slob_free+0xe>
{
ffffffffc02017c8:	1101                	addi	sp,sp,-32
ffffffffc02017ca:	e42a                	sd	a0,8(sp)
ffffffffc02017cc:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02017ce:	8a6ff0ef          	jal	ffffffffc0200874 <intr_disable>
        return 1;
ffffffffc02017d2:	6522                	ld	a0,8(sp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017d4:	00008797          	auipc	a5,0x8
ffffffffc02017d8:	84c7b783          	ld	a5,-1972(a5) # ffffffffc0209020 <slobfree>
ffffffffc02017dc:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017de:	873e                	mv	a4,a5
ffffffffc02017e0:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02017e2:	06a77663          	bgeu	a4,a0,ffffffffc020184e <slob_free+0xee>
ffffffffc02017e6:	00f56463          	bltu	a0,a5,ffffffffc02017ee <slob_free+0x8e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02017ea:	fef76ae3          	bltu	a4,a5,ffffffffc02017de <slob_free+0x7e>
	if (b + b->units == cur->next)
ffffffffc02017ee:	4110                	lw	a2,0(a0)
ffffffffc02017f0:	00461693          	slli	a3,a2,0x4
ffffffffc02017f4:	96aa                	add	a3,a3,a0
ffffffffc02017f6:	06d78363          	beq	a5,a3,ffffffffc020185c <slob_free+0xfc>
	if (cur + cur->units == b)
ffffffffc02017fa:	4310                	lw	a2,0(a4)
ffffffffc02017fc:	e51c                	sd	a5,8(a0)
ffffffffc02017fe:	00461693          	slli	a3,a2,0x4
ffffffffc0201802:	96ba                	add	a3,a3,a4
ffffffffc0201804:	06d50163          	beq	a0,a3,ffffffffc0201866 <slob_free+0x106>
ffffffffc0201808:	e708                	sd	a0,8(a4)
	slobfree = cur;
ffffffffc020180a:	00008797          	auipc	a5,0x8
ffffffffc020180e:	80e7bb23          	sd	a4,-2026(a5) # ffffffffc0209020 <slobfree>
    if (flag) {
ffffffffc0201812:	e1a9                	bnez	a1,ffffffffc0201854 <slob_free+0xf4>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201814:	60e2                	ld	ra,24(sp)
ffffffffc0201816:	6105                	addi	sp,sp,32
ffffffffc0201818:	8082                	ret
        intr_enable();
ffffffffc020181a:	854ff06f          	j	ffffffffc020086e <intr_enable>
		cur->units += b->units;
ffffffffc020181e:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201820:	853e                	mv	a0,a5
ffffffffc0201822:	e708                	sd	a0,8(a4)
		cur->units += b->units;
ffffffffc0201824:	00c687bb          	addw	a5,a3,a2
ffffffffc0201828:	c31c                	sw	a5,0(a4)
	slobfree = cur;
ffffffffc020182a:	00007797          	auipc	a5,0x7
ffffffffc020182e:	7ee7bb23          	sd	a4,2038(a5) # ffffffffc0209020 <slobfree>
    if (flag) {
ffffffffc0201832:	ddad                	beqz	a1,ffffffffc02017ac <slob_free+0x4c>
ffffffffc0201834:	b7dd                	j	ffffffffc020181a <slob_free+0xba>
		b->units += cur->next->units;
ffffffffc0201836:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201838:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc020183a:	9eb1                	addw	a3,a3,a2
ffffffffc020183c:	c114                	sw	a3,0(a0)
	if (cur + cur->units == b)
ffffffffc020183e:	4310                	lw	a2,0(a4)
ffffffffc0201840:	e51c                	sd	a5,8(a0)
ffffffffc0201842:	00461693          	slli	a3,a2,0x4
ffffffffc0201846:	96ba                	add	a3,a3,a4
ffffffffc0201848:	f4d51ce3          	bne	a0,a3,ffffffffc02017a0 <slob_free+0x40>
ffffffffc020184c:	bfc9                	j	ffffffffc020181e <slob_free+0xbe>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020184e:	f8f56ee3          	bltu	a0,a5,ffffffffc02017ea <slob_free+0x8a>
ffffffffc0201852:	b771                	j	ffffffffc02017de <slob_free+0x7e>
}
ffffffffc0201854:	60e2                	ld	ra,24(sp)
ffffffffc0201856:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201858:	816ff06f          	j	ffffffffc020086e <intr_enable>
		b->units += cur->next->units;
ffffffffc020185c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc020185e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201860:	9eb1                	addw	a3,a3,a2
ffffffffc0201862:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc0201864:	bf59                	j	ffffffffc02017fa <slob_free+0x9a>
		cur->units += b->units;
ffffffffc0201866:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201868:	853e                	mv	a0,a5
		cur->units += b->units;
ffffffffc020186a:	00c687bb          	addw	a5,a3,a2
ffffffffc020186e:	c31c                	sw	a5,0(a4)
		cur->next = b->next;
ffffffffc0201870:	bf61                	j	ffffffffc0201808 <slob_free+0xa8>

ffffffffc0201872 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201872:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201874:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201876:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc020187a:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc020187c:	326000ef          	jal	ffffffffc0201ba2 <alloc_pages>
	if (!page)
ffffffffc0201880:	c91d                	beqz	a0,ffffffffc02018b6 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201882:	0000c697          	auipc	a3,0xc
ffffffffc0201886:	c466b683          	ld	a3,-954(a3) # ffffffffc020d4c8 <pages>
ffffffffc020188a:	00004797          	auipc	a5,0x4
ffffffffc020188e:	fd67b783          	ld	a5,-42(a5) # ffffffffc0205860 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201892:	0000c717          	auipc	a4,0xc
ffffffffc0201896:	c2e73703          	ld	a4,-978(a4) # ffffffffc020d4c0 <npage>
    return page - pages + nbase;
ffffffffc020189a:	8d15                	sub	a0,a0,a3
ffffffffc020189c:	8519                	srai	a0,a0,0x6
ffffffffc020189e:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc02018a0:	00c51793          	slli	a5,a0,0xc
ffffffffc02018a4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02018a6:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc02018a8:	00e7fa63          	bgeu	a5,a4,ffffffffc02018bc <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc02018ac:	0000c797          	auipc	a5,0xc
ffffffffc02018b0:	c0c7b783          	ld	a5,-1012(a5) # ffffffffc020d4b8 <va_pa_offset>
ffffffffc02018b4:	953e                	add	a0,a0,a5
}
ffffffffc02018b6:	60a2                	ld	ra,8(sp)
ffffffffc02018b8:	0141                	addi	sp,sp,16
ffffffffc02018ba:	8082                	ret
ffffffffc02018bc:	86aa                	mv	a3,a0
ffffffffc02018be:	00003617          	auipc	a2,0x3
ffffffffc02018c2:	1d260613          	addi	a2,a2,466 # ffffffffc0204a90 <etext+0xd08>
ffffffffc02018c6:	07100593          	li	a1,113
ffffffffc02018ca:	00003517          	auipc	a0,0x3
ffffffffc02018ce:	1ee50513          	addi	a0,a0,494 # ffffffffc0204ab8 <etext+0xd30>
ffffffffc02018d2:	b35fe0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc02018d6 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc02018d6:	7179                	addi	sp,sp,-48
ffffffffc02018d8:	f406                	sd	ra,40(sp)
ffffffffc02018da:	f022                	sd	s0,32(sp)
ffffffffc02018dc:	ec26                	sd	s1,24(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc02018de:	01050713          	addi	a4,a0,16
ffffffffc02018e2:	6785                	lui	a5,0x1
ffffffffc02018e4:	0af77e63          	bgeu	a4,a5,ffffffffc02019a0 <slob_alloc.constprop.0+0xca>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc02018e8:	00f50413          	addi	s0,a0,15
ffffffffc02018ec:	8011                	srli	s0,s0,0x4
ffffffffc02018ee:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02018f0:	100025f3          	csrr	a1,sstatus
ffffffffc02018f4:	8989                	andi	a1,a1,2
ffffffffc02018f6:	edd1                	bnez	a1,ffffffffc0201992 <slob_alloc.constprop.0+0xbc>
	prev = slobfree;
ffffffffc02018f8:	00007497          	auipc	s1,0x7
ffffffffc02018fc:	72848493          	addi	s1,s1,1832 # ffffffffc0209020 <slobfree>
ffffffffc0201900:	6090                	ld	a2,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201902:	6618                	ld	a4,8(a2)
		if (cur->units >= units + delta)
ffffffffc0201904:	4314                	lw	a3,0(a4)
ffffffffc0201906:	0886da63          	bge	a3,s0,ffffffffc020199a <slob_alloc.constprop.0+0xc4>
		if (cur == slobfree)
ffffffffc020190a:	00e60a63          	beq	a2,a4,ffffffffc020191e <slob_alloc.constprop.0+0x48>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc020190e:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201910:	4394                	lw	a3,0(a5)
ffffffffc0201912:	0286d863          	bge	a3,s0,ffffffffc0201942 <slob_alloc.constprop.0+0x6c>
		if (cur == slobfree)
ffffffffc0201916:	6090                	ld	a2,0(s1)
ffffffffc0201918:	873e                	mv	a4,a5
ffffffffc020191a:	fee61ae3          	bne	a2,a4,ffffffffc020190e <slob_alloc.constprop.0+0x38>
    if (flag) {
ffffffffc020191e:	e9b1                	bnez	a1,ffffffffc0201972 <slob_alloc.constprop.0+0x9c>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201920:	4501                	li	a0,0
ffffffffc0201922:	f51ff0ef          	jal	ffffffffc0201872 <__slob_get_free_pages.constprop.0>
ffffffffc0201926:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc0201928:	c915                	beqz	a0,ffffffffc020195c <slob_alloc.constprop.0+0x86>
			slob_free(cur, PAGE_SIZE);
ffffffffc020192a:	6585                	lui	a1,0x1
ffffffffc020192c:	e35ff0ef          	jal	ffffffffc0201760 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201930:	100025f3          	csrr	a1,sstatus
ffffffffc0201934:	8989                	andi	a1,a1,2
ffffffffc0201936:	e98d                	bnez	a1,ffffffffc0201968 <slob_alloc.constprop.0+0x92>
			cur = slobfree;
ffffffffc0201938:	6098                	ld	a4,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc020193a:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc020193c:	4394                	lw	a3,0(a5)
ffffffffc020193e:	fc86cce3          	blt	a3,s0,ffffffffc0201916 <slob_alloc.constprop.0+0x40>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201942:	04d40563          	beq	s0,a3,ffffffffc020198c <slob_alloc.constprop.0+0xb6>
				prev->next = cur + units;
ffffffffc0201946:	00441613          	slli	a2,s0,0x4
ffffffffc020194a:	963e                	add	a2,a2,a5
ffffffffc020194c:	e710                	sd	a2,8(a4)
				prev->next->next = cur->next;
ffffffffc020194e:	6788                	ld	a0,8(a5)
				prev->next->units = cur->units - units;
ffffffffc0201950:	9e81                	subw	a3,a3,s0
ffffffffc0201952:	c214                	sw	a3,0(a2)
				prev->next->next = cur->next;
ffffffffc0201954:	e608                	sd	a0,8(a2)
				cur->units = units;
ffffffffc0201956:	c380                	sw	s0,0(a5)
			slobfree = prev;
ffffffffc0201958:	e098                	sd	a4,0(s1)
    if (flag) {
ffffffffc020195a:	ed99                	bnez	a1,ffffffffc0201978 <slob_alloc.constprop.0+0xa2>
}
ffffffffc020195c:	70a2                	ld	ra,40(sp)
ffffffffc020195e:	7402                	ld	s0,32(sp)
ffffffffc0201960:	64e2                	ld	s1,24(sp)
ffffffffc0201962:	853e                	mv	a0,a5
ffffffffc0201964:	6145                	addi	sp,sp,48
ffffffffc0201966:	8082                	ret
        intr_disable();
ffffffffc0201968:	f0dfe0ef          	jal	ffffffffc0200874 <intr_disable>
			cur = slobfree;
ffffffffc020196c:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc020196e:	4585                	li	a1,1
ffffffffc0201970:	b7e9                	j	ffffffffc020193a <slob_alloc.constprop.0+0x64>
        intr_enable();
ffffffffc0201972:	efdfe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0201976:	b76d                	j	ffffffffc0201920 <slob_alloc.constprop.0+0x4a>
ffffffffc0201978:	e43e                	sd	a5,8(sp)
ffffffffc020197a:	ef5fe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc020197e:	67a2                	ld	a5,8(sp)
}
ffffffffc0201980:	70a2                	ld	ra,40(sp)
ffffffffc0201982:	7402                	ld	s0,32(sp)
ffffffffc0201984:	64e2                	ld	s1,24(sp)
ffffffffc0201986:	853e                	mv	a0,a5
ffffffffc0201988:	6145                	addi	sp,sp,48
ffffffffc020198a:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc020198c:	6794                	ld	a3,8(a5)
ffffffffc020198e:	e714                	sd	a3,8(a4)
ffffffffc0201990:	b7e1                	j	ffffffffc0201958 <slob_alloc.constprop.0+0x82>
        intr_disable();
ffffffffc0201992:	ee3fe0ef          	jal	ffffffffc0200874 <intr_disable>
        return 1;
ffffffffc0201996:	4585                	li	a1,1
ffffffffc0201998:	b785                	j	ffffffffc02018f8 <slob_alloc.constprop.0+0x22>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc020199a:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc020199c:	8732                	mv	a4,a2
ffffffffc020199e:	b755                	j	ffffffffc0201942 <slob_alloc.constprop.0+0x6c>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc02019a0:	00003697          	auipc	a3,0x3
ffffffffc02019a4:	12868693          	addi	a3,a3,296 # ffffffffc0204ac8 <etext+0xd40>
ffffffffc02019a8:	00003617          	auipc	a2,0x3
ffffffffc02019ac:	da860613          	addi	a2,a2,-600 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02019b0:	06300593          	li	a1,99
ffffffffc02019b4:	00003517          	auipc	a0,0x3
ffffffffc02019b8:	13450513          	addi	a0,a0,308 # ffffffffc0204ae8 <etext+0xd60>
ffffffffc02019bc:	a4bfe0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc02019c0 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc02019c0:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc02019c2:	00003517          	auipc	a0,0x3
ffffffffc02019c6:	13e50513          	addi	a0,a0,318 # ffffffffc0204b00 <etext+0xd78>
{
ffffffffc02019ca:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc02019cc:	fc8fe0ef          	jal	ffffffffc0200194 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc02019d0:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc02019d2:	00003517          	auipc	a0,0x3
ffffffffc02019d6:	14650513          	addi	a0,a0,326 # ffffffffc0204b18 <etext+0xd90>
}
ffffffffc02019da:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc02019dc:	fb8fe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc02019e0 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc02019e0:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc02019e2:	6685                	lui	a3,0x1
{
ffffffffc02019e4:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc02019e6:	16bd                	addi	a3,a3,-17 # fef <kern_entry-0xffffffffc01ff011>
ffffffffc02019e8:	04a6f963          	bgeu	a3,a0,ffffffffc0201a3a <kmalloc+0x5a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc02019ec:	e42a                	sd	a0,8(sp)
ffffffffc02019ee:	4561                	li	a0,24
ffffffffc02019f0:	e822                	sd	s0,16(sp)
ffffffffc02019f2:	ee5ff0ef          	jal	ffffffffc02018d6 <slob_alloc.constprop.0>
ffffffffc02019f6:	842a                	mv	s0,a0
	if (!bb)
ffffffffc02019f8:	c541                	beqz	a0,ffffffffc0201a80 <kmalloc+0xa0>
	bb->order = find_order(size);
ffffffffc02019fa:	47a2                	lw	a5,8(sp)
	for (; size > 4096; size >>= 1)
ffffffffc02019fc:	6705                	lui	a4,0x1
	int order = 0;
ffffffffc02019fe:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201a00:	00f75763          	bge	a4,a5,ffffffffc0201a0e <kmalloc+0x2e>
ffffffffc0201a04:	4017d79b          	sraiw	a5,a5,0x1
		order++;
ffffffffc0201a08:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201a0a:	fef74de3          	blt	a4,a5,ffffffffc0201a04 <kmalloc+0x24>
	bb->order = find_order(size);
ffffffffc0201a0e:	c008                	sw	a0,0(s0)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201a10:	e63ff0ef          	jal	ffffffffc0201872 <__slob_get_free_pages.constprop.0>
ffffffffc0201a14:	e408                	sd	a0,8(s0)
	if (bb->pages)
ffffffffc0201a16:	cd31                	beqz	a0,ffffffffc0201a72 <kmalloc+0x92>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a18:	100027f3          	csrr	a5,sstatus
ffffffffc0201a1c:	8b89                	andi	a5,a5,2
ffffffffc0201a1e:	eb85                	bnez	a5,ffffffffc0201a4e <kmalloc+0x6e>
		bb->next = bigblocks;
ffffffffc0201a20:	0000c797          	auipc	a5,0xc
ffffffffc0201a24:	a787b783          	ld	a5,-1416(a5) # ffffffffc020d498 <bigblocks>
		bigblocks = bb;
ffffffffc0201a28:	0000c717          	auipc	a4,0xc
ffffffffc0201a2c:	a6873823          	sd	s0,-1424(a4) # ffffffffc020d498 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a30:	e81c                	sd	a5,16(s0)
    if (flag) {
ffffffffc0201a32:	6442                	ld	s0,16(sp)
	return __kmalloc(size, 0);
}
ffffffffc0201a34:	60e2                	ld	ra,24(sp)
ffffffffc0201a36:	6105                	addi	sp,sp,32
ffffffffc0201a38:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201a3a:	0541                	addi	a0,a0,16
ffffffffc0201a3c:	e9bff0ef          	jal	ffffffffc02018d6 <slob_alloc.constprop.0>
ffffffffc0201a40:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201a42:	0541                	addi	a0,a0,16
ffffffffc0201a44:	fbe5                	bnez	a5,ffffffffc0201a34 <kmalloc+0x54>
		return 0;
ffffffffc0201a46:	4501                	li	a0,0
}
ffffffffc0201a48:	60e2                	ld	ra,24(sp)
ffffffffc0201a4a:	6105                	addi	sp,sp,32
ffffffffc0201a4c:	8082                	ret
        intr_disable();
ffffffffc0201a4e:	e27fe0ef          	jal	ffffffffc0200874 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201a52:	0000c797          	auipc	a5,0xc
ffffffffc0201a56:	a467b783          	ld	a5,-1466(a5) # ffffffffc020d498 <bigblocks>
		bigblocks = bb;
ffffffffc0201a5a:	0000c717          	auipc	a4,0xc
ffffffffc0201a5e:	a2873f23          	sd	s0,-1474(a4) # ffffffffc020d498 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201a62:	e81c                	sd	a5,16(s0)
        intr_enable();
ffffffffc0201a64:	e0bfe0ef          	jal	ffffffffc020086e <intr_enable>
		return bb->pages;
ffffffffc0201a68:	6408                	ld	a0,8(s0)
}
ffffffffc0201a6a:	60e2                	ld	ra,24(sp)
		return bb->pages;
ffffffffc0201a6c:	6442                	ld	s0,16(sp)
}
ffffffffc0201a6e:	6105                	addi	sp,sp,32
ffffffffc0201a70:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201a72:	8522                	mv	a0,s0
ffffffffc0201a74:	45e1                	li	a1,24
ffffffffc0201a76:	cebff0ef          	jal	ffffffffc0201760 <slob_free>
		return 0;
ffffffffc0201a7a:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201a7c:	6442                	ld	s0,16(sp)
ffffffffc0201a7e:	b7e9                	j	ffffffffc0201a48 <kmalloc+0x68>
ffffffffc0201a80:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc0201a82:	4501                	li	a0,0
ffffffffc0201a84:	b7d1                	j	ffffffffc0201a48 <kmalloc+0x68>

ffffffffc0201a86 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201a86:	c571                	beqz	a0,ffffffffc0201b52 <kfree+0xcc>
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201a88:	03451793          	slli	a5,a0,0x34
ffffffffc0201a8c:	e3e1                	bnez	a5,ffffffffc0201b4c <kfree+0xc6>
{
ffffffffc0201a8e:	1101                	addi	sp,sp,-32
ffffffffc0201a90:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a92:	100027f3          	csrr	a5,sstatus
ffffffffc0201a96:	8b89                	andi	a5,a5,2
ffffffffc0201a98:	e7c1                	bnez	a5,ffffffffc0201b20 <kfree+0x9a>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201a9a:	0000c797          	auipc	a5,0xc
ffffffffc0201a9e:	9fe7b783          	ld	a5,-1538(a5) # ffffffffc020d498 <bigblocks>
    return 0;
ffffffffc0201aa2:	4581                	li	a1,0
ffffffffc0201aa4:	cbad                	beqz	a5,ffffffffc0201b16 <kfree+0x90>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201aa6:	0000c617          	auipc	a2,0xc
ffffffffc0201aaa:	9f260613          	addi	a2,a2,-1550 # ffffffffc020d498 <bigblocks>
ffffffffc0201aae:	a021                	j	ffffffffc0201ab6 <kfree+0x30>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201ab0:	01070613          	addi	a2,a4,16
ffffffffc0201ab4:	c3a5                	beqz	a5,ffffffffc0201b14 <kfree+0x8e>
		{
			if (bb->pages == block)
ffffffffc0201ab6:	6794                	ld	a3,8(a5)
ffffffffc0201ab8:	873e                	mv	a4,a5
			{
				*last = bb->next;
ffffffffc0201aba:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201abc:	fea69ae3          	bne	a3,a0,ffffffffc0201ab0 <kfree+0x2a>
				*last = bb->next;
ffffffffc0201ac0:	e21c                	sd	a5,0(a2)
    if (flag) {
ffffffffc0201ac2:	edb5                	bnez	a1,ffffffffc0201b3e <kfree+0xb8>
    return pa2page(PADDR(kva));
ffffffffc0201ac4:	c02007b7          	lui	a5,0xc0200
ffffffffc0201ac8:	0af56263          	bltu	a0,a5,ffffffffc0201b6c <kfree+0xe6>
ffffffffc0201acc:	0000c797          	auipc	a5,0xc
ffffffffc0201ad0:	9ec7b783          	ld	a5,-1556(a5) # ffffffffc020d4b8 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0201ad4:	0000c697          	auipc	a3,0xc
ffffffffc0201ad8:	9ec6b683          	ld	a3,-1556(a3) # ffffffffc020d4c0 <npage>
    return pa2page(PADDR(kva));
ffffffffc0201adc:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0201ade:	00c55793          	srli	a5,a0,0xc
ffffffffc0201ae2:	06d7f963          	bgeu	a5,a3,ffffffffc0201b54 <kfree+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ae6:	00004617          	auipc	a2,0x4
ffffffffc0201aea:	d7a63603          	ld	a2,-646(a2) # ffffffffc0205860 <nbase>
ffffffffc0201aee:	0000c517          	auipc	a0,0xc
ffffffffc0201af2:	9da53503          	ld	a0,-1574(a0) # ffffffffc020d4c8 <pages>
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201af6:	4314                	lw	a3,0(a4)
ffffffffc0201af8:	8f91                	sub	a5,a5,a2
ffffffffc0201afa:	079a                	slli	a5,a5,0x6
ffffffffc0201afc:	4585                	li	a1,1
ffffffffc0201afe:	953e                	add	a0,a0,a5
ffffffffc0201b00:	00d595bb          	sllw	a1,a1,a3
ffffffffc0201b04:	e03a                	sd	a4,0(sp)
ffffffffc0201b06:	0d6000ef          	jal	ffffffffc0201bdc <free_pages>
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b0a:	6502                	ld	a0,0(sp)
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201b0c:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b0e:	45e1                	li	a1,24
}
ffffffffc0201b10:	6105                	addi	sp,sp,32
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201b12:	b1b9                	j	ffffffffc0201760 <slob_free>
ffffffffc0201b14:	e185                	bnez	a1,ffffffffc0201b34 <kfree+0xae>
}
ffffffffc0201b16:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b18:	1541                	addi	a0,a0,-16
ffffffffc0201b1a:	4581                	li	a1,0
}
ffffffffc0201b1c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b1e:	b189                	j	ffffffffc0201760 <slob_free>
        intr_disable();
ffffffffc0201b20:	e02a                	sd	a0,0(sp)
ffffffffc0201b22:	d53fe0ef          	jal	ffffffffc0200874 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201b26:	0000c797          	auipc	a5,0xc
ffffffffc0201b2a:	9727b783          	ld	a5,-1678(a5) # ffffffffc020d498 <bigblocks>
ffffffffc0201b2e:	6502                	ld	a0,0(sp)
        return 1;
ffffffffc0201b30:	4585                	li	a1,1
ffffffffc0201b32:	fbb5                	bnez	a5,ffffffffc0201aa6 <kfree+0x20>
ffffffffc0201b34:	e02a                	sd	a0,0(sp)
        intr_enable();
ffffffffc0201b36:	d39fe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0201b3a:	6502                	ld	a0,0(sp)
ffffffffc0201b3c:	bfe9                	j	ffffffffc0201b16 <kfree+0x90>
ffffffffc0201b3e:	e42a                	sd	a0,8(sp)
ffffffffc0201b40:	e03a                	sd	a4,0(sp)
ffffffffc0201b42:	d2dfe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0201b46:	6522                	ld	a0,8(sp)
ffffffffc0201b48:	6702                	ld	a4,0(sp)
ffffffffc0201b4a:	bfad                	j	ffffffffc0201ac4 <kfree+0x3e>
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201b4c:	1541                	addi	a0,a0,-16
ffffffffc0201b4e:	4581                	li	a1,0
ffffffffc0201b50:	b901                	j	ffffffffc0201760 <slob_free>
ffffffffc0201b52:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201b54:	00003617          	auipc	a2,0x3
ffffffffc0201b58:	00c60613          	addi	a2,a2,12 # ffffffffc0204b60 <etext+0xdd8>
ffffffffc0201b5c:	06900593          	li	a1,105
ffffffffc0201b60:	00003517          	auipc	a0,0x3
ffffffffc0201b64:	f5850513          	addi	a0,a0,-168 # ffffffffc0204ab8 <etext+0xd30>
ffffffffc0201b68:	89ffe0ef          	jal	ffffffffc0200406 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201b6c:	86aa                	mv	a3,a0
ffffffffc0201b6e:	00003617          	auipc	a2,0x3
ffffffffc0201b72:	fca60613          	addi	a2,a2,-54 # ffffffffc0204b38 <etext+0xdb0>
ffffffffc0201b76:	07700593          	li	a1,119
ffffffffc0201b7a:	00003517          	auipc	a0,0x3
ffffffffc0201b7e:	f3e50513          	addi	a0,a0,-194 # ffffffffc0204ab8 <etext+0xd30>
ffffffffc0201b82:	885fe0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0201b86 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201b86:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201b88:	00003617          	auipc	a2,0x3
ffffffffc0201b8c:	fd860613          	addi	a2,a2,-40 # ffffffffc0204b60 <etext+0xdd8>
ffffffffc0201b90:	06900593          	li	a1,105
ffffffffc0201b94:	00003517          	auipc	a0,0x3
ffffffffc0201b98:	f2450513          	addi	a0,a0,-220 # ffffffffc0204ab8 <etext+0xd30>
pa2page(uintptr_t pa)
ffffffffc0201b9c:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201b9e:	869fe0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0201ba2 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ba2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ba6:	8b89                	andi	a5,a5,2
ffffffffc0201ba8:	e799                	bnez	a5,ffffffffc0201bb6 <alloc_pages+0x14>
    struct Page *page = NULL;
    bool intr_flag;
    // 在临界区内分配页面（禁用中断）
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201baa:	0000c797          	auipc	a5,0xc
ffffffffc0201bae:	8f67b783          	ld	a5,-1802(a5) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201bb2:	6f9c                	ld	a5,24(a5)
ffffffffc0201bb4:	8782                	jr	a5
{
ffffffffc0201bb6:	1101                	addi	sp,sp,-32
ffffffffc0201bb8:	ec06                	sd	ra,24(sp)
ffffffffc0201bba:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201bbc:	cb9fe0ef          	jal	ffffffffc0200874 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201bc0:	0000c797          	auipc	a5,0xc
ffffffffc0201bc4:	8e07b783          	ld	a5,-1824(a5) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201bc8:	6522                	ld	a0,8(sp)
ffffffffc0201bca:	6f9c                	ld	a5,24(a5)
ffffffffc0201bcc:	9782                	jalr	a5
ffffffffc0201bce:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201bd0:	c9ffe0ef          	jal	ffffffffc020086e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201bd4:	60e2                	ld	ra,24(sp)
ffffffffc0201bd6:	6522                	ld	a0,8(sp)
ffffffffc0201bd8:	6105                	addi	sp,sp,32
ffffffffc0201bda:	8082                	ret

ffffffffc0201bdc <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bdc:	100027f3          	csrr	a5,sstatus
ffffffffc0201be0:	8b89                	andi	a5,a5,2
ffffffffc0201be2:	e799                	bnez	a5,ffffffffc0201bf0 <free_pages+0x14>
{
    bool intr_flag;
    // 在临界区内释放页面（禁用中断）
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201be4:	0000c797          	auipc	a5,0xc
ffffffffc0201be8:	8bc7b783          	ld	a5,-1860(a5) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201bec:	739c                	ld	a5,32(a5)
ffffffffc0201bee:	8782                	jr	a5
{
ffffffffc0201bf0:	1101                	addi	sp,sp,-32
ffffffffc0201bf2:	ec06                	sd	ra,24(sp)
ffffffffc0201bf4:	e42e                	sd	a1,8(sp)
ffffffffc0201bf6:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0201bf8:	c7dfe0ef          	jal	ffffffffc0200874 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201bfc:	0000c797          	auipc	a5,0xc
ffffffffc0201c00:	8a47b783          	ld	a5,-1884(a5) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201c04:	65a2                	ld	a1,8(sp)
ffffffffc0201c06:	6502                	ld	a0,0(sp)
ffffffffc0201c08:	739c                	ld	a5,32(a5)
ffffffffc0201c0a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201c0c:	60e2                	ld	ra,24(sp)
ffffffffc0201c0e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201c10:	c5ffe06f          	j	ffffffffc020086e <intr_enable>

ffffffffc0201c14 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c14:	100027f3          	csrr	a5,sstatus
ffffffffc0201c18:	8b89                	andi	a5,a5,2
ffffffffc0201c1a:	e799                	bnez	a5,ffffffffc0201c28 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c1c:	0000c797          	auipc	a5,0xc
ffffffffc0201c20:	8847b783          	ld	a5,-1916(a5) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201c24:	779c                	ld	a5,40(a5)
ffffffffc0201c26:	8782                	jr	a5
{
ffffffffc0201c28:	1101                	addi	sp,sp,-32
ffffffffc0201c2a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201c2c:	c49fe0ef          	jal	ffffffffc0200874 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201c30:	0000c797          	auipc	a5,0xc
ffffffffc0201c34:	8707b783          	ld	a5,-1936(a5) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201c38:	779c                	ld	a5,40(a5)
ffffffffc0201c3a:	9782                	jalr	a5
ffffffffc0201c3c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201c3e:	c31fe0ef          	jal	ffffffffc020086e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201c42:	60e2                	ld	ra,24(sp)
ffffffffc0201c44:	6522                	ld	a0,8(sp)
ffffffffc0201c46:	6105                	addi	sp,sp,32
ffffffffc0201c48:	8082                	ret

ffffffffc0201c4a <get_pte>:
//  create: 逻辑值，决定是否为PT分配页面
// 返回值: 该pte的内核虚拟地址
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    // 获取一级页目录条目
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201c4a:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201c4e:	1ff7f793          	andi	a5,a5,511
ffffffffc0201c52:	078e                	slli	a5,a5,0x3
ffffffffc0201c54:	00f50733          	add	a4,a0,a5
    // 如果一级页目录条目无效
    if (!(*pdep1 & PTE_V))
ffffffffc0201c58:	6314                	ld	a3,0(a4)
{
ffffffffc0201c5a:	7139                	addi	sp,sp,-64
ffffffffc0201c5c:	f822                	sd	s0,48(sp)
ffffffffc0201c5e:	f426                	sd	s1,40(sp)
ffffffffc0201c60:	fc06                	sd	ra,56(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201c62:	0016f793          	andi	a5,a3,1
{
ffffffffc0201c66:	842e                	mv	s0,a1
ffffffffc0201c68:	8832                	mv	a6,a2
ffffffffc0201c6a:	0000c497          	auipc	s1,0xc
ffffffffc0201c6e:	85648493          	addi	s1,s1,-1962 # ffffffffc020d4c0 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201c72:	ebd1                	bnez	a5,ffffffffc0201d06 <get_pte+0xbc>
    {
        struct Page *page;
        // 如果不创建或分配页面失败，返回NULL
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201c74:	16060d63          	beqz	a2,ffffffffc0201dee <get_pte+0x1a4>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c78:	100027f3          	csrr	a5,sstatus
ffffffffc0201c7c:	8b89                	andi	a5,a5,2
ffffffffc0201c7e:	16079e63          	bnez	a5,ffffffffc0201dfa <get_pte+0x1b0>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201c82:	0000c797          	auipc	a5,0xc
ffffffffc0201c86:	81e7b783          	ld	a5,-2018(a5) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201c8a:	4505                	li	a0,1
ffffffffc0201c8c:	e43a                	sd	a4,8(sp)
ffffffffc0201c8e:	6f9c                	ld	a5,24(a5)
ffffffffc0201c90:	e832                	sd	a2,16(sp)
ffffffffc0201c92:	9782                	jalr	a5
ffffffffc0201c94:	6722                	ld	a4,8(sp)
ffffffffc0201c96:	6842                	ld	a6,16(sp)
ffffffffc0201c98:	87aa                	mv	a5,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201c9a:	14078a63          	beqz	a5,ffffffffc0201dee <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0201c9e:	0000c517          	auipc	a0,0xc
ffffffffc0201ca2:	82a53503          	ld	a0,-2006(a0) # ffffffffc020d4c8 <pages>
ffffffffc0201ca6:	000808b7          	lui	a7,0x80
        // 设置页面引用计数为1
        set_page_ref(page, 1);
        // 获取页面的物理地址
        uintptr_t pa = page2pa(page);
        // 清空页面内容
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201caa:	0000c497          	auipc	s1,0xc
ffffffffc0201cae:	81648493          	addi	s1,s1,-2026 # ffffffffc020d4c0 <npage>
ffffffffc0201cb2:	40a78533          	sub	a0,a5,a0
ffffffffc0201cb6:	8519                	srai	a0,a0,0x6
ffffffffc0201cb8:	9546                	add	a0,a0,a7
ffffffffc0201cba:	6090                	ld	a2,0(s1)
ffffffffc0201cbc:	00c51693          	slli	a3,a0,0xc
    page->ref = val;
ffffffffc0201cc0:	4585                	li	a1,1
ffffffffc0201cc2:	82b1                	srli	a3,a3,0xc
ffffffffc0201cc4:	c38c                	sw	a1,0(a5)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201cc6:	0532                	slli	a0,a0,0xc
ffffffffc0201cc8:	1ac6f763          	bgeu	a3,a2,ffffffffc0201e76 <get_pte+0x22c>
ffffffffc0201ccc:	0000b697          	auipc	a3,0xb
ffffffffc0201cd0:	7ec6b683          	ld	a3,2028(a3) # ffffffffc020d4b8 <va_pa_offset>
ffffffffc0201cd4:	6605                	lui	a2,0x1
ffffffffc0201cd6:	4581                	li	a1,0
ffffffffc0201cd8:	9536                	add	a0,a0,a3
ffffffffc0201cda:	ec42                	sd	a6,24(sp)
ffffffffc0201cdc:	e83e                	sd	a5,16(sp)
ffffffffc0201cde:	e43a                	sd	a4,8(sp)
ffffffffc0201ce0:	05a020ef          	jal	ffffffffc0203d3a <memset>
    return page - pages + nbase;
ffffffffc0201ce4:	0000b697          	auipc	a3,0xb
ffffffffc0201ce8:	7e46b683          	ld	a3,2020(a3) # ffffffffc020d4c8 <pages>
ffffffffc0201cec:	67c2                	ld	a5,16(sp)
ffffffffc0201cee:	000808b7          	lui	a7,0x80
        // 创建一级页目录条目
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201cf2:	6722                	ld	a4,8(sp)
ffffffffc0201cf4:	40d786b3          	sub	a3,a5,a3
ffffffffc0201cf8:	8699                	srai	a3,a3,0x6
ffffffffc0201cfa:	96c6                	add	a3,a3,a7
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201cfc:	06aa                	slli	a3,a3,0xa
ffffffffc0201cfe:	6862                	ld	a6,24(sp)
ffffffffc0201d00:	0116e693          	ori	a3,a3,17
ffffffffc0201d04:	e314                	sd	a3,0(a4)
    }
    
    // 获取二级页目录条目
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201d06:	c006f693          	andi	a3,a3,-1024
ffffffffc0201d0a:	6098                	ld	a4,0(s1)
ffffffffc0201d0c:	068a                	slli	a3,a3,0x2
ffffffffc0201d0e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201d12:	14e7f663          	bgeu	a5,a4,ffffffffc0201e5e <get_pte+0x214>
ffffffffc0201d16:	0000b897          	auipc	a7,0xb
ffffffffc0201d1a:	7a288893          	addi	a7,a7,1954 # ffffffffc020d4b8 <va_pa_offset>
ffffffffc0201d1e:	0008b603          	ld	a2,0(a7)
ffffffffc0201d22:	01545793          	srli	a5,s0,0x15
ffffffffc0201d26:	1ff7f793          	andi	a5,a5,511
ffffffffc0201d2a:	96b2                	add	a3,a3,a2
ffffffffc0201d2c:	078e                	slli	a5,a5,0x3
ffffffffc0201d2e:	97b6                	add	a5,a5,a3
    // 如果二级页目录条目无效
    if (!(*pdep0 & PTE_V))
ffffffffc0201d30:	6394                	ld	a3,0(a5)
ffffffffc0201d32:	0016f613          	andi	a2,a3,1
ffffffffc0201d36:	e659                	bnez	a2,ffffffffc0201dc4 <get_pte+0x17a>
    {
        struct Page *page;
        // 如果不创建或分配页面失败，返回NULL
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201d38:	0a080b63          	beqz	a6,ffffffffc0201dee <get_pte+0x1a4>
ffffffffc0201d3c:	10002773          	csrr	a4,sstatus
ffffffffc0201d40:	8b09                	andi	a4,a4,2
ffffffffc0201d42:	ef71                	bnez	a4,ffffffffc0201e1e <get_pte+0x1d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201d44:	0000b717          	auipc	a4,0xb
ffffffffc0201d48:	75c73703          	ld	a4,1884(a4) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201d4c:	4505                	li	a0,1
ffffffffc0201d4e:	e43e                	sd	a5,8(sp)
ffffffffc0201d50:	6f18                	ld	a4,24(a4)
ffffffffc0201d52:	9702                	jalr	a4
ffffffffc0201d54:	67a2                	ld	a5,8(sp)
ffffffffc0201d56:	872a                	mv	a4,a0
ffffffffc0201d58:	0000b897          	auipc	a7,0xb
ffffffffc0201d5c:	76088893          	addi	a7,a7,1888 # ffffffffc020d4b8 <va_pa_offset>
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201d60:	c759                	beqz	a4,ffffffffc0201dee <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0201d62:	0000b697          	auipc	a3,0xb
ffffffffc0201d66:	7666b683          	ld	a3,1894(a3) # ffffffffc020d4c8 <pages>
ffffffffc0201d6a:	00080837          	lui	a6,0x80
        // 设置页面引用计数为1
        set_page_ref(page, 1);
        // 获取页面的物理地址
        uintptr_t pa = page2pa(page);
        // 清空页面内容
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201d6e:	608c                	ld	a1,0(s1)
ffffffffc0201d70:	40d706b3          	sub	a3,a4,a3
ffffffffc0201d74:	8699                	srai	a3,a3,0x6
ffffffffc0201d76:	96c2                	add	a3,a3,a6
ffffffffc0201d78:	00c69613          	slli	a2,a3,0xc
    page->ref = val;
ffffffffc0201d7c:	4505                	li	a0,1
ffffffffc0201d7e:	8231                	srli	a2,a2,0xc
ffffffffc0201d80:	c308                	sw	a0,0(a4)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201d82:	06b2                	slli	a3,a3,0xc
ffffffffc0201d84:	10b67663          	bgeu	a2,a1,ffffffffc0201e90 <get_pte+0x246>
ffffffffc0201d88:	0008b503          	ld	a0,0(a7)
ffffffffc0201d8c:	6605                	lui	a2,0x1
ffffffffc0201d8e:	4581                	li	a1,0
ffffffffc0201d90:	9536                	add	a0,a0,a3
ffffffffc0201d92:	e83a                	sd	a4,16(sp)
ffffffffc0201d94:	e43e                	sd	a5,8(sp)
ffffffffc0201d96:	7a5010ef          	jal	ffffffffc0203d3a <memset>
    return page - pages + nbase;
ffffffffc0201d9a:	0000b697          	auipc	a3,0xb
ffffffffc0201d9e:	72e6b683          	ld	a3,1838(a3) # ffffffffc020d4c8 <pages>
ffffffffc0201da2:	6742                	ld	a4,16(sp)
ffffffffc0201da4:	00080837          	lui	a6,0x80
        // 创建二级页目录条目
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201da8:	67a2                	ld	a5,8(sp)
ffffffffc0201daa:	40d706b3          	sub	a3,a4,a3
ffffffffc0201dae:	8699                	srai	a3,a3,0x6
ffffffffc0201db0:	96c2                	add	a3,a3,a6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201db2:	06aa                	slli	a3,a3,0xa
ffffffffc0201db4:	0116e693          	ori	a3,a3,17
ffffffffc0201db8:	e394                	sd	a3,0(a5)
    }
    
    // 返回页表条目指针
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201dba:	6098                	ld	a4,0(s1)
ffffffffc0201dbc:	0000b897          	auipc	a7,0xb
ffffffffc0201dc0:	6fc88893          	addi	a7,a7,1788 # ffffffffc020d4b8 <va_pa_offset>
ffffffffc0201dc4:	c006f693          	andi	a3,a3,-1024
ffffffffc0201dc8:	068a                	slli	a3,a3,0x2
ffffffffc0201dca:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201dce:	06e7fc63          	bgeu	a5,a4,ffffffffc0201e46 <get_pte+0x1fc>
ffffffffc0201dd2:	0008b783          	ld	a5,0(a7)
ffffffffc0201dd6:	8031                	srli	s0,s0,0xc
ffffffffc0201dd8:	1ff47413          	andi	s0,s0,511
ffffffffc0201ddc:	040e                	slli	s0,s0,0x3
ffffffffc0201dde:	96be                	add	a3,a3,a5
}
ffffffffc0201de0:	70e2                	ld	ra,56(sp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201de2:	00868533          	add	a0,a3,s0
}
ffffffffc0201de6:	7442                	ld	s0,48(sp)
ffffffffc0201de8:	74a2                	ld	s1,40(sp)
ffffffffc0201dea:	6121                	addi	sp,sp,64
ffffffffc0201dec:	8082                	ret
ffffffffc0201dee:	70e2                	ld	ra,56(sp)
ffffffffc0201df0:	7442                	ld	s0,48(sp)
ffffffffc0201df2:	74a2                	ld	s1,40(sp)
            return NULL;
ffffffffc0201df4:	4501                	li	a0,0
}
ffffffffc0201df6:	6121                	addi	sp,sp,64
ffffffffc0201df8:	8082                	ret
        intr_disable();
ffffffffc0201dfa:	e83a                	sd	a4,16(sp)
ffffffffc0201dfc:	ec32                	sd	a2,24(sp)
ffffffffc0201dfe:	a77fe0ef          	jal	ffffffffc0200874 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201e02:	0000b797          	auipc	a5,0xb
ffffffffc0201e06:	69e7b783          	ld	a5,1694(a5) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201e0a:	4505                	li	a0,1
ffffffffc0201e0c:	6f9c                	ld	a5,24(a5)
ffffffffc0201e0e:	9782                	jalr	a5
ffffffffc0201e10:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201e12:	a5dfe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0201e16:	6862                	ld	a6,24(sp)
ffffffffc0201e18:	6742                	ld	a4,16(sp)
ffffffffc0201e1a:	67a2                	ld	a5,8(sp)
ffffffffc0201e1c:	bdbd                	j	ffffffffc0201c9a <get_pte+0x50>
        intr_disable();
ffffffffc0201e1e:	e83e                	sd	a5,16(sp)
ffffffffc0201e20:	a55fe0ef          	jal	ffffffffc0200874 <intr_disable>
ffffffffc0201e24:	0000b717          	auipc	a4,0xb
ffffffffc0201e28:	67c73703          	ld	a4,1660(a4) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201e2c:	4505                	li	a0,1
ffffffffc0201e2e:	6f18                	ld	a4,24(a4)
ffffffffc0201e30:	9702                	jalr	a4
ffffffffc0201e32:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201e34:	a3bfe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0201e38:	6722                	ld	a4,8(sp)
ffffffffc0201e3a:	67c2                	ld	a5,16(sp)
ffffffffc0201e3c:	0000b897          	auipc	a7,0xb
ffffffffc0201e40:	67c88893          	addi	a7,a7,1660 # ffffffffc020d4b8 <va_pa_offset>
ffffffffc0201e44:	bf31                	j	ffffffffc0201d60 <get_pte+0x116>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201e46:	00003617          	auipc	a2,0x3
ffffffffc0201e4a:	c4a60613          	addi	a2,a2,-950 # ffffffffc0204a90 <etext+0xd08>
ffffffffc0201e4e:	12100593          	li	a1,289
ffffffffc0201e52:	00003517          	auipc	a0,0x3
ffffffffc0201e56:	d2e50513          	addi	a0,a0,-722 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0201e5a:	dacfe0ef          	jal	ffffffffc0200406 <__panic>
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201e5e:	00003617          	auipc	a2,0x3
ffffffffc0201e62:	c3260613          	addi	a2,a2,-974 # ffffffffc0204a90 <etext+0xd08>
ffffffffc0201e66:	10c00593          	li	a1,268
ffffffffc0201e6a:	00003517          	auipc	a0,0x3
ffffffffc0201e6e:	d1650513          	addi	a0,a0,-746 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0201e72:	d94fe0ef          	jal	ffffffffc0200406 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e76:	86aa                	mv	a3,a0
ffffffffc0201e78:	00003617          	auipc	a2,0x3
ffffffffc0201e7c:	c1860613          	addi	a2,a2,-1000 # ffffffffc0204a90 <etext+0xd08>
ffffffffc0201e80:	10600593          	li	a1,262
ffffffffc0201e84:	00003517          	auipc	a0,0x3
ffffffffc0201e88:	cfc50513          	addi	a0,a0,-772 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0201e8c:	d7afe0ef          	jal	ffffffffc0200406 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e90:	00003617          	auipc	a2,0x3
ffffffffc0201e94:	c0060613          	addi	a2,a2,-1024 # ffffffffc0204a90 <etext+0xd08>
ffffffffc0201e98:	11b00593          	li	a1,283
ffffffffc0201e9c:	00003517          	auipc	a0,0x3
ffffffffc0201ea0:	ce450513          	addi	a0,a0,-796 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0201ea4:	d62fe0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0201ea8 <get_page>:

// get_page - 使用PDT pgdir获取线性地址la相关的Page结构
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc0201ea8:	1141                	addi	sp,sp,-16
ffffffffc0201eaa:	e022                	sd	s0,0(sp)
ffffffffc0201eac:	8432                	mv	s0,a2
    // 获取页表条目
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201eae:	4601                	li	a2,0
{
ffffffffc0201eb0:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201eb2:	d99ff0ef          	jal	ffffffffc0201c4a <get_pte>
    // 如果需要存储pte指针
    if (ptep_store != NULL)
ffffffffc0201eb6:	c011                	beqz	s0,ffffffffc0201eba <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0201eb8:	e008                	sd	a0,0(s0)
    }
    // 如果pte存在且有效，返回对应的页面
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0201eba:	c511                	beqz	a0,ffffffffc0201ec6 <get_page+0x1e>
ffffffffc0201ebc:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201ebe:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0201ec0:	0017f713          	andi	a4,a5,1
ffffffffc0201ec4:	e709                	bnez	a4,ffffffffc0201ece <get_page+0x26>
}
ffffffffc0201ec6:	60a2                	ld	ra,8(sp)
ffffffffc0201ec8:	6402                	ld	s0,0(sp)
ffffffffc0201eca:	0141                	addi	sp,sp,16
ffffffffc0201ecc:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0201ece:	0000b717          	auipc	a4,0xb
ffffffffc0201ed2:	5f273703          	ld	a4,1522(a4) # ffffffffc020d4c0 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ed6:	078a                	slli	a5,a5,0x2
ffffffffc0201ed8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201eda:	00e7ff63          	bgeu	a5,a4,ffffffffc0201ef8 <get_page+0x50>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ede:	0000b517          	auipc	a0,0xb
ffffffffc0201ee2:	5ea53503          	ld	a0,1514(a0) # ffffffffc020d4c8 <pages>
ffffffffc0201ee6:	60a2                	ld	ra,8(sp)
ffffffffc0201ee8:	6402                	ld	s0,0(sp)
ffffffffc0201eea:	079a                	slli	a5,a5,0x6
ffffffffc0201eec:	fe000737          	lui	a4,0xfe000
ffffffffc0201ef0:	97ba                	add	a5,a5,a4
ffffffffc0201ef2:	953e                	add	a0,a0,a5
ffffffffc0201ef4:	0141                	addi	sp,sp,16
ffffffffc0201ef6:	8082                	ret
ffffffffc0201ef8:	c8fff0ef          	jal	ffffffffc0201b86 <pa2page.part.0>

ffffffffc0201efc <page_remove>:
    }
}

// page_remove - 释放与线性地址la相关且具有已验证pte的Page
void page_remove(pde_t *pgdir, uintptr_t la)
{
ffffffffc0201efc:	1101                	addi	sp,sp,-32
    // 获取页表条目
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201efe:	4601                	li	a2,0
{
ffffffffc0201f00:	e822                	sd	s0,16(sp)
ffffffffc0201f02:	ec06                	sd	ra,24(sp)
ffffffffc0201f04:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201f06:	d45ff0ef          	jal	ffffffffc0201c4a <get_pte>
    if (ptep != NULL)
ffffffffc0201f0a:	c511                	beqz	a0,ffffffffc0201f16 <page_remove+0x1a>
    if (*ptep & PTE_V)
ffffffffc0201f0c:	6118                	ld	a4,0(a0)
ffffffffc0201f0e:	87aa                	mv	a5,a0
ffffffffc0201f10:	00177693          	andi	a3,a4,1
ffffffffc0201f14:	e689                	bnez	a3,ffffffffc0201f1e <page_remove+0x22>
    {
        // 移除页面
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201f16:	60e2                	ld	ra,24(sp)
ffffffffc0201f18:	6442                	ld	s0,16(sp)
ffffffffc0201f1a:	6105                	addi	sp,sp,32
ffffffffc0201f1c:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0201f1e:	0000b697          	auipc	a3,0xb
ffffffffc0201f22:	5a26b683          	ld	a3,1442(a3) # ffffffffc020d4c0 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0201f26:	070a                	slli	a4,a4,0x2
ffffffffc0201f28:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0201f2a:	06d77563          	bgeu	a4,a3,ffffffffc0201f94 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f2e:	0000b517          	auipc	a0,0xb
ffffffffc0201f32:	59a53503          	ld	a0,1434(a0) # ffffffffc020d4c8 <pages>
ffffffffc0201f36:	071a                	slli	a4,a4,0x6
ffffffffc0201f38:	fe0006b7          	lui	a3,0xfe000
ffffffffc0201f3c:	9736                	add	a4,a4,a3
ffffffffc0201f3e:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc0201f40:	4118                	lw	a4,0(a0)
ffffffffc0201f42:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3ddf2b0f>
ffffffffc0201f44:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0201f46:	cb09                	beqz	a4,ffffffffc0201f58 <page_remove+0x5c>
        *ptep = 0;
ffffffffc0201f48:	0007b023          	sd	zero,0(a5)
// tlb_invalidate - 使TLB条目失效，但仅当正在编辑的页表是处理器当前使用的页表时
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    // flush_tlb();  // 刷新整个TLB，有更好的方法吗？
    // 使用sfence.vma指令刷新指定地址的TLB条目
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201f4c:	12040073          	sfence.vma	s0
}
ffffffffc0201f50:	60e2                	ld	ra,24(sp)
ffffffffc0201f52:	6442                	ld	s0,16(sp)
ffffffffc0201f54:	6105                	addi	sp,sp,32
ffffffffc0201f56:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f58:	10002773          	csrr	a4,sstatus
ffffffffc0201f5c:	8b09                	andi	a4,a4,2
ffffffffc0201f5e:	eb19                	bnez	a4,ffffffffc0201f74 <page_remove+0x78>
        pmm_manager->free_pages(base, n);
ffffffffc0201f60:	0000b717          	auipc	a4,0xb
ffffffffc0201f64:	54073703          	ld	a4,1344(a4) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201f68:	4585                	li	a1,1
ffffffffc0201f6a:	e03e                	sd	a5,0(sp)
ffffffffc0201f6c:	7318                	ld	a4,32(a4)
ffffffffc0201f6e:	9702                	jalr	a4
    if (flag) {
ffffffffc0201f70:	6782                	ld	a5,0(sp)
ffffffffc0201f72:	bfd9                	j	ffffffffc0201f48 <page_remove+0x4c>
        intr_disable();
ffffffffc0201f74:	e43e                	sd	a5,8(sp)
ffffffffc0201f76:	e02a                	sd	a0,0(sp)
ffffffffc0201f78:	8fdfe0ef          	jal	ffffffffc0200874 <intr_disable>
ffffffffc0201f7c:	0000b717          	auipc	a4,0xb
ffffffffc0201f80:	52473703          	ld	a4,1316(a4) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0201f84:	6502                	ld	a0,0(sp)
ffffffffc0201f86:	4585                	li	a1,1
ffffffffc0201f88:	7318                	ld	a4,32(a4)
ffffffffc0201f8a:	9702                	jalr	a4
        intr_enable();
ffffffffc0201f8c:	8e3fe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0201f90:	67a2                	ld	a5,8(sp)
ffffffffc0201f92:	bf5d                	j	ffffffffc0201f48 <page_remove+0x4c>
ffffffffc0201f94:	bf3ff0ef          	jal	ffffffffc0201b86 <pa2page.part.0>

ffffffffc0201f98 <page_insert>:
{
ffffffffc0201f98:	7139                	addi	sp,sp,-64
ffffffffc0201f9a:	f426                	sd	s1,40(sp)
ffffffffc0201f9c:	84b2                	mv	s1,a2
ffffffffc0201f9e:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201fa0:	4605                	li	a2,1
{
ffffffffc0201fa2:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201fa4:	85a6                	mv	a1,s1
{
ffffffffc0201fa6:	fc06                	sd	ra,56(sp)
ffffffffc0201fa8:	e436                	sd	a3,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201faa:	ca1ff0ef          	jal	ffffffffc0201c4a <get_pte>
    if (ptep == NULL)
ffffffffc0201fae:	cd61                	beqz	a0,ffffffffc0202086 <page_insert+0xee>
    page->ref += 1;
ffffffffc0201fb0:	400c                	lw	a1,0(s0)
    if (*ptep & PTE_V)
ffffffffc0201fb2:	611c                	ld	a5,0(a0)
ffffffffc0201fb4:	66a2                	ld	a3,8(sp)
ffffffffc0201fb6:	0015861b          	addiw	a2,a1,1 # 1001 <kern_entry-0xffffffffc01fefff>
ffffffffc0201fba:	c010                	sw	a2,0(s0)
ffffffffc0201fbc:	0017f613          	andi	a2,a5,1
ffffffffc0201fc0:	872a                	mv	a4,a0
ffffffffc0201fc2:	e61d                	bnez	a2,ffffffffc0201ff0 <page_insert+0x58>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fc4:	0000b617          	auipc	a2,0xb
ffffffffc0201fc8:	50463603          	ld	a2,1284(a2) # ffffffffc020d4c8 <pages>
    return page - pages + nbase;
ffffffffc0201fcc:	8c11                	sub	s0,s0,a2
ffffffffc0201fce:	8419                	srai	s0,s0,0x6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fd0:	200007b7          	lui	a5,0x20000
ffffffffc0201fd4:	042a                	slli	s0,s0,0xa
ffffffffc0201fd6:	943e                	add	s0,s0,a5
ffffffffc0201fd8:	8ec1                	or	a3,a3,s0
ffffffffc0201fda:	0016e693          	ori	a3,a3,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201fde:	e314                	sd	a3,0(a4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201fe0:	12048073          	sfence.vma	s1
    return 0;
ffffffffc0201fe4:	4501                	li	a0,0
}
ffffffffc0201fe6:	70e2                	ld	ra,56(sp)
ffffffffc0201fe8:	7442                	ld	s0,48(sp)
ffffffffc0201fea:	74a2                	ld	s1,40(sp)
ffffffffc0201fec:	6121                	addi	sp,sp,64
ffffffffc0201fee:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0201ff0:	0000b617          	auipc	a2,0xb
ffffffffc0201ff4:	4d063603          	ld	a2,1232(a2) # ffffffffc020d4c0 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ff8:	078a                	slli	a5,a5,0x2
ffffffffc0201ffa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0201ffc:	08c7f763          	bgeu	a5,a2,ffffffffc020208a <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202000:	0000b617          	auipc	a2,0xb
ffffffffc0202004:	4c863603          	ld	a2,1224(a2) # ffffffffc020d4c8 <pages>
ffffffffc0202008:	fe000537          	lui	a0,0xfe000
ffffffffc020200c:	079a                	slli	a5,a5,0x6
ffffffffc020200e:	97aa                	add	a5,a5,a0
ffffffffc0202010:	00f60533          	add	a0,a2,a5
        if (p == page)
ffffffffc0202014:	00a40963          	beq	s0,a0,ffffffffc0202026 <page_insert+0x8e>
    page->ref -= 1;
ffffffffc0202018:	411c                	lw	a5,0(a0)
ffffffffc020201a:	37fd                	addiw	a5,a5,-1 # 1fffffff <kern_entry-0xffffffffa0200001>
ffffffffc020201c:	c11c                	sw	a5,0(a0)
        if (page_ref(page) == 0)
ffffffffc020201e:	c791                	beqz	a5,ffffffffc020202a <page_insert+0x92>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202020:	12048073          	sfence.vma	s1
}
ffffffffc0202024:	b765                	j	ffffffffc0201fcc <page_insert+0x34>
ffffffffc0202026:	c00c                	sw	a1,0(s0)
    return page->ref;
ffffffffc0202028:	b755                	j	ffffffffc0201fcc <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020202a:	100027f3          	csrr	a5,sstatus
ffffffffc020202e:	8b89                	andi	a5,a5,2
ffffffffc0202030:	e39d                	bnez	a5,ffffffffc0202056 <page_insert+0xbe>
        pmm_manager->free_pages(base, n);
ffffffffc0202032:	0000b797          	auipc	a5,0xb
ffffffffc0202036:	46e7b783          	ld	a5,1134(a5) # ffffffffc020d4a0 <pmm_manager>
ffffffffc020203a:	4585                	li	a1,1
ffffffffc020203c:	e83a                	sd	a4,16(sp)
ffffffffc020203e:	739c                	ld	a5,32(a5)
ffffffffc0202040:	e436                	sd	a3,8(sp)
ffffffffc0202042:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202044:	0000b617          	auipc	a2,0xb
ffffffffc0202048:	48463603          	ld	a2,1156(a2) # ffffffffc020d4c8 <pages>
ffffffffc020204c:	66a2                	ld	a3,8(sp)
ffffffffc020204e:	6742                	ld	a4,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202050:	12048073          	sfence.vma	s1
ffffffffc0202054:	bfa5                	j	ffffffffc0201fcc <page_insert+0x34>
        intr_disable();
ffffffffc0202056:	ec3a                	sd	a4,24(sp)
ffffffffc0202058:	e836                	sd	a3,16(sp)
ffffffffc020205a:	e42a                	sd	a0,8(sp)
ffffffffc020205c:	819fe0ef          	jal	ffffffffc0200874 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202060:	0000b797          	auipc	a5,0xb
ffffffffc0202064:	4407b783          	ld	a5,1088(a5) # ffffffffc020d4a0 <pmm_manager>
ffffffffc0202068:	6522                	ld	a0,8(sp)
ffffffffc020206a:	4585                	li	a1,1
ffffffffc020206c:	739c                	ld	a5,32(a5)
ffffffffc020206e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202070:	ffefe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0202074:	0000b617          	auipc	a2,0xb
ffffffffc0202078:	45463603          	ld	a2,1108(a2) # ffffffffc020d4c8 <pages>
ffffffffc020207c:	6762                	ld	a4,24(sp)
ffffffffc020207e:	66c2                	ld	a3,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202080:	12048073          	sfence.vma	s1
ffffffffc0202084:	b7a1                	j	ffffffffc0201fcc <page_insert+0x34>
        return -E_NO_MEM;  // 内存不足
ffffffffc0202086:	5571                	li	a0,-4
ffffffffc0202088:	bfb9                	j	ffffffffc0201fe6 <page_insert+0x4e>
ffffffffc020208a:	afdff0ef          	jal	ffffffffc0201b86 <pa2page.part.0>

ffffffffc020208e <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;    // 使用最佳适应内存管理器
ffffffffc020208e:	00003797          	auipc	a5,0x3
ffffffffc0202092:	60a78793          	addi	a5,a5,1546 # ffffffffc0205698 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202096:	638c                	ld	a1,0(a5)
{
ffffffffc0202098:	7159                	addi	sp,sp,-112
ffffffffc020209a:	f486                	sd	ra,104(sp)
ffffffffc020209c:	e8ca                	sd	s2,80(sp)
ffffffffc020209e:	e4ce                	sd	s3,72(sp)
ffffffffc02020a0:	f85a                	sd	s6,48(sp)
ffffffffc02020a2:	f0a2                	sd	s0,96(sp)
ffffffffc02020a4:	eca6                	sd	s1,88(sp)
ffffffffc02020a6:	e0d2                	sd	s4,64(sp)
ffffffffc02020a8:	fc56                	sd	s5,56(sp)
ffffffffc02020aa:	f45e                	sd	s7,40(sp)
ffffffffc02020ac:	f062                	sd	s8,32(sp)
ffffffffc02020ae:	ec66                	sd	s9,24(sp)
    pmm_manager = &best_fit_pmm_manager;    // 使用最佳适应内存管理器
ffffffffc02020b0:	0000bb17          	auipc	s6,0xb
ffffffffc02020b4:	3f0b0b13          	addi	s6,s6,1008 # ffffffffc020d4a0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02020b8:	00003517          	auipc	a0,0x3
ffffffffc02020bc:	ad850513          	addi	a0,a0,-1320 # ffffffffc0204b90 <etext+0xe08>
    pmm_manager = &best_fit_pmm_manager;    // 使用最佳适应内存管理器
ffffffffc02020c0:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02020c4:	8d0fe0ef          	jal	ffffffffc0200194 <cprintf>
    pmm_manager->init();  // 初始化内存管理器
ffffffffc02020c8:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02020cc:	0000b997          	auipc	s3,0xb
ffffffffc02020d0:	3ec98993          	addi	s3,s3,1004 # ffffffffc020d4b8 <va_pa_offset>
    pmm_manager->init();  // 初始化内存管理器
ffffffffc02020d4:	679c                	ld	a5,8(a5)
ffffffffc02020d6:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02020d8:	57f5                	li	a5,-3
ffffffffc02020da:	07fa                	slli	a5,a5,0x1e
ffffffffc02020dc:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc02020e0:	f7afe0ef          	jal	ffffffffc020085a <get_memory_base>
ffffffffc02020e4:	892a                	mv	s2,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc02020e6:	f7efe0ef          	jal	ffffffffc0200864 <get_memory_size>
    if (mem_size == 0) {
ffffffffc02020ea:	70050e63          	beqz	a0,ffffffffc0202806 <pmm_init+0x778>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc02020ee:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02020f0:	00003517          	auipc	a0,0x3
ffffffffc02020f4:	ad850513          	addi	a0,a0,-1320 # ffffffffc0204bc8 <etext+0xe40>
ffffffffc02020f8:	89cfe0ef          	jal	ffffffffc0200194 <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc02020fc:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202100:	864a                	mv	a2,s2
ffffffffc0202102:	85a6                	mv	a1,s1
ffffffffc0202104:	fff40693          	addi	a3,s0,-1
ffffffffc0202108:	00003517          	auipc	a0,0x3
ffffffffc020210c:	ad850513          	addi	a0,a0,-1320 # ffffffffc0204be0 <etext+0xe58>
ffffffffc0202110:	884fe0ef          	jal	ffffffffc0200194 <cprintf>
    if (maxpa > KERNTOP)
ffffffffc0202114:	c80007b7          	lui	a5,0xc8000
ffffffffc0202118:	8522                	mv	a0,s0
ffffffffc020211a:	5287ed63          	bltu	a5,s0,ffffffffc0202654 <pmm_init+0x5c6>
ffffffffc020211e:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202120:	0000c617          	auipc	a2,0xc
ffffffffc0202124:	3cf60613          	addi	a2,a2,975 # ffffffffc020e4ef <end+0xfff>
ffffffffc0202128:	8e7d                	and	a2,a2,a5
    npage = maxpa / PGSIZE;
ffffffffc020212a:	8131                	srli	a0,a0,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020212c:	0000bb97          	auipc	s7,0xb
ffffffffc0202130:	39cb8b93          	addi	s7,s7,924 # ffffffffc020d4c8 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202134:	0000b497          	auipc	s1,0xb
ffffffffc0202138:	38c48493          	addi	s1,s1,908 # ffffffffc020d4c0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020213c:	00cbb023          	sd	a2,0(s7)
    npage = maxpa / PGSIZE;
ffffffffc0202140:	e088                	sd	a0,0(s1)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202142:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202146:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202148:	02f50763          	beq	a0,a5,ffffffffc0202176 <pmm_init+0xe8>
ffffffffc020214c:	4701                	li	a4,0
ffffffffc020214e:	4585                	li	a1,1
ffffffffc0202150:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc0202154:	00671793          	slli	a5,a4,0x6
ffffffffc0202158:	97b2                	add	a5,a5,a2
ffffffffc020215a:	07a1                	addi	a5,a5,8 # 80008 <kern_entry-0xffffffffc017fff8>
ffffffffc020215c:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202160:	6088                	ld	a0,0(s1)
ffffffffc0202162:	0705                	addi	a4,a4,1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202164:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202168:	00d507b3          	add	a5,a0,a3
ffffffffc020216c:	fef764e3          	bltu	a4,a5,ffffffffc0202154 <pmm_init+0xc6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202170:	079a                	slli	a5,a5,0x6
ffffffffc0202172:	00f606b3          	add	a3,a2,a5
ffffffffc0202176:	c02007b7          	lui	a5,0xc0200
ffffffffc020217a:	16f6eee3          	bltu	a3,a5,ffffffffc0202af6 <pmm_init+0xa68>
ffffffffc020217e:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0202182:	77fd                	lui	a5,0xfffff
ffffffffc0202184:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202186:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202188:	4e86ed63          	bltu	a3,s0,ffffffffc0202682 <pmm_init+0x5f4>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc020218c:	00003517          	auipc	a0,0x3
ffffffffc0202190:	a7c50513          	addi	a0,a0,-1412 # ffffffffc0204c08 <etext+0xe80>
ffffffffc0202194:	800fe0ef          	jal	ffffffffc0200194 <cprintf>
}

// check_alloc_page - 检查页面分配功能
static void check_alloc_page(void)
{
    pmm_manager->check();  // 调用内存管理器的检查函数
ffffffffc0202198:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020219c:	0000b917          	auipc	s2,0xb
ffffffffc02021a0:	31490913          	addi	s2,s2,788 # ffffffffc020d4b0 <boot_pgdir_va>
    pmm_manager->check();  // 调用内存管理器的检查函数
ffffffffc02021a4:	7b9c                	ld	a5,48(a5)
ffffffffc02021a6:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02021a8:	00003517          	auipc	a0,0x3
ffffffffc02021ac:	a7850513          	addi	a0,a0,-1416 # ffffffffc0204c20 <etext+0xe98>
ffffffffc02021b0:	fe5fd0ef          	jal	ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02021b4:	00006697          	auipc	a3,0x6
ffffffffc02021b8:	e4c68693          	addi	a3,a3,-436 # ffffffffc0208000 <boot_page_table_sv39>
ffffffffc02021bc:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02021c0:	c02007b7          	lui	a5,0xc0200
ffffffffc02021c4:	2af6eee3          	bltu	a3,a5,ffffffffc0202c80 <pmm_init+0xbf2>
ffffffffc02021c8:	0009b783          	ld	a5,0(s3)
ffffffffc02021cc:	8e9d                	sub	a3,a3,a5
ffffffffc02021ce:	0000b797          	auipc	a5,0xb
ffffffffc02021d2:	2cd7bd23          	sd	a3,730(a5) # ffffffffc020d4a8 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02021d6:	100027f3          	csrr	a5,sstatus
ffffffffc02021da:	8b89                	andi	a5,a5,2
ffffffffc02021dc:	48079963          	bnez	a5,ffffffffc020266e <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc02021e0:	000b3783          	ld	a5,0(s6)
ffffffffc02021e4:	779c                	ld	a5,40(a5)
ffffffffc02021e6:	9782                	jalr	a5
ffffffffc02021e8:	842a                	mv	s0,a0

    // 保存当前空闲页面数
    nr_free_store = nr_free_pages();

    // 各种断言检查
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02021ea:	6098                	ld	a4,0(s1)
ffffffffc02021ec:	c80007b7          	lui	a5,0xc8000
ffffffffc02021f0:	83b1                	srli	a5,a5,0xc
ffffffffc02021f2:	66e7e663          	bltu	a5,a4,ffffffffc020285e <pmm_init+0x7d0>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02021f6:	00093503          	ld	a0,0(s2)
ffffffffc02021fa:	64050263          	beqz	a0,ffffffffc020283e <pmm_init+0x7b0>
ffffffffc02021fe:	03451793          	slli	a5,a0,0x34
ffffffffc0202202:	62079e63          	bnez	a5,ffffffffc020283e <pmm_init+0x7b0>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202206:	4601                	li	a2,0
ffffffffc0202208:	4581                	li	a1,0
ffffffffc020220a:	c9fff0ef          	jal	ffffffffc0201ea8 <get_page>
ffffffffc020220e:	240519e3          	bnez	a0,ffffffffc0202c60 <pmm_init+0xbd2>
ffffffffc0202212:	100027f3          	csrr	a5,sstatus
ffffffffc0202216:	8b89                	andi	a5,a5,2
ffffffffc0202218:	44079063          	bnez	a5,ffffffffc0202658 <pmm_init+0x5ca>
        page = pmm_manager->alloc_pages(n);
ffffffffc020221c:	000b3783          	ld	a5,0(s6)
ffffffffc0202220:	4505                	li	a0,1
ffffffffc0202222:	6f9c                	ld	a5,24(a5)
ffffffffc0202224:	9782                	jalr	a5
ffffffffc0202226:	8a2a                	mv	s4,a0

    // 测试页面插入和获取
    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202228:	00093503          	ld	a0,0(s2)
ffffffffc020222c:	4681                	li	a3,0
ffffffffc020222e:	4601                	li	a2,0
ffffffffc0202230:	85d2                	mv	a1,s4
ffffffffc0202232:	d67ff0ef          	jal	ffffffffc0201f98 <page_insert>
ffffffffc0202236:	280511e3          	bnez	a0,ffffffffc0202cb8 <pmm_init+0xc2a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc020223a:	00093503          	ld	a0,0(s2)
ffffffffc020223e:	4601                	li	a2,0
ffffffffc0202240:	4581                	li	a1,0
ffffffffc0202242:	a09ff0ef          	jal	ffffffffc0201c4a <get_pte>
ffffffffc0202246:	240509e3          	beqz	a0,ffffffffc0202c98 <pmm_init+0xc0a>
    assert(pte2page(*ptep) == p1);
ffffffffc020224a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc020224c:	0017f713          	andi	a4,a5,1
ffffffffc0202250:	58070f63          	beqz	a4,ffffffffc02027ee <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0202254:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202256:	078a                	slli	a5,a5,0x2
ffffffffc0202258:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020225a:	58e7f863          	bgeu	a5,a4,ffffffffc02027ea <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc020225e:	000bb683          	ld	a3,0(s7)
ffffffffc0202262:	079a                	slli	a5,a5,0x6
ffffffffc0202264:	fe000637          	lui	a2,0xfe000
ffffffffc0202268:	97b2                	add	a5,a5,a2
ffffffffc020226a:	97b6                	add	a5,a5,a3
ffffffffc020226c:	14fa1ae3          	bne	s4,a5,ffffffffc0202bc0 <pmm_init+0xb32>
    assert(page_ref(p1) == 1);
ffffffffc0202270:	000a2683          	lw	a3,0(s4)
ffffffffc0202274:	4785                	li	a5,1
ffffffffc0202276:	12f695e3          	bne	a3,a5,ffffffffc0202ba0 <pmm_init+0xb12>

    // 测试页表遍历
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020227a:	00093503          	ld	a0,0(s2)
ffffffffc020227e:	77fd                	lui	a5,0xfffff
ffffffffc0202280:	6114                	ld	a3,0(a0)
ffffffffc0202282:	068a                	slli	a3,a3,0x2
ffffffffc0202284:	8efd                	and	a3,a3,a5
ffffffffc0202286:	00c6d613          	srli	a2,a3,0xc
ffffffffc020228a:	0ee67fe3          	bgeu	a2,a4,ffffffffc0202b88 <pmm_init+0xafa>
ffffffffc020228e:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202292:	96e2                	add	a3,a3,s8
ffffffffc0202294:	0006ba83          	ld	s5,0(a3)
ffffffffc0202298:	0a8a                	slli	s5,s5,0x2
ffffffffc020229a:	00fafab3          	and	s5,s5,a5
ffffffffc020229e:	00cad793          	srli	a5,s5,0xc
ffffffffc02022a2:	0ce7f6e3          	bgeu	a5,a4,ffffffffc0202b6e <pmm_init+0xae0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02022a6:	4601                	li	a2,0
ffffffffc02022a8:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022aa:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02022ac:	99fff0ef          	jal	ffffffffc0201c4a <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022b0:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02022b2:	05851ee3          	bne	a0,s8,ffffffffc0202b0e <pmm_init+0xa80>
ffffffffc02022b6:	100027f3          	csrr	a5,sstatus
ffffffffc02022ba:	8b89                	andi	a5,a5,2
ffffffffc02022bc:	3e079b63          	bnez	a5,ffffffffc02026b2 <pmm_init+0x624>
        page = pmm_manager->alloc_pages(n);
ffffffffc02022c0:	000b3783          	ld	a5,0(s6)
ffffffffc02022c4:	4505                	li	a0,1
ffffffffc02022c6:	6f9c                	ld	a5,24(a5)
ffffffffc02022c8:	9782                	jalr	a5
ffffffffc02022ca:	8c2a                	mv	s8,a0

    // 测试用户权限
    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02022cc:	00093503          	ld	a0,0(s2)
ffffffffc02022d0:	46d1                	li	a3,20
ffffffffc02022d2:	6605                	lui	a2,0x1
ffffffffc02022d4:	85e2                	mv	a1,s8
ffffffffc02022d6:	cc3ff0ef          	jal	ffffffffc0201f98 <page_insert>
ffffffffc02022da:	06051ae3          	bnez	a0,ffffffffc0202b4e <pmm_init+0xac0>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02022de:	00093503          	ld	a0,0(s2)
ffffffffc02022e2:	4601                	li	a2,0
ffffffffc02022e4:	6585                	lui	a1,0x1
ffffffffc02022e6:	965ff0ef          	jal	ffffffffc0201c4a <get_pte>
ffffffffc02022ea:	040502e3          	beqz	a0,ffffffffc0202b2e <pmm_init+0xaa0>
    assert(*ptep & PTE_U);
ffffffffc02022ee:	611c                	ld	a5,0(a0)
ffffffffc02022f0:	0107f713          	andi	a4,a5,16
ffffffffc02022f4:	7e070163          	beqz	a4,ffffffffc0202ad6 <pmm_init+0xa48>
    assert(*ptep & PTE_W);
ffffffffc02022f8:	8b91                	andi	a5,a5,4
ffffffffc02022fa:	7a078e63          	beqz	a5,ffffffffc0202ab6 <pmm_init+0xa28>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc02022fe:	00093503          	ld	a0,0(s2)
ffffffffc0202302:	611c                	ld	a5,0(a0)
ffffffffc0202304:	8bc1                	andi	a5,a5,16
ffffffffc0202306:	78078863          	beqz	a5,ffffffffc0202a96 <pmm_init+0xa08>
    assert(page_ref(p2) == 1);
ffffffffc020230a:	000c2703          	lw	a4,0(s8)
ffffffffc020230e:	4785                	li	a5,1
ffffffffc0202310:	76f71363          	bne	a4,a5,ffffffffc0202a76 <pmm_init+0x9e8>

    // 测试页面替换
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202314:	4681                	li	a3,0
ffffffffc0202316:	6605                	lui	a2,0x1
ffffffffc0202318:	85d2                	mv	a1,s4
ffffffffc020231a:	c7fff0ef          	jal	ffffffffc0201f98 <page_insert>
ffffffffc020231e:	72051c63          	bnez	a0,ffffffffc0202a56 <pmm_init+0x9c8>
    assert(page_ref(p1) == 2);
ffffffffc0202322:	000a2703          	lw	a4,0(s4)
ffffffffc0202326:	4789                	li	a5,2
ffffffffc0202328:	70f71763          	bne	a4,a5,ffffffffc0202a36 <pmm_init+0x9a8>
    assert(page_ref(p2) == 0);
ffffffffc020232c:	000c2783          	lw	a5,0(s8)
ffffffffc0202330:	6e079363          	bnez	a5,ffffffffc0202a16 <pmm_init+0x988>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202334:	00093503          	ld	a0,0(s2)
ffffffffc0202338:	4601                	li	a2,0
ffffffffc020233a:	6585                	lui	a1,0x1
ffffffffc020233c:	90fff0ef          	jal	ffffffffc0201c4a <get_pte>
ffffffffc0202340:	6a050b63          	beqz	a0,ffffffffc02029f6 <pmm_init+0x968>
    assert(pte2page(*ptep) == p1);
ffffffffc0202344:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202346:	00177793          	andi	a5,a4,1
ffffffffc020234a:	4a078263          	beqz	a5,ffffffffc02027ee <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc020234e:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202350:	00271793          	slli	a5,a4,0x2
ffffffffc0202354:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202356:	48d7fa63          	bgeu	a5,a3,ffffffffc02027ea <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc020235a:	000bb683          	ld	a3,0(s7)
ffffffffc020235e:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202362:	97d6                	add	a5,a5,s5
ffffffffc0202364:	079a                	slli	a5,a5,0x6
ffffffffc0202366:	97b6                	add	a5,a5,a3
ffffffffc0202368:	66fa1763          	bne	s4,a5,ffffffffc02029d6 <pmm_init+0x948>
    assert((*ptep & PTE_U) == 0);
ffffffffc020236c:	8b41                	andi	a4,a4,16
ffffffffc020236e:	64071463          	bnez	a4,ffffffffc02029b6 <pmm_init+0x928>

    // 测试页面移除
    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202372:	00093503          	ld	a0,0(s2)
ffffffffc0202376:	4581                	li	a1,0
ffffffffc0202378:	b85ff0ef          	jal	ffffffffc0201efc <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc020237c:	000a2c83          	lw	s9,0(s4)
ffffffffc0202380:	4785                	li	a5,1
ffffffffc0202382:	60fc9a63          	bne	s9,a5,ffffffffc0202996 <pmm_init+0x908>
    assert(page_ref(p2) == 0);
ffffffffc0202386:	000c2783          	lw	a5,0(s8)
ffffffffc020238a:	5e079663          	bnez	a5,ffffffffc0202976 <pmm_init+0x8e8>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc020238e:	00093503          	ld	a0,0(s2)
ffffffffc0202392:	6585                	lui	a1,0x1
ffffffffc0202394:	b69ff0ef          	jal	ffffffffc0201efc <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202398:	000a2783          	lw	a5,0(s4)
ffffffffc020239c:	52079d63          	bnez	a5,ffffffffc02028d6 <pmm_init+0x848>
    assert(page_ref(p2) == 0);
ffffffffc02023a0:	000c2783          	lw	a5,0(s8)
ffffffffc02023a4:	50079963          	bnez	a5,ffffffffc02028b6 <pmm_init+0x828>

    // 检查页目录引用计数
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc02023a8:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc02023ac:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023ae:	000a3783          	ld	a5,0(s4)
ffffffffc02023b2:	078a                	slli	a5,a5,0x2
ffffffffc02023b4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02023b6:	42e7fa63          	bgeu	a5,a4,ffffffffc02027ea <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ba:	000bb503          	ld	a0,0(s7)
ffffffffc02023be:	97d6                	add	a5,a5,s5
ffffffffc02023c0:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc02023c2:	00f506b3          	add	a3,a0,a5
ffffffffc02023c6:	4294                	lw	a3,0(a3)
ffffffffc02023c8:	4d969763          	bne	a3,s9,ffffffffc0202896 <pmm_init+0x808>
    return page - pages + nbase;
ffffffffc02023cc:	8799                	srai	a5,a5,0x6
ffffffffc02023ce:	00080637          	lui	a2,0x80
ffffffffc02023d2:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02023d4:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02023d8:	4ae7f363          	bgeu	a5,a4,ffffffffc020287e <pmm_init+0x7f0>

    // 清理测试资源
    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc02023dc:	0009b783          	ld	a5,0(s3)
ffffffffc02023e0:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc02023e2:	639c                	ld	a5,0(a5)
ffffffffc02023e4:	078a                	slli	a5,a5,0x2
ffffffffc02023e6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02023e8:	40e7f163          	bgeu	a5,a4,ffffffffc02027ea <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02023ec:	8f91                	sub	a5,a5,a2
ffffffffc02023ee:	079a                	slli	a5,a5,0x6
ffffffffc02023f0:	953e                	add	a0,a0,a5
ffffffffc02023f2:	100027f3          	csrr	a5,sstatus
ffffffffc02023f6:	8b89                	andi	a5,a5,2
ffffffffc02023f8:	30079863          	bnez	a5,ffffffffc0202708 <pmm_init+0x67a>
        pmm_manager->free_pages(base, n);
ffffffffc02023fc:	000b3783          	ld	a5,0(s6)
ffffffffc0202400:	4585                	li	a1,1
ffffffffc0202402:	739c                	ld	a5,32(a5)
ffffffffc0202404:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202406:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc020240a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020240c:	078a                	slli	a5,a5,0x2
ffffffffc020240e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202410:	3ce7fd63          	bgeu	a5,a4,ffffffffc02027ea <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202414:	000bb503          	ld	a0,0(s7)
ffffffffc0202418:	fe000737          	lui	a4,0xfe000
ffffffffc020241c:	079a                	slli	a5,a5,0x6
ffffffffc020241e:	97ba                	add	a5,a5,a4
ffffffffc0202420:	953e                	add	a0,a0,a5
ffffffffc0202422:	100027f3          	csrr	a5,sstatus
ffffffffc0202426:	8b89                	andi	a5,a5,2
ffffffffc0202428:	2c079463          	bnez	a5,ffffffffc02026f0 <pmm_init+0x662>
ffffffffc020242c:	000b3783          	ld	a5,0(s6)
ffffffffc0202430:	4585                	li	a1,1
ffffffffc0202432:	739c                	ld	a5,32(a5)
ffffffffc0202434:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202436:	00093783          	ld	a5,0(s2)
ffffffffc020243a:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdf1b10>
    asm volatile("sfence.vma");
ffffffffc020243e:	12000073          	sfence.vma
ffffffffc0202442:	100027f3          	csrr	a5,sstatus
ffffffffc0202446:	8b89                	andi	a5,a5,2
ffffffffc0202448:	28079a63          	bnez	a5,ffffffffc02026dc <pmm_init+0x64e>
        ret = pmm_manager->nr_free_pages();
ffffffffc020244c:	000b3783          	ld	a5,0(s6)
ffffffffc0202450:	779c                	ld	a5,40(a5)
ffffffffc0202452:	9782                	jalr	a5
ffffffffc0202454:	8a2a                	mv	s4,a0
    flush_tlb();  // 刷新TLB

    // 验证空闲页面数恢复
    assert(nr_free_store == nr_free_pages());
ffffffffc0202456:	4d441063          	bne	s0,s4,ffffffffc0202916 <pmm_init+0x888>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020245a:	00003517          	auipc	a0,0x3
ffffffffc020245e:	b1650513          	addi	a0,a0,-1258 # ffffffffc0204f70 <etext+0x11e8>
ffffffffc0202462:	d33fd0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0202466:	100027f3          	csrr	a5,sstatus
ffffffffc020246a:	8b89                	andi	a5,a5,2
ffffffffc020246c:	24079e63          	bnez	a5,ffffffffc02026c8 <pmm_init+0x63a>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202470:	000b3783          	ld	a5,0(s6)
ffffffffc0202474:	779c                	ld	a5,40(a5)
ffffffffc0202476:	9782                	jalr	a5
ffffffffc0202478:	8c2a                	mv	s8,a0

    // 保存当前空闲页面数
    nr_free_store = nr_free_pages();

    // 检查内核地址空间的映射
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc020247a:	609c                	ld	a5,0(s1)
ffffffffc020247c:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202480:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202482:	00c79713          	slli	a4,a5,0xc
ffffffffc0202486:	6a85                	lui	s5,0x1
ffffffffc0202488:	02e47c63          	bgeu	s0,a4,ffffffffc02024c0 <pmm_init+0x432>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020248c:	00c45713          	srli	a4,s0,0xc
ffffffffc0202490:	30f77063          	bgeu	a4,a5,ffffffffc0202790 <pmm_init+0x702>
ffffffffc0202494:	0009b583          	ld	a1,0(s3)
ffffffffc0202498:	00093503          	ld	a0,0(s2)
ffffffffc020249c:	4601                	li	a2,0
ffffffffc020249e:	95a2                	add	a1,a1,s0
ffffffffc02024a0:	faaff0ef          	jal	ffffffffc0201c4a <get_pte>
ffffffffc02024a4:	32050363          	beqz	a0,ffffffffc02027ca <pmm_init+0x73c>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02024a8:	611c                	ld	a5,0(a0)
ffffffffc02024aa:	078a                	slli	a5,a5,0x2
ffffffffc02024ac:	0147f7b3          	and	a5,a5,s4
ffffffffc02024b0:	2e879d63          	bne	a5,s0,ffffffffc02027aa <pmm_init+0x71c>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc02024b4:	609c                	ld	a5,0(s1)
ffffffffc02024b6:	9456                	add	s0,s0,s5
ffffffffc02024b8:	00c79713          	slli	a4,a5,0xc
ffffffffc02024bc:	fce468e3          	bltu	s0,a4,ffffffffc020248c <pmm_init+0x3fe>
    }

    // 检查页目录条目
    assert(boot_pgdir_va[0] == 0);
ffffffffc02024c0:	00093783          	ld	a5,0(s2)
ffffffffc02024c4:	639c                	ld	a5,0(a5)
ffffffffc02024c6:	42079863          	bnez	a5,ffffffffc02028f6 <pmm_init+0x868>
ffffffffc02024ca:	100027f3          	csrr	a5,sstatus
ffffffffc02024ce:	8b89                	andi	a5,a5,2
ffffffffc02024d0:	24079863          	bnez	a5,ffffffffc0202720 <pmm_init+0x692>
        page = pmm_manager->alloc_pages(n);
ffffffffc02024d4:	000b3783          	ld	a5,0(s6)
ffffffffc02024d8:	4505                	li	a0,1
ffffffffc02024da:	6f9c                	ld	a5,24(a5)
ffffffffc02024dc:	9782                	jalr	a5
ffffffffc02024de:	842a                	mv	s0,a0

    // 测试页面共享
    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02024e0:	00093503          	ld	a0,0(s2)
ffffffffc02024e4:	4699                	li	a3,6
ffffffffc02024e6:	10000613          	li	a2,256
ffffffffc02024ea:	85a2                	mv	a1,s0
ffffffffc02024ec:	aadff0ef          	jal	ffffffffc0201f98 <page_insert>
ffffffffc02024f0:	46051363          	bnez	a0,ffffffffc0202956 <pmm_init+0x8c8>
    assert(page_ref(p) == 1);
ffffffffc02024f4:	4018                	lw	a4,0(s0)
ffffffffc02024f6:	4785                	li	a5,1
ffffffffc02024f8:	42f71f63          	bne	a4,a5,ffffffffc0202936 <pmm_init+0x8a8>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02024fc:	00093503          	ld	a0,0(s2)
ffffffffc0202500:	6605                	lui	a2,0x1
ffffffffc0202502:	10060613          	addi	a2,a2,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0202506:	4699                	li	a3,6
ffffffffc0202508:	85a2                	mv	a1,s0
ffffffffc020250a:	a8fff0ef          	jal	ffffffffc0201f98 <page_insert>
ffffffffc020250e:	72051963          	bnez	a0,ffffffffc0202c40 <pmm_init+0xbb2>
    assert(page_ref(p) == 2);
ffffffffc0202512:	4018                	lw	a4,0(s0)
ffffffffc0202514:	4789                	li	a5,2
ffffffffc0202516:	70f71563          	bne	a4,a5,ffffffffc0202c20 <pmm_init+0xb92>

    // 测试内存访问
    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc020251a:	00003597          	auipc	a1,0x3
ffffffffc020251e:	b9e58593          	addi	a1,a1,-1122 # ffffffffc02050b8 <etext+0x1330>
ffffffffc0202522:	10000513          	li	a0,256
ffffffffc0202526:	794010ef          	jal	ffffffffc0203cba <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020252a:	6585                	lui	a1,0x1
ffffffffc020252c:	10058593          	addi	a1,a1,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc0202530:	10000513          	li	a0,256
ffffffffc0202534:	798010ef          	jal	ffffffffc0203ccc <strcmp>
ffffffffc0202538:	6c051463          	bnez	a0,ffffffffc0202c00 <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc020253c:	000bb683          	ld	a3,0(s7)
ffffffffc0202540:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0202544:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc0202546:	40d406b3          	sub	a3,s0,a3
ffffffffc020254a:	8699                	srai	a3,a3,0x6
ffffffffc020254c:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc020254e:	00c69793          	slli	a5,a3,0xc
ffffffffc0202552:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202554:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202556:	32e7f463          	bgeu	a5,a4,ffffffffc020287e <pmm_init+0x7f0>

    // 测试字符串操作
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc020255a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc020255e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202562:	97b6                	add	a5,a5,a3
ffffffffc0202564:	10078023          	sb	zero,256(a5) # 80100 <kern_entry-0xffffffffc017ff00>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202568:	71e010ef          	jal	ffffffffc0203c86 <strlen>
ffffffffc020256c:	66051a63          	bnez	a0,ffffffffc0202be0 <pmm_init+0xb52>

    // 清理资源
    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202570:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202574:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202576:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fdf1b10>
ffffffffc020257a:	078a                	slli	a5,a5,0x2
ffffffffc020257c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020257e:	26e7f663          	bgeu	a5,a4,ffffffffc02027ea <pmm_init+0x75c>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202582:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202586:	2ee7fc63          	bgeu	a5,a4,ffffffffc020287e <pmm_init+0x7f0>
ffffffffc020258a:	0009b783          	ld	a5,0(s3)
ffffffffc020258e:	00f689b3          	add	s3,a3,a5
ffffffffc0202592:	100027f3          	csrr	a5,sstatus
ffffffffc0202596:	8b89                	andi	a5,a5,2
ffffffffc0202598:	1e079163          	bnez	a5,ffffffffc020277a <pmm_init+0x6ec>
        pmm_manager->free_pages(base, n);
ffffffffc020259c:	000b3783          	ld	a5,0(s6)
ffffffffc02025a0:	8522                	mv	a0,s0
ffffffffc02025a2:	4585                	li	a1,1
ffffffffc02025a4:	739c                	ld	a5,32(a5)
ffffffffc02025a6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02025a8:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage)
ffffffffc02025ac:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02025ae:	078a                	slli	a5,a5,0x2
ffffffffc02025b0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02025b2:	22e7fc63          	bgeu	a5,a4,ffffffffc02027ea <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02025b6:	000bb503          	ld	a0,0(s7)
ffffffffc02025ba:	fe000737          	lui	a4,0xfe000
ffffffffc02025be:	079a                	slli	a5,a5,0x6
ffffffffc02025c0:	97ba                	add	a5,a5,a4
ffffffffc02025c2:	953e                	add	a0,a0,a5
ffffffffc02025c4:	100027f3          	csrr	a5,sstatus
ffffffffc02025c8:	8b89                	andi	a5,a5,2
ffffffffc02025ca:	18079c63          	bnez	a5,ffffffffc0202762 <pmm_init+0x6d4>
ffffffffc02025ce:	000b3783          	ld	a5,0(s6)
ffffffffc02025d2:	4585                	li	a1,1
ffffffffc02025d4:	739c                	ld	a5,32(a5)
ffffffffc02025d6:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02025d8:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc02025dc:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02025de:	078a                	slli	a5,a5,0x2
ffffffffc02025e0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02025e2:	20e7f463          	bgeu	a5,a4,ffffffffc02027ea <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02025e6:	000bb503          	ld	a0,0(s7)
ffffffffc02025ea:	fe000737          	lui	a4,0xfe000
ffffffffc02025ee:	079a                	slli	a5,a5,0x6
ffffffffc02025f0:	97ba                	add	a5,a5,a4
ffffffffc02025f2:	953e                	add	a0,a0,a5
ffffffffc02025f4:	100027f3          	csrr	a5,sstatus
ffffffffc02025f8:	8b89                	andi	a5,a5,2
ffffffffc02025fa:	14079863          	bnez	a5,ffffffffc020274a <pmm_init+0x6bc>
ffffffffc02025fe:	000b3783          	ld	a5,0(s6)
ffffffffc0202602:	4585                	li	a1,1
ffffffffc0202604:	739c                	ld	a5,32(a5)
ffffffffc0202606:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202608:	00093783          	ld	a5,0(s2)
ffffffffc020260c:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202610:	12000073          	sfence.vma
ffffffffc0202614:	100027f3          	csrr	a5,sstatus
ffffffffc0202618:	8b89                	andi	a5,a5,2
ffffffffc020261a:	10079e63          	bnez	a5,ffffffffc0202736 <pmm_init+0x6a8>
        ret = pmm_manager->nr_free_pages();
ffffffffc020261e:	000b3783          	ld	a5,0(s6)
ffffffffc0202622:	779c                	ld	a5,40(a5)
ffffffffc0202624:	9782                	jalr	a5
ffffffffc0202626:	842a                	mv	s0,a0
    flush_tlb();

    // 验证空闲页面数恢复
    assert(nr_free_store == nr_free_pages());
ffffffffc0202628:	1e8c1b63          	bne	s8,s0,ffffffffc020281e <pmm_init+0x790>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020262c:	00003517          	auipc	a0,0x3
ffffffffc0202630:	b0450513          	addi	a0,a0,-1276 # ffffffffc0205130 <etext+0x13a8>
ffffffffc0202634:	b61fd0ef          	jal	ffffffffc0200194 <cprintf>
}
ffffffffc0202638:	7406                	ld	s0,96(sp)
ffffffffc020263a:	70a6                	ld	ra,104(sp)
ffffffffc020263c:	64e6                	ld	s1,88(sp)
ffffffffc020263e:	6946                	ld	s2,80(sp)
ffffffffc0202640:	69a6                	ld	s3,72(sp)
ffffffffc0202642:	6a06                	ld	s4,64(sp)
ffffffffc0202644:	7ae2                	ld	s5,56(sp)
ffffffffc0202646:	7b42                	ld	s6,48(sp)
ffffffffc0202648:	7ba2                	ld	s7,40(sp)
ffffffffc020264a:	7c02                	ld	s8,32(sp)
ffffffffc020264c:	6ce2                	ld	s9,24(sp)
ffffffffc020264e:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202650:	b70ff06f          	j	ffffffffc02019c0 <kmalloc_init>
    if (maxpa > KERNTOP)
ffffffffc0202654:	853e                	mv	a0,a5
ffffffffc0202656:	b4e1                	j	ffffffffc020211e <pmm_init+0x90>
        intr_disable();
ffffffffc0202658:	a1cfe0ef          	jal	ffffffffc0200874 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020265c:	000b3783          	ld	a5,0(s6)
ffffffffc0202660:	4505                	li	a0,1
ffffffffc0202662:	6f9c                	ld	a5,24(a5)
ffffffffc0202664:	9782                	jalr	a5
ffffffffc0202666:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202668:	a06fe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc020266c:	be75                	j	ffffffffc0202228 <pmm_init+0x19a>
        intr_disable();
ffffffffc020266e:	a06fe0ef          	jal	ffffffffc0200874 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202672:	000b3783          	ld	a5,0(s6)
ffffffffc0202676:	779c                	ld	a5,40(a5)
ffffffffc0202678:	9782                	jalr	a5
ffffffffc020267a:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020267c:	9f2fe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0202680:	b6ad                	j	ffffffffc02021ea <pmm_init+0x15c>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202682:	6705                	lui	a4,0x1
ffffffffc0202684:	177d                	addi	a4,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0202686:	96ba                	add	a3,a3,a4
ffffffffc0202688:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc020268a:	00c7d713          	srli	a4,a5,0xc
ffffffffc020268e:	14a77e63          	bgeu	a4,a0,ffffffffc02027ea <pmm_init+0x75c>
    pmm_manager->init_memmap(base, n);
ffffffffc0202692:	000b3683          	ld	a3,0(s6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202696:	8c1d                	sub	s0,s0,a5
    return &pages[PPN(pa) - nbase];
ffffffffc0202698:	071a                	slli	a4,a4,0x6
ffffffffc020269a:	fe0007b7          	lui	a5,0xfe000
ffffffffc020269e:	973e                	add	a4,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc02026a0:	6a9c                	ld	a5,16(a3)
ffffffffc02026a2:	00c45593          	srli	a1,s0,0xc
ffffffffc02026a6:	00e60533          	add	a0,a2,a4
ffffffffc02026aa:	9782                	jalr	a5
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc02026ac:	0009b583          	ld	a1,0(s3)
}
ffffffffc02026b0:	bcf1                	j	ffffffffc020218c <pmm_init+0xfe>
        intr_disable();
ffffffffc02026b2:	9c2fe0ef          	jal	ffffffffc0200874 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02026b6:	000b3783          	ld	a5,0(s6)
ffffffffc02026ba:	4505                	li	a0,1
ffffffffc02026bc:	6f9c                	ld	a5,24(a5)
ffffffffc02026be:	9782                	jalr	a5
ffffffffc02026c0:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02026c2:	9acfe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc02026c6:	b119                	j	ffffffffc02022cc <pmm_init+0x23e>
        intr_disable();
ffffffffc02026c8:	9acfe0ef          	jal	ffffffffc0200874 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc02026cc:	000b3783          	ld	a5,0(s6)
ffffffffc02026d0:	779c                	ld	a5,40(a5)
ffffffffc02026d2:	9782                	jalr	a5
ffffffffc02026d4:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc02026d6:	998fe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc02026da:	b345                	j	ffffffffc020247a <pmm_init+0x3ec>
        intr_disable();
ffffffffc02026dc:	998fe0ef          	jal	ffffffffc0200874 <intr_disable>
ffffffffc02026e0:	000b3783          	ld	a5,0(s6)
ffffffffc02026e4:	779c                	ld	a5,40(a5)
ffffffffc02026e6:	9782                	jalr	a5
ffffffffc02026e8:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc02026ea:	984fe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc02026ee:	b3a5                	j	ffffffffc0202456 <pmm_init+0x3c8>
ffffffffc02026f0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02026f2:	982fe0ef          	jal	ffffffffc0200874 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02026f6:	000b3783          	ld	a5,0(s6)
ffffffffc02026fa:	6522                	ld	a0,8(sp)
ffffffffc02026fc:	4585                	li	a1,1
ffffffffc02026fe:	739c                	ld	a5,32(a5)
ffffffffc0202700:	9782                	jalr	a5
        intr_enable();
ffffffffc0202702:	96cfe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0202706:	bb05                	j	ffffffffc0202436 <pmm_init+0x3a8>
ffffffffc0202708:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020270a:	96afe0ef          	jal	ffffffffc0200874 <intr_disable>
ffffffffc020270e:	000b3783          	ld	a5,0(s6)
ffffffffc0202712:	6522                	ld	a0,8(sp)
ffffffffc0202714:	4585                	li	a1,1
ffffffffc0202716:	739c                	ld	a5,32(a5)
ffffffffc0202718:	9782                	jalr	a5
        intr_enable();
ffffffffc020271a:	954fe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc020271e:	b1e5                	j	ffffffffc0202406 <pmm_init+0x378>
        intr_disable();
ffffffffc0202720:	954fe0ef          	jal	ffffffffc0200874 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202724:	000b3783          	ld	a5,0(s6)
ffffffffc0202728:	4505                	li	a0,1
ffffffffc020272a:	6f9c                	ld	a5,24(a5)
ffffffffc020272c:	9782                	jalr	a5
ffffffffc020272e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202730:	93efe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0202734:	b375                	j	ffffffffc02024e0 <pmm_init+0x452>
        intr_disable();
ffffffffc0202736:	93efe0ef          	jal	ffffffffc0200874 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020273a:	000b3783          	ld	a5,0(s6)
ffffffffc020273e:	779c                	ld	a5,40(a5)
ffffffffc0202740:	9782                	jalr	a5
ffffffffc0202742:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202744:	92afe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0202748:	b5c5                	j	ffffffffc0202628 <pmm_init+0x59a>
ffffffffc020274a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020274c:	928fe0ef          	jal	ffffffffc0200874 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202750:	000b3783          	ld	a5,0(s6)
ffffffffc0202754:	6522                	ld	a0,8(sp)
ffffffffc0202756:	4585                	li	a1,1
ffffffffc0202758:	739c                	ld	a5,32(a5)
ffffffffc020275a:	9782                	jalr	a5
        intr_enable();
ffffffffc020275c:	912fe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0202760:	b565                	j	ffffffffc0202608 <pmm_init+0x57a>
ffffffffc0202762:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202764:	910fe0ef          	jal	ffffffffc0200874 <intr_disable>
ffffffffc0202768:	000b3783          	ld	a5,0(s6)
ffffffffc020276c:	6522                	ld	a0,8(sp)
ffffffffc020276e:	4585                	li	a1,1
ffffffffc0202770:	739c                	ld	a5,32(a5)
ffffffffc0202772:	9782                	jalr	a5
        intr_enable();
ffffffffc0202774:	8fafe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc0202778:	b585                	j	ffffffffc02025d8 <pmm_init+0x54a>
        intr_disable();
ffffffffc020277a:	8fafe0ef          	jal	ffffffffc0200874 <intr_disable>
ffffffffc020277e:	000b3783          	ld	a5,0(s6)
ffffffffc0202782:	8522                	mv	a0,s0
ffffffffc0202784:	4585                	li	a1,1
ffffffffc0202786:	739c                	ld	a5,32(a5)
ffffffffc0202788:	9782                	jalr	a5
        intr_enable();
ffffffffc020278a:	8e4fe0ef          	jal	ffffffffc020086e <intr_enable>
ffffffffc020278e:	bd29                	j	ffffffffc02025a8 <pmm_init+0x51a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202790:	86a2                	mv	a3,s0
ffffffffc0202792:	00002617          	auipc	a2,0x2
ffffffffc0202796:	2fe60613          	addi	a2,a2,766 # ffffffffc0204a90 <etext+0xd08>
ffffffffc020279a:	1e800593          	li	a1,488
ffffffffc020279e:	00002517          	auipc	a0,0x2
ffffffffc02027a2:	3e250513          	addi	a0,a0,994 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc02027a6:	c61fd0ef          	jal	ffffffffc0200406 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02027aa:	00003697          	auipc	a3,0x3
ffffffffc02027ae:	82668693          	addi	a3,a3,-2010 # ffffffffc0204fd0 <etext+0x1248>
ffffffffc02027b2:	00002617          	auipc	a2,0x2
ffffffffc02027b6:	f9e60613          	addi	a2,a2,-98 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02027ba:	1e900593          	li	a1,489
ffffffffc02027be:	00002517          	auipc	a0,0x2
ffffffffc02027c2:	3c250513          	addi	a0,a0,962 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc02027c6:	c41fd0ef          	jal	ffffffffc0200406 <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02027ca:	00002697          	auipc	a3,0x2
ffffffffc02027ce:	7c668693          	addi	a3,a3,1990 # ffffffffc0204f90 <etext+0x1208>
ffffffffc02027d2:	00002617          	auipc	a2,0x2
ffffffffc02027d6:	f7e60613          	addi	a2,a2,-130 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02027da:	1e800593          	li	a1,488
ffffffffc02027de:	00002517          	auipc	a0,0x2
ffffffffc02027e2:	3a250513          	addi	a0,a0,930 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc02027e6:	c21fd0ef          	jal	ffffffffc0200406 <__panic>
ffffffffc02027ea:	b9cff0ef          	jal	ffffffffc0201b86 <pa2page.part.0>
        panic("pte2page called with invalid pte");
ffffffffc02027ee:	00002617          	auipc	a2,0x2
ffffffffc02027f2:	54260613          	addi	a2,a2,1346 # ffffffffc0204d30 <etext+0xfa8>
ffffffffc02027f6:	07f00593          	li	a1,127
ffffffffc02027fa:	00002517          	auipc	a0,0x2
ffffffffc02027fe:	2be50513          	addi	a0,a0,702 # ffffffffc0204ab8 <etext+0xd30>
ffffffffc0202802:	c05fd0ef          	jal	ffffffffc0200406 <__panic>
        panic("DTB memory info not available");  // 设备树内存信息不可用
ffffffffc0202806:	00002617          	auipc	a2,0x2
ffffffffc020280a:	3a260613          	addi	a2,a2,930 # ffffffffc0204ba8 <etext+0xe20>
ffffffffc020280e:	06b00593          	li	a1,107
ffffffffc0202812:	00002517          	auipc	a0,0x2
ffffffffc0202816:	36e50513          	addi	a0,a0,878 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc020281a:	bedfd0ef          	jal	ffffffffc0200406 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc020281e:	00002697          	auipc	a3,0x2
ffffffffc0202822:	72a68693          	addi	a3,a3,1834 # ffffffffc0204f48 <etext+0x11c0>
ffffffffc0202826:	00002617          	auipc	a2,0x2
ffffffffc020282a:	f2a60613          	addi	a2,a2,-214 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020282e:	20900593          	li	a1,521
ffffffffc0202832:	00002517          	auipc	a0,0x2
ffffffffc0202836:	34e50513          	addi	a0,a0,846 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc020283a:	bcdfd0ef          	jal	ffffffffc0200406 <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020283e:	00002697          	auipc	a3,0x2
ffffffffc0202842:	42268693          	addi	a3,a3,1058 # ffffffffc0204c60 <etext+0xed8>
ffffffffc0202846:	00002617          	auipc	a2,0x2
ffffffffc020284a:	f0a60613          	addi	a2,a2,-246 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020284e:	19f00593          	li	a1,415
ffffffffc0202852:	00002517          	auipc	a0,0x2
ffffffffc0202856:	32e50513          	addi	a0,a0,814 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc020285a:	badfd0ef          	jal	ffffffffc0200406 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020285e:	00002697          	auipc	a3,0x2
ffffffffc0202862:	3e268693          	addi	a3,a3,994 # ffffffffc0204c40 <etext+0xeb8>
ffffffffc0202866:	00002617          	auipc	a2,0x2
ffffffffc020286a:	eea60613          	addi	a2,a2,-278 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020286e:	19e00593          	li	a1,414
ffffffffc0202872:	00002517          	auipc	a0,0x2
ffffffffc0202876:	30e50513          	addi	a0,a0,782 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc020287a:	b8dfd0ef          	jal	ffffffffc0200406 <__panic>
    return KADDR(page2pa(page));
ffffffffc020287e:	00002617          	auipc	a2,0x2
ffffffffc0202882:	21260613          	addi	a2,a2,530 # ffffffffc0204a90 <etext+0xd08>
ffffffffc0202886:	07100593          	li	a1,113
ffffffffc020288a:	00002517          	auipc	a0,0x2
ffffffffc020288e:	22e50513          	addi	a0,a0,558 # ffffffffc0204ab8 <etext+0xd30>
ffffffffc0202892:	b75fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202896:	00002697          	auipc	a3,0x2
ffffffffc020289a:	68268693          	addi	a3,a3,1666 # ffffffffc0204f18 <etext+0x1190>
ffffffffc020289e:	00002617          	auipc	a2,0x2
ffffffffc02028a2:	eb260613          	addi	a2,a2,-334 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02028a6:	1cc00593          	li	a1,460
ffffffffc02028aa:	00002517          	auipc	a0,0x2
ffffffffc02028ae:	2d650513          	addi	a0,a0,726 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc02028b2:	b55fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02028b6:	00002697          	auipc	a3,0x2
ffffffffc02028ba:	61a68693          	addi	a3,a3,1562 # ffffffffc0204ed0 <etext+0x1148>
ffffffffc02028be:	00002617          	auipc	a2,0x2
ffffffffc02028c2:	e9260613          	addi	a2,a2,-366 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02028c6:	1c900593          	li	a1,457
ffffffffc02028ca:	00002517          	auipc	a0,0x2
ffffffffc02028ce:	2b650513          	addi	a0,a0,694 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc02028d2:	b35fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02028d6:	00002697          	auipc	a3,0x2
ffffffffc02028da:	62a68693          	addi	a3,a3,1578 # ffffffffc0204f00 <etext+0x1178>
ffffffffc02028de:	00002617          	auipc	a2,0x2
ffffffffc02028e2:	e7260613          	addi	a2,a2,-398 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02028e6:	1c800593          	li	a1,456
ffffffffc02028ea:	00002517          	auipc	a0,0x2
ffffffffc02028ee:	29650513          	addi	a0,a0,662 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc02028f2:	b15fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc02028f6:	00002697          	auipc	a3,0x2
ffffffffc02028fa:	6f268693          	addi	a3,a3,1778 # ffffffffc0204fe8 <etext+0x1260>
ffffffffc02028fe:	00002617          	auipc	a2,0x2
ffffffffc0202902:	e5260613          	addi	a2,a2,-430 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202906:	1ed00593          	li	a1,493
ffffffffc020290a:	00002517          	auipc	a0,0x2
ffffffffc020290e:	27650513          	addi	a0,a0,630 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202912:	af5fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202916:	00002697          	auipc	a3,0x2
ffffffffc020291a:	63268693          	addi	a3,a3,1586 # ffffffffc0204f48 <etext+0x11c0>
ffffffffc020291e:	00002617          	auipc	a2,0x2
ffffffffc0202922:	e3260613          	addi	a2,a2,-462 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202926:	1d600593          	li	a1,470
ffffffffc020292a:	00002517          	auipc	a0,0x2
ffffffffc020292e:	25650513          	addi	a0,a0,598 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202932:	ad5fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202936:	00002697          	auipc	a3,0x2
ffffffffc020293a:	70a68693          	addi	a3,a3,1802 # ffffffffc0205040 <etext+0x12b8>
ffffffffc020293e:	00002617          	auipc	a2,0x2
ffffffffc0202942:	e1260613          	addi	a2,a2,-494 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202946:	1f300593          	li	a1,499
ffffffffc020294a:	00002517          	auipc	a0,0x2
ffffffffc020294e:	23650513          	addi	a0,a0,566 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202952:	ab5fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202956:	00002697          	auipc	a3,0x2
ffffffffc020295a:	6aa68693          	addi	a3,a3,1706 # ffffffffc0205000 <etext+0x1278>
ffffffffc020295e:	00002617          	auipc	a2,0x2
ffffffffc0202962:	df260613          	addi	a2,a2,-526 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202966:	1f200593          	li	a1,498
ffffffffc020296a:	00002517          	auipc	a0,0x2
ffffffffc020296e:	21650513          	addi	a0,a0,534 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202972:	a95fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202976:	00002697          	auipc	a3,0x2
ffffffffc020297a:	55a68693          	addi	a3,a3,1370 # ffffffffc0204ed0 <etext+0x1148>
ffffffffc020297e:	00002617          	auipc	a2,0x2
ffffffffc0202982:	dd260613          	addi	a2,a2,-558 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202986:	1c500593          	li	a1,453
ffffffffc020298a:	00002517          	auipc	a0,0x2
ffffffffc020298e:	1f650513          	addi	a0,a0,502 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202992:	a75fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202996:	00002697          	auipc	a3,0x2
ffffffffc020299a:	3da68693          	addi	a3,a3,986 # ffffffffc0204d70 <etext+0xfe8>
ffffffffc020299e:	00002617          	auipc	a2,0x2
ffffffffc02029a2:	db260613          	addi	a2,a2,-590 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02029a6:	1c400593          	li	a1,452
ffffffffc02029aa:	00002517          	auipc	a0,0x2
ffffffffc02029ae:	1d650513          	addi	a0,a0,470 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc02029b2:	a55fd0ef          	jal	ffffffffc0200406 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02029b6:	00002697          	auipc	a3,0x2
ffffffffc02029ba:	53268693          	addi	a3,a3,1330 # ffffffffc0204ee8 <etext+0x1160>
ffffffffc02029be:	00002617          	auipc	a2,0x2
ffffffffc02029c2:	d9260613          	addi	a2,a2,-622 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02029c6:	1c000593          	li	a1,448
ffffffffc02029ca:	00002517          	auipc	a0,0x2
ffffffffc02029ce:	1b650513          	addi	a0,a0,438 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc02029d2:	a35fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02029d6:	00002697          	auipc	a3,0x2
ffffffffc02029da:	38268693          	addi	a3,a3,898 # ffffffffc0204d58 <etext+0xfd0>
ffffffffc02029de:	00002617          	auipc	a2,0x2
ffffffffc02029e2:	d7260613          	addi	a2,a2,-654 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02029e6:	1bf00593          	li	a1,447
ffffffffc02029ea:	00002517          	auipc	a0,0x2
ffffffffc02029ee:	19650513          	addi	a0,a0,406 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc02029f2:	a15fd0ef          	jal	ffffffffc0200406 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02029f6:	00002697          	auipc	a3,0x2
ffffffffc02029fa:	40268693          	addi	a3,a3,1026 # ffffffffc0204df8 <etext+0x1070>
ffffffffc02029fe:	00002617          	auipc	a2,0x2
ffffffffc0202a02:	d5260613          	addi	a2,a2,-686 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202a06:	1be00593          	li	a1,446
ffffffffc0202a0a:	00002517          	auipc	a0,0x2
ffffffffc0202a0e:	17650513          	addi	a0,a0,374 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202a12:	9f5fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202a16:	00002697          	auipc	a3,0x2
ffffffffc0202a1a:	4ba68693          	addi	a3,a3,1210 # ffffffffc0204ed0 <etext+0x1148>
ffffffffc0202a1e:	00002617          	auipc	a2,0x2
ffffffffc0202a22:	d3260613          	addi	a2,a2,-718 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202a26:	1bd00593          	li	a1,445
ffffffffc0202a2a:	00002517          	auipc	a0,0x2
ffffffffc0202a2e:	15650513          	addi	a0,a0,342 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202a32:	9d5fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202a36:	00002697          	auipc	a3,0x2
ffffffffc0202a3a:	48268693          	addi	a3,a3,1154 # ffffffffc0204eb8 <etext+0x1130>
ffffffffc0202a3e:	00002617          	auipc	a2,0x2
ffffffffc0202a42:	d1260613          	addi	a2,a2,-750 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202a46:	1bc00593          	li	a1,444
ffffffffc0202a4a:	00002517          	auipc	a0,0x2
ffffffffc0202a4e:	13650513          	addi	a0,a0,310 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202a52:	9b5fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202a56:	00002697          	auipc	a3,0x2
ffffffffc0202a5a:	43268693          	addi	a3,a3,1074 # ffffffffc0204e88 <etext+0x1100>
ffffffffc0202a5e:	00002617          	auipc	a2,0x2
ffffffffc0202a62:	cf260613          	addi	a2,a2,-782 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202a66:	1bb00593          	li	a1,443
ffffffffc0202a6a:	00002517          	auipc	a0,0x2
ffffffffc0202a6e:	11650513          	addi	a0,a0,278 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202a72:	995fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202a76:	00002697          	auipc	a3,0x2
ffffffffc0202a7a:	3fa68693          	addi	a3,a3,1018 # ffffffffc0204e70 <etext+0x10e8>
ffffffffc0202a7e:	00002617          	auipc	a2,0x2
ffffffffc0202a82:	cd260613          	addi	a2,a2,-814 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202a86:	1b800593          	li	a1,440
ffffffffc0202a8a:	00002517          	auipc	a0,0x2
ffffffffc0202a8e:	0f650513          	addi	a0,a0,246 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202a92:	975fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202a96:	00002697          	auipc	a3,0x2
ffffffffc0202a9a:	3ba68693          	addi	a3,a3,954 # ffffffffc0204e50 <etext+0x10c8>
ffffffffc0202a9e:	00002617          	auipc	a2,0x2
ffffffffc0202aa2:	cb260613          	addi	a2,a2,-846 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202aa6:	1b700593          	li	a1,439
ffffffffc0202aaa:	00002517          	auipc	a0,0x2
ffffffffc0202aae:	0d650513          	addi	a0,a0,214 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202ab2:	955fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202ab6:	00002697          	auipc	a3,0x2
ffffffffc0202aba:	38a68693          	addi	a3,a3,906 # ffffffffc0204e40 <etext+0x10b8>
ffffffffc0202abe:	00002617          	auipc	a2,0x2
ffffffffc0202ac2:	c9260613          	addi	a2,a2,-878 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202ac6:	1b600593          	li	a1,438
ffffffffc0202aca:	00002517          	auipc	a0,0x2
ffffffffc0202ace:	0b650513          	addi	a0,a0,182 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202ad2:	935fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202ad6:	00002697          	auipc	a3,0x2
ffffffffc0202ada:	35a68693          	addi	a3,a3,858 # ffffffffc0204e30 <etext+0x10a8>
ffffffffc0202ade:	00002617          	auipc	a2,0x2
ffffffffc0202ae2:	c7260613          	addi	a2,a2,-910 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202ae6:	1b500593          	li	a1,437
ffffffffc0202aea:	00002517          	auipc	a0,0x2
ffffffffc0202aee:	09650513          	addi	a0,a0,150 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202af2:	915fd0ef          	jal	ffffffffc0200406 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202af6:	00002617          	auipc	a2,0x2
ffffffffc0202afa:	04260613          	addi	a2,a2,66 # ffffffffc0204b38 <etext+0xdb0>
ffffffffc0202afe:	08b00593          	li	a1,139
ffffffffc0202b02:	00002517          	auipc	a0,0x2
ffffffffc0202b06:	07e50513          	addi	a0,a0,126 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202b0a:	8fdfd0ef          	jal	ffffffffc0200406 <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202b0e:	00002697          	auipc	a3,0x2
ffffffffc0202b12:	27a68693          	addi	a3,a3,634 # ffffffffc0204d88 <etext+0x1000>
ffffffffc0202b16:	00002617          	auipc	a2,0x2
ffffffffc0202b1a:	c3a60613          	addi	a2,a2,-966 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202b1e:	1af00593          	li	a1,431
ffffffffc0202b22:	00002517          	auipc	a0,0x2
ffffffffc0202b26:	05e50513          	addi	a0,a0,94 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202b2a:	8ddfd0ef          	jal	ffffffffc0200406 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202b2e:	00002697          	auipc	a3,0x2
ffffffffc0202b32:	2ca68693          	addi	a3,a3,714 # ffffffffc0204df8 <etext+0x1070>
ffffffffc0202b36:	00002617          	auipc	a2,0x2
ffffffffc0202b3a:	c1a60613          	addi	a2,a2,-998 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202b3e:	1b400593          	li	a1,436
ffffffffc0202b42:	00002517          	auipc	a0,0x2
ffffffffc0202b46:	03e50513          	addi	a0,a0,62 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202b4a:	8bdfd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202b4e:	00002697          	auipc	a3,0x2
ffffffffc0202b52:	26a68693          	addi	a3,a3,618 # ffffffffc0204db8 <etext+0x1030>
ffffffffc0202b56:	00002617          	auipc	a2,0x2
ffffffffc0202b5a:	bfa60613          	addi	a2,a2,-1030 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202b5e:	1b300593          	li	a1,435
ffffffffc0202b62:	00002517          	auipc	a0,0x2
ffffffffc0202b66:	01e50513          	addi	a0,a0,30 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202b6a:	89dfd0ef          	jal	ffffffffc0200406 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202b6e:	86d6                	mv	a3,s5
ffffffffc0202b70:	00002617          	auipc	a2,0x2
ffffffffc0202b74:	f2060613          	addi	a2,a2,-224 # ffffffffc0204a90 <etext+0xd08>
ffffffffc0202b78:	1ae00593          	li	a1,430
ffffffffc0202b7c:	00002517          	auipc	a0,0x2
ffffffffc0202b80:	00450513          	addi	a0,a0,4 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202b84:	883fd0ef          	jal	ffffffffc0200406 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202b88:	00002617          	auipc	a2,0x2
ffffffffc0202b8c:	f0860613          	addi	a2,a2,-248 # ffffffffc0204a90 <etext+0xd08>
ffffffffc0202b90:	1ad00593          	li	a1,429
ffffffffc0202b94:	00002517          	auipc	a0,0x2
ffffffffc0202b98:	fec50513          	addi	a0,a0,-20 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202b9c:	86bfd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202ba0:	00002697          	auipc	a3,0x2
ffffffffc0202ba4:	1d068693          	addi	a3,a3,464 # ffffffffc0204d70 <etext+0xfe8>
ffffffffc0202ba8:	00002617          	auipc	a2,0x2
ffffffffc0202bac:	ba860613          	addi	a2,a2,-1112 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202bb0:	1aa00593          	li	a1,426
ffffffffc0202bb4:	00002517          	auipc	a0,0x2
ffffffffc0202bb8:	fcc50513          	addi	a0,a0,-52 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202bbc:	84bfd0ef          	jal	ffffffffc0200406 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202bc0:	00002697          	auipc	a3,0x2
ffffffffc0202bc4:	19868693          	addi	a3,a3,408 # ffffffffc0204d58 <etext+0xfd0>
ffffffffc0202bc8:	00002617          	auipc	a2,0x2
ffffffffc0202bcc:	b8860613          	addi	a2,a2,-1144 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202bd0:	1a900593          	li	a1,425
ffffffffc0202bd4:	00002517          	auipc	a0,0x2
ffffffffc0202bd8:	fac50513          	addi	a0,a0,-84 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202bdc:	82bfd0ef          	jal	ffffffffc0200406 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202be0:	00002697          	auipc	a3,0x2
ffffffffc0202be4:	52868693          	addi	a3,a3,1320 # ffffffffc0205108 <etext+0x1380>
ffffffffc0202be8:	00002617          	auipc	a2,0x2
ffffffffc0202bec:	b6860613          	addi	a2,a2,-1176 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202bf0:	1fe00593          	li	a1,510
ffffffffc0202bf4:	00002517          	auipc	a0,0x2
ffffffffc0202bf8:	f8c50513          	addi	a0,a0,-116 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202bfc:	80bfd0ef          	jal	ffffffffc0200406 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202c00:	00002697          	auipc	a3,0x2
ffffffffc0202c04:	4d068693          	addi	a3,a3,1232 # ffffffffc02050d0 <etext+0x1348>
ffffffffc0202c08:	00002617          	auipc	a2,0x2
ffffffffc0202c0c:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202c10:	1fa00593          	li	a1,506
ffffffffc0202c14:	00002517          	auipc	a0,0x2
ffffffffc0202c18:	f6c50513          	addi	a0,a0,-148 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202c1c:	feafd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202c20:	00002697          	auipc	a3,0x2
ffffffffc0202c24:	48068693          	addi	a3,a3,1152 # ffffffffc02050a0 <etext+0x1318>
ffffffffc0202c28:	00002617          	auipc	a2,0x2
ffffffffc0202c2c:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202c30:	1f500593          	li	a1,501
ffffffffc0202c34:	00002517          	auipc	a0,0x2
ffffffffc0202c38:	f4c50513          	addi	a0,a0,-180 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202c3c:	fcafd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202c40:	00002697          	auipc	a3,0x2
ffffffffc0202c44:	41868693          	addi	a3,a3,1048 # ffffffffc0205058 <etext+0x12d0>
ffffffffc0202c48:	00002617          	auipc	a2,0x2
ffffffffc0202c4c:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202c50:	1f400593          	li	a1,500
ffffffffc0202c54:	00002517          	auipc	a0,0x2
ffffffffc0202c58:	f2c50513          	addi	a0,a0,-212 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202c5c:	faafd0ef          	jal	ffffffffc0200406 <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202c60:	00002697          	auipc	a3,0x2
ffffffffc0202c64:	04068693          	addi	a3,a3,64 # ffffffffc0204ca0 <etext+0xf18>
ffffffffc0202c68:	00002617          	auipc	a2,0x2
ffffffffc0202c6c:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202c70:	1a000593          	li	a1,416
ffffffffc0202c74:	00002517          	auipc	a0,0x2
ffffffffc0202c78:	f0c50513          	addi	a0,a0,-244 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202c7c:	f8afd0ef          	jal	ffffffffc0200406 <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202c80:	00002617          	auipc	a2,0x2
ffffffffc0202c84:	eb860613          	addi	a2,a2,-328 # ffffffffc0204b38 <etext+0xdb0>
ffffffffc0202c88:	0de00593          	li	a1,222
ffffffffc0202c8c:	00002517          	auipc	a0,0x2
ffffffffc0202c90:	ef450513          	addi	a0,a0,-268 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202c94:	f72fd0ef          	jal	ffffffffc0200406 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202c98:	00002697          	auipc	a3,0x2
ffffffffc0202c9c:	06868693          	addi	a3,a3,104 # ffffffffc0204d00 <etext+0xf78>
ffffffffc0202ca0:	00002617          	auipc	a2,0x2
ffffffffc0202ca4:	ab060613          	addi	a2,a2,-1360 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202ca8:	1a800593          	li	a1,424
ffffffffc0202cac:	00002517          	auipc	a0,0x2
ffffffffc0202cb0:	ed450513          	addi	a0,a0,-300 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202cb4:	f52fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202cb8:	00002697          	auipc	a3,0x2
ffffffffc0202cbc:	01868693          	addi	a3,a3,24 # ffffffffc0204cd0 <etext+0xf48>
ffffffffc0202cc0:	00002617          	auipc	a2,0x2
ffffffffc0202cc4:	a9060613          	addi	a2,a2,-1392 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202cc8:	1a500593          	li	a1,421
ffffffffc0202ccc:	00002517          	auipc	a0,0x2
ffffffffc0202cd0:	eb450513          	addi	a0,a0,-332 # ffffffffc0204b80 <etext+0xdf8>
ffffffffc0202cd4:	f32fd0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0202cd8 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0202cd8:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0202cda:	00002697          	auipc	a3,0x2
ffffffffc0202cde:	47668693          	addi	a3,a3,1142 # ffffffffc0205150 <etext+0x13c8>
ffffffffc0202ce2:	00002617          	auipc	a2,0x2
ffffffffc0202ce6:	a6e60613          	addi	a2,a2,-1426 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202cea:	08800593          	li	a1,136
ffffffffc0202cee:	00002517          	auipc	a0,0x2
ffffffffc0202cf2:	48250513          	addi	a0,a0,1154 # ffffffffc0205170 <etext+0x13e8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0202cf6:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0202cf8:	f0efd0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0202cfc <find_vma>:
    if (mm != NULL)
ffffffffc0202cfc:	c505                	beqz	a0,ffffffffc0202d24 <find_vma+0x28>
        vma = mm->mmap_cache;
ffffffffc0202cfe:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0202d00:	c781                	beqz	a5,ffffffffc0202d08 <find_vma+0xc>
ffffffffc0202d02:	6798                	ld	a4,8(a5)
ffffffffc0202d04:	02e5f363          	bgeu	a1,a4,ffffffffc0202d2a <find_vma+0x2e>
    return listelm->next;
ffffffffc0202d08:	651c                	ld	a5,8(a0)
            while ((le = list_next(le)) != list)
ffffffffc0202d0a:	00f50d63          	beq	a0,a5,ffffffffc0202d24 <find_vma+0x28>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0202d0e:	fe87b703          	ld	a4,-24(a5) # fffffffffdffffe8 <end+0x3ddf2af8>
ffffffffc0202d12:	00e5e663          	bltu	a1,a4,ffffffffc0202d1e <find_vma+0x22>
ffffffffc0202d16:	ff07b703          	ld	a4,-16(a5)
ffffffffc0202d1a:	00e5ee63          	bltu	a1,a4,ffffffffc0202d36 <find_vma+0x3a>
ffffffffc0202d1e:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc0202d20:	fef517e3          	bne	a0,a5,ffffffffc0202d0e <find_vma+0x12>
    struct vma_struct *vma = NULL;
ffffffffc0202d24:	4781                	li	a5,0
}
ffffffffc0202d26:	853e                	mv	a0,a5
ffffffffc0202d28:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0202d2a:	6b98                	ld	a4,16(a5)
ffffffffc0202d2c:	fce5fee3          	bgeu	a1,a4,ffffffffc0202d08 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0202d30:	e91c                	sd	a5,16(a0)
}
ffffffffc0202d32:	853e                	mv	a0,a5
ffffffffc0202d34:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0202d36:	1781                	addi	a5,a5,-32
            mm->mmap_cache = vma;
ffffffffc0202d38:	e91c                	sd	a5,16(a0)
ffffffffc0202d3a:	bfe5                	j	ffffffffc0202d32 <find_vma+0x36>

ffffffffc0202d3c <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202d3c:	6590                	ld	a2,8(a1)
ffffffffc0202d3e:	0105b803          	ld	a6,16(a1)
{
ffffffffc0202d42:	1141                	addi	sp,sp,-16
ffffffffc0202d44:	e406                	sd	ra,8(sp)
ffffffffc0202d46:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202d48:	01066763          	bltu	a2,a6,ffffffffc0202d56 <insert_vma_struct+0x1a>
ffffffffc0202d4c:	a8b9                	j	ffffffffc0202daa <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0202d4e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202d52:	04e66763          	bltu	a2,a4,ffffffffc0202da0 <insert_vma_struct+0x64>
ffffffffc0202d56:	86be                	mv	a3,a5
ffffffffc0202d58:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0202d5a:	fef51ae3          	bne	a0,a5,ffffffffc0202d4e <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0202d5e:	02a68463          	beq	a3,a0,ffffffffc0202d86 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0202d62:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202d66:	fe86b883          	ld	a7,-24(a3)
ffffffffc0202d6a:	08e8f063          	bgeu	a7,a4,ffffffffc0202dea <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202d6e:	04e66e63          	bltu	a2,a4,ffffffffc0202dca <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc0202d72:	00f50a63          	beq	a0,a5,ffffffffc0202d86 <insert_vma_struct+0x4a>
ffffffffc0202d76:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202d7a:	05076863          	bltu	a4,a6,ffffffffc0202dca <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0202d7e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0202d82:	02c77263          	bgeu	a4,a2,ffffffffc0202da6 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0202d86:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0202d88:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0202d8a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0202d8e:	e390                	sd	a2,0(a5)
ffffffffc0202d90:	e690                	sd	a2,8(a3)
}
ffffffffc0202d92:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0202d94:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0202d96:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0202d98:	2705                	addiw	a4,a4,1
ffffffffc0202d9a:	d118                	sw	a4,32(a0)
}
ffffffffc0202d9c:	0141                	addi	sp,sp,16
ffffffffc0202d9e:	8082                	ret
    if (le_prev != list)
ffffffffc0202da0:	fca691e3          	bne	a3,a0,ffffffffc0202d62 <insert_vma_struct+0x26>
ffffffffc0202da4:	bfd9                	j	ffffffffc0202d7a <insert_vma_struct+0x3e>
ffffffffc0202da6:	f33ff0ef          	jal	ffffffffc0202cd8 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0202daa:	00002697          	auipc	a3,0x2
ffffffffc0202dae:	3d668693          	addi	a3,a3,982 # ffffffffc0205180 <etext+0x13f8>
ffffffffc0202db2:	00002617          	auipc	a2,0x2
ffffffffc0202db6:	99e60613          	addi	a2,a2,-1634 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202dba:	08e00593          	li	a1,142
ffffffffc0202dbe:	00002517          	auipc	a0,0x2
ffffffffc0202dc2:	3b250513          	addi	a0,a0,946 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0202dc6:	e40fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0202dca:	00002697          	auipc	a3,0x2
ffffffffc0202dce:	3f668693          	addi	a3,a3,1014 # ffffffffc02051c0 <etext+0x1438>
ffffffffc0202dd2:	00002617          	auipc	a2,0x2
ffffffffc0202dd6:	97e60613          	addi	a2,a2,-1666 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202dda:	08700593          	li	a1,135
ffffffffc0202dde:	00002517          	auipc	a0,0x2
ffffffffc0202de2:	39250513          	addi	a0,a0,914 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0202de6:	e20fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0202dea:	00002697          	auipc	a3,0x2
ffffffffc0202dee:	3b668693          	addi	a3,a3,950 # ffffffffc02051a0 <etext+0x1418>
ffffffffc0202df2:	00002617          	auipc	a2,0x2
ffffffffc0202df6:	95e60613          	addi	a2,a2,-1698 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202dfa:	08600593          	li	a1,134
ffffffffc0202dfe:	00002517          	auipc	a0,0x2
ffffffffc0202e02:	37250513          	addi	a0,a0,882 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0202e06:	e00fd0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0202e0a <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0202e0a:	7139                	addi	sp,sp,-64
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202e0c:	03000513          	li	a0,48
{
ffffffffc0202e10:	fc06                	sd	ra,56(sp)
ffffffffc0202e12:	f822                	sd	s0,48(sp)
ffffffffc0202e14:	f426                	sd	s1,40(sp)
ffffffffc0202e16:	f04a                	sd	s2,32(sp)
ffffffffc0202e18:	ec4e                	sd	s3,24(sp)
ffffffffc0202e1a:	e852                	sd	s4,16(sp)
ffffffffc0202e1c:	e456                	sd	s5,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0202e1e:	bc3fe0ef          	jal	ffffffffc02019e0 <kmalloc>
    if (mm != NULL)
ffffffffc0202e22:	18050a63          	beqz	a0,ffffffffc0202fb6 <vmm_init+0x1ac>
ffffffffc0202e26:	842a                	mv	s0,a0
    elm->prev = elm->next = elm;
ffffffffc0202e28:	e508                	sd	a0,8(a0)
ffffffffc0202e2a:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0202e2c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0202e30:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0202e34:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0202e38:	02053423          	sd	zero,40(a0)
ffffffffc0202e3c:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202e40:	03000513          	li	a0,48
ffffffffc0202e44:	b9dfe0ef          	jal	ffffffffc02019e0 <kmalloc>
    if (vma != NULL)
ffffffffc0202e48:	14050763          	beqz	a0,ffffffffc0202f96 <vmm_init+0x18c>
        vma->vm_end = vm_end;
ffffffffc0202e4c:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0202e50:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202e52:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0202e56:	e91c                	sd	a5,16(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202e58:	85aa                	mv	a1,a0
    for (i = step1; i >= 1; i--)
ffffffffc0202e5a:	14ed                	addi	s1,s1,-5
        insert_vma_struct(mm, vma);
ffffffffc0202e5c:	8522                	mv	a0,s0
ffffffffc0202e5e:	edfff0ef          	jal	ffffffffc0202d3c <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0202e62:	fcf9                	bnez	s1,ffffffffc0202e40 <vmm_init+0x36>
ffffffffc0202e64:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202e68:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0202e6c:	03000513          	li	a0,48
ffffffffc0202e70:	b71fe0ef          	jal	ffffffffc02019e0 <kmalloc>
    if (vma != NULL)
ffffffffc0202e74:	16050163          	beqz	a0,ffffffffc0202fd6 <vmm_init+0x1cc>
        vma->vm_end = vm_end;
ffffffffc0202e78:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0202e7c:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0202e7e:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0202e82:	e91c                	sd	a5,16(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0202e84:	85aa                	mv	a1,a0
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202e86:	0495                	addi	s1,s1,5
        insert_vma_struct(mm, vma);
ffffffffc0202e88:	8522                	mv	a0,s0
ffffffffc0202e8a:	eb3ff0ef          	jal	ffffffffc0202d3c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0202e8e:	fd249fe3          	bne	s1,s2,ffffffffc0202e6c <vmm_init+0x62>
    return listelm->next;
ffffffffc0202e92:	641c                	ld	a5,8(s0)
ffffffffc0202e94:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0202e96:	1fb00593          	li	a1,507
ffffffffc0202e9a:	8abe                	mv	s5,a5
    {
        assert(le != &(mm->mmap_list));
ffffffffc0202e9c:	20f40d63          	beq	s0,a5,ffffffffc02030b6 <vmm_init+0x2ac>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202ea0:	fe87b603          	ld	a2,-24(a5)
ffffffffc0202ea4:	ffe70693          	addi	a3,a4,-2
ffffffffc0202ea8:	14d61763          	bne	a2,a3,ffffffffc0202ff6 <vmm_init+0x1ec>
ffffffffc0202eac:	ff07b683          	ld	a3,-16(a5)
ffffffffc0202eb0:	14e69363          	bne	a3,a4,ffffffffc0202ff6 <vmm_init+0x1ec>
    for (i = 1; i <= step2; i++)
ffffffffc0202eb4:	0715                	addi	a4,a4,5
ffffffffc0202eb6:	679c                	ld	a5,8(a5)
ffffffffc0202eb8:	feb712e3          	bne	a4,a1,ffffffffc0202e9c <vmm_init+0x92>
ffffffffc0202ebc:	491d                	li	s2,7
ffffffffc0202ebe:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0202ec0:	85a6                	mv	a1,s1
ffffffffc0202ec2:	8522                	mv	a0,s0
ffffffffc0202ec4:	e39ff0ef          	jal	ffffffffc0202cfc <find_vma>
ffffffffc0202ec8:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0202eca:	22050663          	beqz	a0,ffffffffc02030f6 <vmm_init+0x2ec>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0202ece:	00148593          	addi	a1,s1,1
ffffffffc0202ed2:	8522                	mv	a0,s0
ffffffffc0202ed4:	e29ff0ef          	jal	ffffffffc0202cfc <find_vma>
ffffffffc0202ed8:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0202eda:	1e050e63          	beqz	a0,ffffffffc02030d6 <vmm_init+0x2cc>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0202ede:	85ca                	mv	a1,s2
ffffffffc0202ee0:	8522                	mv	a0,s0
ffffffffc0202ee2:	e1bff0ef          	jal	ffffffffc0202cfc <find_vma>
        assert(vma3 == NULL);
ffffffffc0202ee6:	1a051863          	bnez	a0,ffffffffc0203096 <vmm_init+0x28c>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0202eea:	00348593          	addi	a1,s1,3
ffffffffc0202eee:	8522                	mv	a0,s0
ffffffffc0202ef0:	e0dff0ef          	jal	ffffffffc0202cfc <find_vma>
        assert(vma4 == NULL);
ffffffffc0202ef4:	18051163          	bnez	a0,ffffffffc0203076 <vmm_init+0x26c>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0202ef8:	00448593          	addi	a1,s1,4
ffffffffc0202efc:	8522                	mv	a0,s0
ffffffffc0202efe:	dffff0ef          	jal	ffffffffc0202cfc <find_vma>
        assert(vma5 == NULL);
ffffffffc0202f02:	14051a63          	bnez	a0,ffffffffc0203056 <vmm_init+0x24c>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0202f06:	008a3783          	ld	a5,8(s4)
ffffffffc0202f0a:	12979663          	bne	a5,s1,ffffffffc0203036 <vmm_init+0x22c>
ffffffffc0202f0e:	010a3783          	ld	a5,16(s4)
ffffffffc0202f12:	13279263          	bne	a5,s2,ffffffffc0203036 <vmm_init+0x22c>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0202f16:	0089b783          	ld	a5,8(s3)
ffffffffc0202f1a:	0e979e63          	bne	a5,s1,ffffffffc0203016 <vmm_init+0x20c>
ffffffffc0202f1e:	0109b783          	ld	a5,16(s3)
ffffffffc0202f22:	0f279a63          	bne	a5,s2,ffffffffc0203016 <vmm_init+0x20c>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0202f26:	0495                	addi	s1,s1,5
ffffffffc0202f28:	1f900793          	li	a5,505
ffffffffc0202f2c:	0915                	addi	s2,s2,5
ffffffffc0202f2e:	f8f499e3          	bne	s1,a5,ffffffffc0202ec0 <vmm_init+0xb6>
ffffffffc0202f32:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0202f34:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0202f36:	85a6                	mv	a1,s1
ffffffffc0202f38:	8522                	mv	a0,s0
ffffffffc0202f3a:	dc3ff0ef          	jal	ffffffffc0202cfc <find_vma>
        if (vma_below_5 != NULL)
ffffffffc0202f3e:	1c051c63          	bnez	a0,ffffffffc0203116 <vmm_init+0x30c>
    for (i = 4; i >= 0; i--)
ffffffffc0202f42:	14fd                	addi	s1,s1,-1
ffffffffc0202f44:	ff2499e3          	bne	s1,s2,ffffffffc0202f36 <vmm_init+0x12c>
    while ((le = list_next(list)) != list)
ffffffffc0202f48:	028a8063          	beq	s5,s0,ffffffffc0202f68 <vmm_init+0x15e>
    __list_del(listelm->prev, listelm->next);
ffffffffc0202f4c:	008ab783          	ld	a5,8(s5) # 1008 <kern_entry-0xffffffffc01feff8>
ffffffffc0202f50:	000ab703          	ld	a4,0(s5)
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0202f54:	fe0a8513          	addi	a0,s5,-32
    prev->next = next;
ffffffffc0202f58:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0202f5a:	e398                	sd	a4,0(a5)
ffffffffc0202f5c:	b2bfe0ef          	jal	ffffffffc0201a86 <kfree>
    return listelm->next;
ffffffffc0202f60:	641c                	ld	a5,8(s0)
ffffffffc0202f62:	8abe                	mv	s5,a5
    while ((le = list_next(list)) != list)
ffffffffc0202f64:	fef414e3          	bne	s0,a5,ffffffffc0202f4c <vmm_init+0x142>
    kfree(mm); // kfree mm
ffffffffc0202f68:	8522                	mv	a0,s0
ffffffffc0202f6a:	b1dfe0ef          	jal	ffffffffc0201a86 <kfree>
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0202f6e:	00002517          	auipc	a0,0x2
ffffffffc0202f72:	3d250513          	addi	a0,a0,978 # ffffffffc0205340 <etext+0x15b8>
ffffffffc0202f76:	a1efd0ef          	jal	ffffffffc0200194 <cprintf>
}
ffffffffc0202f7a:	7442                	ld	s0,48(sp)
ffffffffc0202f7c:	70e2                	ld	ra,56(sp)
ffffffffc0202f7e:	74a2                	ld	s1,40(sp)
ffffffffc0202f80:	7902                	ld	s2,32(sp)
ffffffffc0202f82:	69e2                	ld	s3,24(sp)
ffffffffc0202f84:	6a42                	ld	s4,16(sp)
ffffffffc0202f86:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202f88:	00002517          	auipc	a0,0x2
ffffffffc0202f8c:	3d850513          	addi	a0,a0,984 # ffffffffc0205360 <etext+0x15d8>
}
ffffffffc0202f90:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0202f92:	a02fd06f          	j	ffffffffc0200194 <cprintf>
        assert(vma != NULL);
ffffffffc0202f96:	00002697          	auipc	a3,0x2
ffffffffc0202f9a:	25a68693          	addi	a3,a3,602 # ffffffffc02051f0 <etext+0x1468>
ffffffffc0202f9e:	00001617          	auipc	a2,0x1
ffffffffc0202fa2:	7b260613          	addi	a2,a2,1970 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202fa6:	0da00593          	li	a1,218
ffffffffc0202faa:	00002517          	auipc	a0,0x2
ffffffffc0202fae:	1c650513          	addi	a0,a0,454 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0202fb2:	c54fd0ef          	jal	ffffffffc0200406 <__panic>
    assert(mm != NULL);
ffffffffc0202fb6:	00002697          	auipc	a3,0x2
ffffffffc0202fba:	22a68693          	addi	a3,a3,554 # ffffffffc02051e0 <etext+0x1458>
ffffffffc0202fbe:	00001617          	auipc	a2,0x1
ffffffffc0202fc2:	79260613          	addi	a2,a2,1938 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202fc6:	0d200593          	li	a1,210
ffffffffc0202fca:	00002517          	auipc	a0,0x2
ffffffffc0202fce:	1a650513          	addi	a0,a0,422 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0202fd2:	c34fd0ef          	jal	ffffffffc0200406 <__panic>
        assert(vma != NULL);
ffffffffc0202fd6:	00002697          	auipc	a3,0x2
ffffffffc0202fda:	21a68693          	addi	a3,a3,538 # ffffffffc02051f0 <etext+0x1468>
ffffffffc0202fde:	00001617          	auipc	a2,0x1
ffffffffc0202fe2:	77260613          	addi	a2,a2,1906 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0202fe6:	0e100593          	li	a1,225
ffffffffc0202fea:	00002517          	auipc	a0,0x2
ffffffffc0202fee:	18650513          	addi	a0,a0,390 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0202ff2:	c14fd0ef          	jal	ffffffffc0200406 <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0202ff6:	00002697          	auipc	a3,0x2
ffffffffc0202ffa:	22268693          	addi	a3,a3,546 # ffffffffc0205218 <etext+0x1490>
ffffffffc0202ffe:	00001617          	auipc	a2,0x1
ffffffffc0203002:	75260613          	addi	a2,a2,1874 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0203006:	0eb00593          	li	a1,235
ffffffffc020300a:	00002517          	auipc	a0,0x2
ffffffffc020300e:	16650513          	addi	a0,a0,358 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0203012:	bf4fd0ef          	jal	ffffffffc0200406 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203016:	00002697          	auipc	a3,0x2
ffffffffc020301a:	2ba68693          	addi	a3,a3,698 # ffffffffc02052d0 <etext+0x1548>
ffffffffc020301e:	00001617          	auipc	a2,0x1
ffffffffc0203022:	73260613          	addi	a2,a2,1842 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0203026:	0fd00593          	li	a1,253
ffffffffc020302a:	00002517          	auipc	a0,0x2
ffffffffc020302e:	14650513          	addi	a0,a0,326 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0203032:	bd4fd0ef          	jal	ffffffffc0200406 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203036:	00002697          	auipc	a3,0x2
ffffffffc020303a:	26a68693          	addi	a3,a3,618 # ffffffffc02052a0 <etext+0x1518>
ffffffffc020303e:	00001617          	auipc	a2,0x1
ffffffffc0203042:	71260613          	addi	a2,a2,1810 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0203046:	0fc00593          	li	a1,252
ffffffffc020304a:	00002517          	auipc	a0,0x2
ffffffffc020304e:	12650513          	addi	a0,a0,294 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0203052:	bb4fd0ef          	jal	ffffffffc0200406 <__panic>
        assert(vma5 == NULL);
ffffffffc0203056:	00002697          	auipc	a3,0x2
ffffffffc020305a:	23a68693          	addi	a3,a3,570 # ffffffffc0205290 <etext+0x1508>
ffffffffc020305e:	00001617          	auipc	a2,0x1
ffffffffc0203062:	6f260613          	addi	a2,a2,1778 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0203066:	0fa00593          	li	a1,250
ffffffffc020306a:	00002517          	auipc	a0,0x2
ffffffffc020306e:	10650513          	addi	a0,a0,262 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0203072:	b94fd0ef          	jal	ffffffffc0200406 <__panic>
        assert(vma4 == NULL);
ffffffffc0203076:	00002697          	auipc	a3,0x2
ffffffffc020307a:	20a68693          	addi	a3,a3,522 # ffffffffc0205280 <etext+0x14f8>
ffffffffc020307e:	00001617          	auipc	a2,0x1
ffffffffc0203082:	6d260613          	addi	a2,a2,1746 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0203086:	0f800593          	li	a1,248
ffffffffc020308a:	00002517          	auipc	a0,0x2
ffffffffc020308e:	0e650513          	addi	a0,a0,230 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0203092:	b74fd0ef          	jal	ffffffffc0200406 <__panic>
        assert(vma3 == NULL);
ffffffffc0203096:	00002697          	auipc	a3,0x2
ffffffffc020309a:	1da68693          	addi	a3,a3,474 # ffffffffc0205270 <etext+0x14e8>
ffffffffc020309e:	00001617          	auipc	a2,0x1
ffffffffc02030a2:	6b260613          	addi	a2,a2,1714 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02030a6:	0f600593          	li	a1,246
ffffffffc02030aa:	00002517          	auipc	a0,0x2
ffffffffc02030ae:	0c650513          	addi	a0,a0,198 # ffffffffc0205170 <etext+0x13e8>
ffffffffc02030b2:	b54fd0ef          	jal	ffffffffc0200406 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02030b6:	00002697          	auipc	a3,0x2
ffffffffc02030ba:	14a68693          	addi	a3,a3,330 # ffffffffc0205200 <etext+0x1478>
ffffffffc02030be:	00001617          	auipc	a2,0x1
ffffffffc02030c2:	69260613          	addi	a2,a2,1682 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02030c6:	0e900593          	li	a1,233
ffffffffc02030ca:	00002517          	auipc	a0,0x2
ffffffffc02030ce:	0a650513          	addi	a0,a0,166 # ffffffffc0205170 <etext+0x13e8>
ffffffffc02030d2:	b34fd0ef          	jal	ffffffffc0200406 <__panic>
        assert(vma2 != NULL);
ffffffffc02030d6:	00002697          	auipc	a3,0x2
ffffffffc02030da:	18a68693          	addi	a3,a3,394 # ffffffffc0205260 <etext+0x14d8>
ffffffffc02030de:	00001617          	auipc	a2,0x1
ffffffffc02030e2:	67260613          	addi	a2,a2,1650 # ffffffffc0204750 <etext+0x9c8>
ffffffffc02030e6:	0f400593          	li	a1,244
ffffffffc02030ea:	00002517          	auipc	a0,0x2
ffffffffc02030ee:	08650513          	addi	a0,a0,134 # ffffffffc0205170 <etext+0x13e8>
ffffffffc02030f2:	b14fd0ef          	jal	ffffffffc0200406 <__panic>
        assert(vma1 != NULL);
ffffffffc02030f6:	00002697          	auipc	a3,0x2
ffffffffc02030fa:	15a68693          	addi	a3,a3,346 # ffffffffc0205250 <etext+0x14c8>
ffffffffc02030fe:	00001617          	auipc	a2,0x1
ffffffffc0203102:	65260613          	addi	a2,a2,1618 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0203106:	0f200593          	li	a1,242
ffffffffc020310a:	00002517          	auipc	a0,0x2
ffffffffc020310e:	06650513          	addi	a0,a0,102 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0203112:	af4fd0ef          	jal	ffffffffc0200406 <__panic>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203116:	6914                	ld	a3,16(a0)
ffffffffc0203118:	6510                	ld	a2,8(a0)
ffffffffc020311a:	0004859b          	sext.w	a1,s1
ffffffffc020311e:	00002517          	auipc	a0,0x2
ffffffffc0203122:	1e250513          	addi	a0,a0,482 # ffffffffc0205300 <etext+0x1578>
ffffffffc0203126:	86efd0ef          	jal	ffffffffc0200194 <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc020312a:	00002697          	auipc	a3,0x2
ffffffffc020312e:	1fe68693          	addi	a3,a3,510 # ffffffffc0205328 <etext+0x15a0>
ffffffffc0203132:	00001617          	auipc	a2,0x1
ffffffffc0203136:	61e60613          	addi	a2,a2,1566 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020313a:	10700593          	li	a1,263
ffffffffc020313e:	00002517          	auipc	a0,0x2
ffffffffc0203142:	03250513          	addi	a0,a0,50 # ffffffffc0205170 <etext+0x13e8>
ffffffffc0203146:	ac0fd0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc020314a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1           # 将参数从s1寄存器移动到a0寄存器（函数第一个参数）
ffffffffc020314a:	8526                	mv	a0,s1
	jalr s0               # 跳转到s0寄存器中的函数地址执行（内核线程的主函数）
ffffffffc020314c:	9402                	jalr	s0

ffffffffc020314e:	398000ef          	jal	ffffffffc02034e6 <do_exit>

ffffffffc0203152 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - 分配一个proc_struct并初始化所有字段
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203152:	1141                	addi	sp,sp,-16
    // 分配进程控制块内存
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203154:	0e800513          	li	a0,232
{
ffffffffc0203158:	e022                	sd	s0,0(sp)
ffffffffc020315a:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc020315c:	885fe0ef          	jal	ffffffffc02019e0 <kmalloc>
ffffffffc0203160:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203162:	c521                	beqz	a0,ffffffffc02031aa <alloc_proc+0x58>
         *       struct trapframe *tf;                       // 当前中断的陷阱帧
         *       uintptr_t pgdir;                            // 页目录表(PDT)的基地址
         *       uint32_t flags;                             // 进程标志
         *       char name[PROC_NAME_LEN + 1];               // 进程名称
         */
        proc->state = PROC_UNINIT;        // 设置为未初始化状态
ffffffffc0203164:	57fd                	li	a5,-1
ffffffffc0203166:	1782                	slli	a5,a5,0x20
ffffffffc0203168:	e11c                	sd	a5,0(a0)
        proc->pid = -1;                   // 初始pid为-1，表示无效
        proc->runs = 0;                   // 运行次数初始为0
        proc->pgdir = boot_pgdir_pa;      // 使用启动页目录
ffffffffc020316a:	0000a797          	auipc	a5,0xa
ffffffffc020316e:	33e7b783          	ld	a5,830(a5) # ffffffffc020d4a8 <boot_pgdir_pa>
        proc->runs = 0;                   // 运行次数初始为0
ffffffffc0203172:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;                 // 内核栈初始为0
ffffffffc0203176:	00053823          	sd	zero,16(a0)
        proc->pgdir = boot_pgdir_pa;      // 使用启动页目录
ffffffffc020317a:	f55c                	sd	a5,168(a0)
        proc->need_resched = 0;           // 不需要重新调度
ffffffffc020317c:	00052c23          	sw	zero,24(a0)
        proc->parent = NULL;              // 父进程为空
ffffffffc0203180:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;                  // 内存管理结构为空
ffffffffc0203184:	02053423          	sd	zero,40(a0)
        proc->tf = NULL;                  // 陷阱帧为空
ffffffffc0203188:	0a053023          	sd	zero,160(a0)
        proc->flags = 0;                  // 标志位初始为0
ffffffffc020318c:	0a052823          	sw	zero,176(a0)
        memset(&proc->name, 0, PROC_NAME_LEN);  // 清空进程名
ffffffffc0203190:	463d                	li	a2,15
ffffffffc0203192:	4581                	li	a1,0
ffffffffc0203194:	0b450513          	addi	a0,a0,180
ffffffffc0203198:	3a3000ef          	jal	ffffffffc0203d3a <memset>
        memset(&proc->context, 0, sizeof(struct context));  // 清空上下文
ffffffffc020319c:	03040513          	addi	a0,s0,48 # ffffffffc0200030 <kern_entry+0x30>
ffffffffc02031a0:	07000613          	li	a2,112
ffffffffc02031a4:	4581                	li	a1,0
ffffffffc02031a6:	395000ef          	jal	ffffffffc0203d3a <memset>
    }
    return proc;
}
ffffffffc02031aa:	60a2                	ld	ra,8(sp)
ffffffffc02031ac:	8522                	mv	a0,s0
ffffffffc02031ae:	6402                	ld	s0,0(sp)
ffffffffc02031b0:	0141                	addi	sp,sp,16
ffffffffc02031b2:	8082                	ret

ffffffffc02031b4 <forkret>:
// 注意：forkret的地址在copy_thread函数中设置
//       在switch_to之后，当前进程将在这里执行
static void
forkret(void)
{
    forkrets(current->tf);  // 从陷阱帧返回到用户空间
ffffffffc02031b4:	0000a797          	auipc	a5,0xa
ffffffffc02031b8:	3247b783          	ld	a5,804(a5) # ffffffffc020d4d8 <current>
ffffffffc02031bc:	73c8                	ld	a0,160(a5)
ffffffffc02031be:	b73fd06f          	j	ffffffffc0200d30 <forkrets>

ffffffffc02031c2 <init_main>:
}

// init_main - 用于创建user_main内核线程的第二个内核线程
static int
init_main(void *arg)
{
ffffffffc02031c2:	1101                	addi	sp,sp,-32
ffffffffc02031c4:	e822                	sd	s0,16(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02031c6:	0000a417          	auipc	s0,0xa
ffffffffc02031ca:	31243403          	ld	s0,786(s0) # ffffffffc020d4d8 <current>
{
ffffffffc02031ce:	e04a                	sd	s2,0(sp)
    memset(name, 0, sizeof(name));  // 清空静态缓冲区
ffffffffc02031d0:	4641                	li	a2,16
{
ffffffffc02031d2:	892a                	mv	s2,a0
    memset(name, 0, sizeof(name));  // 清空静态缓冲区
ffffffffc02031d4:	4581                	li	a1,0
ffffffffc02031d6:	00006517          	auipc	a0,0x6
ffffffffc02031da:	27250513          	addi	a0,a0,626 # ffffffffc0209448 <name.2>
{
ffffffffc02031de:	ec06                	sd	ra,24(sp)
ffffffffc02031e0:	e426                	sd	s1,8(sp)
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02031e2:	4044                	lw	s1,4(s0)
    memset(name, 0, sizeof(name));  // 清空静态缓冲区
ffffffffc02031e4:	357000ef          	jal	ffffffffc0203d3a <memset>
    return memcpy(name, proc->name, PROC_NAME_LEN);  // 复制进程名称
ffffffffc02031e8:	0b440593          	addi	a1,s0,180
ffffffffc02031ec:	463d                	li	a2,15
ffffffffc02031ee:	00006517          	auipc	a0,0x6
ffffffffc02031f2:	25a50513          	addi	a0,a0,602 # ffffffffc0209448 <name.2>
ffffffffc02031f6:	357000ef          	jal	ffffffffc0203d4c <memcpy>
ffffffffc02031fa:	862a                	mv	a2,a0
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
ffffffffc02031fc:	85a6                	mv	a1,s1
ffffffffc02031fe:	00002517          	auipc	a0,0x2
ffffffffc0203202:	17a50513          	addi	a0,a0,378 # ffffffffc0205378 <etext+0x15f0>
ffffffffc0203206:	f8ffc0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("To U: \"%s\".\n", (const char *)arg);
ffffffffc020320a:	85ca                	mv	a1,s2
ffffffffc020320c:	00002517          	auipc	a0,0x2
ffffffffc0203210:	19450513          	addi	a0,a0,404 # ffffffffc02053a0 <etext+0x1618>
ffffffffc0203214:	f81fc0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
ffffffffc0203218:	00002517          	auipc	a0,0x2
ffffffffc020321c:	19850513          	addi	a0,a0,408 # ffffffffc02053b0 <etext+0x1628>
ffffffffc0203220:	f75fc0ef          	jal	ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc0203224:	60e2                	ld	ra,24(sp)
ffffffffc0203226:	6442                	ld	s0,16(sp)
ffffffffc0203228:	64a2                	ld	s1,8(sp)
ffffffffc020322a:	6902                	ld	s2,0(sp)
ffffffffc020322c:	4501                	li	a0,0
ffffffffc020322e:	6105                	addi	sp,sp,32
ffffffffc0203230:	8082                	ret

ffffffffc0203232 <proc_run>:
    if (proc != current)  // 如果要运行的进程不是当前进程
ffffffffc0203232:	0000a717          	auipc	a4,0xa
ffffffffc0203236:	2a670713          	addi	a4,a4,678 # ffffffffc020d4d8 <current>
ffffffffc020323a:	6310                	ld	a2,0(a4)
ffffffffc020323c:	04a60363          	beq	a2,a0,ffffffffc0203282 <proc_run+0x50>
ffffffffc0203240:	87aa                	mv	a5,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203242:	100026f3          	csrr	a3,sstatus
ffffffffc0203246:	8a89                	andi	a3,a3,2
ffffffffc0203248:	e699                	bnez	a3,ffffffffc0203256 <proc_run+0x24>
            switch_to(&(curr_proc->context), &(proc->context));  // 执行上下文切换
ffffffffc020324a:	03060513          	addi	a0,a2,48
ffffffffc020324e:	03078593          	addi	a1,a5,48
            current = proc;  // 设置当前进程为目标进程
ffffffffc0203252:	e31c                	sd	a5,0(a4)
            switch_to(&(curr_proc->context), &(proc->context));  // 执行上下文切换
ffffffffc0203254:	a305                	j	ffffffffc0203774 <switch_to>
{
ffffffffc0203256:	1101                	addi	sp,sp,-32
ffffffffc0203258:	ec06                	sd	ra,24(sp)
ffffffffc020325a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020325c:	e18fd0ef          	jal	ffffffffc0200874 <intr_disable>
            struct proc_struct *curr_proc = current;  // 保存当前进程
ffffffffc0203260:	0000a717          	auipc	a4,0xa
ffffffffc0203264:	27870713          	addi	a4,a4,632 # ffffffffc020d4d8 <current>
            switch_to(&(curr_proc->context), &(proc->context));  // 执行上下文切换
ffffffffc0203268:	67a2                	ld	a5,8(sp)
            struct proc_struct *curr_proc = current;  // 保存当前进程
ffffffffc020326a:	6308                	ld	a0,0(a4)
            switch_to(&(curr_proc->context), &(proc->context));  // 执行上下文切换
ffffffffc020326c:	03078593          	addi	a1,a5,48
ffffffffc0203270:	03050513          	addi	a0,a0,48
            current = proc;  // 设置当前进程为目标进程
ffffffffc0203274:	e31c                	sd	a5,0(a4)
            switch_to(&(curr_proc->context), &(proc->context));  // 执行上下文切换
ffffffffc0203276:	4fe000ef          	jal	ffffffffc0203774 <switch_to>
}
ffffffffc020327a:	60e2                	ld	ra,24(sp)
ffffffffc020327c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020327e:	df0fd06f          	j	ffffffffc020086e <intr_enable>
ffffffffc0203282:	8082                	ret

ffffffffc0203284 <do_fork>:
    if (nr_process >= MAX_PROCESS)  // 检查进程数是否超过最大值
ffffffffc0203284:	0000a717          	auipc	a4,0xa
ffffffffc0203288:	24c72703          	lw	a4,588(a4) # ffffffffc020d4d0 <nr_process>
ffffffffc020328c:	6785                	lui	a5,0x1
ffffffffc020328e:	1cf75663          	bge	a4,a5,ffffffffc020345a <do_fork+0x1d6>
{
ffffffffc0203292:	1101                	addi	sp,sp,-32
ffffffffc0203294:	e822                	sd	s0,16(sp)
ffffffffc0203296:	e426                	sd	s1,8(sp)
ffffffffc0203298:	e04a                	sd	s2,0(sp)
ffffffffc020329a:	ec06                	sd	ra,24(sp)
ffffffffc020329c:	892e                	mv	s2,a1
ffffffffc020329e:	8432                	mv	s0,a2
    if ((proc = alloc_proc()) == NULL) {
ffffffffc02032a0:	eb3ff0ef          	jal	ffffffffc0203152 <alloc_proc>
ffffffffc02032a4:	84aa                	mv	s1,a0
ffffffffc02032a6:	1a050863          	beqz	a0,ffffffffc0203456 <do_fork+0x1d2>
    struct Page *page = alloc_pages(KSTACKPAGE);  // 分配内核栈页面
ffffffffc02032aa:	4509                	li	a0,2
ffffffffc02032ac:	8f7fe0ef          	jal	ffffffffc0201ba2 <alloc_pages>
    if (page != NULL)
ffffffffc02032b0:	1a050063          	beqz	a0,ffffffffc0203450 <do_fork+0x1cc>
    return page - pages + nbase;
ffffffffc02032b4:	0000a697          	auipc	a3,0xa
ffffffffc02032b8:	2146b683          	ld	a3,532(a3) # ffffffffc020d4c8 <pages>
ffffffffc02032bc:	00002797          	auipc	a5,0x2
ffffffffc02032c0:	5a47b783          	ld	a5,1444(a5) # ffffffffc0205860 <nbase>
    return KADDR(page2pa(page));
ffffffffc02032c4:	0000a717          	auipc	a4,0xa
ffffffffc02032c8:	1fc73703          	ld	a4,508(a4) # ffffffffc020d4c0 <npage>
    return page - pages + nbase;
ffffffffc02032cc:	40d506b3          	sub	a3,a0,a3
ffffffffc02032d0:	8699                	srai	a3,a3,0x6
ffffffffc02032d2:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02032d4:	00c69793          	slli	a5,a3,0xc
ffffffffc02032d8:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02032da:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02032dc:	1ae7f163          	bgeu	a5,a4,ffffffffc020347e <do_fork+0x1fa>
    assert(current->mm == NULL);  // 断言当前进程没有内存管理结构（内核线程）
ffffffffc02032e0:	0000a797          	auipc	a5,0xa
ffffffffc02032e4:	1f87b783          	ld	a5,504(a5) # ffffffffc020d4d8 <current>
ffffffffc02032e8:	0000a717          	auipc	a4,0xa
ffffffffc02032ec:	1d073703          	ld	a4,464(a4) # ffffffffc020d4b8 <va_pa_offset>
ffffffffc02032f0:	779c                	ld	a5,40(a5)
ffffffffc02032f2:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);  // 设置内核栈地址为页面内核虚拟地址
ffffffffc02032f4:	e894                	sd	a3,16(s1)
    assert(current->mm == NULL);  // 断言当前进程没有内存管理结构（内核线程）
ffffffffc02032f6:	16079463          	bnez	a5,ffffffffc020345e <do_fork+0x1da>
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc02032fa:	6789                	lui	a5,0x2
ffffffffc02032fc:	ee078793          	addi	a5,a5,-288 # 1ee0 <kern_entry-0xffffffffc01fe120>
ffffffffc0203300:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;  // 复制陷阱帧内容
ffffffffc0203302:	8622                	mv	a2,s0
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0203304:	f0d4                	sd	a3,160(s1)
    *(proc->tf) = *tf;  // 复制陷阱帧内容
ffffffffc0203306:	87b6                	mv	a5,a3
ffffffffc0203308:	12040713          	addi	a4,s0,288
ffffffffc020330c:	6a0c                	ld	a1,16(a2)
ffffffffc020330e:	00063803          	ld	a6,0(a2)
ffffffffc0203312:	6608                	ld	a0,8(a2)
ffffffffc0203314:	eb8c                	sd	a1,16(a5)
ffffffffc0203316:	0107b023          	sd	a6,0(a5)
ffffffffc020331a:	e788                	sd	a0,8(a5)
ffffffffc020331c:	6e0c                	ld	a1,24(a2)
ffffffffc020331e:	02060613          	addi	a2,a2,32
ffffffffc0203322:	02078793          	addi	a5,a5,32
ffffffffc0203326:	feb7bc23          	sd	a1,-8(a5)
ffffffffc020332a:	fee611e3          	bne	a2,a4,ffffffffc020330c <do_fork+0x88>
    proc->tf->gpr.a0 = 0;
ffffffffc020332e:	0406b823          	sd	zero,80(a3)
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203332:	10090163          	beqz	s2,ffffffffc0203434 <do_fork+0x1b0>
    if (++last_pid >= MAX_PID)  // 如果last_pid超过最大值
ffffffffc0203336:	00006517          	auipc	a0,0x6
ffffffffc020333a:	cf652503          	lw	a0,-778(a0) # ffffffffc020902c <last_pid.1>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020333e:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203342:	00000797          	auipc	a5,0x0
ffffffffc0203346:	e7278793          	addi	a5,a5,-398 # ffffffffc02031b4 <forkret>
    if (++last_pid >= MAX_PID)  // 如果last_pid超过最大值
ffffffffc020334a:	2505                	addiw	a0,a0,1
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020334c:	f89c                	sd	a5,48(s1)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020334e:	fc94                	sd	a3,56(s1)
    if (++last_pid >= MAX_PID)  // 如果last_pid超过最大值
ffffffffc0203350:	00006717          	auipc	a4,0x6
ffffffffc0203354:	cca72e23          	sw	a0,-804(a4) # ffffffffc020902c <last_pid.1>
ffffffffc0203358:	6789                	lui	a5,0x2
ffffffffc020335a:	0cf55f63          	bge	a0,a5,ffffffffc0203438 <do_fork+0x1b4>
    if (last_pid >= next_safe)  // 如果last_pid超过安全值
ffffffffc020335e:	00006797          	auipc	a5,0x6
ffffffffc0203362:	cca7a783          	lw	a5,-822(a5) # ffffffffc0209028 <next_safe.0>
ffffffffc0203366:	0000a417          	auipc	s0,0xa
ffffffffc020336a:	0f240413          	addi	s0,s0,242 # ffffffffc020d458 <proc_list>
ffffffffc020336e:	06f54563          	blt	a0,a5,ffffffffc02033d8 <do_fork+0x154>
ffffffffc0203372:	0000a417          	auipc	s0,0xa
ffffffffc0203376:	0e640413          	addi	s0,s0,230 # ffffffffc020d458 <proc_list>
ffffffffc020337a:	00843883          	ld	a7,8(s0)
        next_safe = MAX_PID;  // 重置安全值为最大
ffffffffc020337e:	6789                	lui	a5,0x2
ffffffffc0203380:	00006717          	auipc	a4,0x6
ffffffffc0203384:	caf72423          	sw	a5,-856(a4) # ffffffffc0209028 <next_safe.0>
ffffffffc0203388:	86aa                	mv	a3,a0
ffffffffc020338a:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc020338c:	04888063          	beq	a7,s0,ffffffffc02033cc <do_fork+0x148>
ffffffffc0203390:	882e                	mv	a6,a1
ffffffffc0203392:	87c6                	mv	a5,a7
ffffffffc0203394:	6609                	lui	a2,0x2
ffffffffc0203396:	a811                	j	ffffffffc02033aa <do_fork+0x126>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0203398:	00e6d663          	bge	a3,a4,ffffffffc02033a4 <do_fork+0x120>
ffffffffc020339c:	00c75463          	bge	a4,a2,ffffffffc02033a4 <do_fork+0x120>
                next_safe = proc->pid;  // 更新安全值为下一个更大的pid
ffffffffc02033a0:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02033a2:	4805                	li	a6,1
ffffffffc02033a4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02033a6:	00878d63          	beq	a5,s0,ffffffffc02033c0 <do_fork+0x13c>
            if (proc->pid == last_pid)  // 如果pid冲突
ffffffffc02033aa:	f3c7a703          	lw	a4,-196(a5) # 1f3c <kern_entry-0xffffffffc01fe0c4>
ffffffffc02033ae:	fed715e3          	bne	a4,a3,ffffffffc0203398 <do_fork+0x114>
                if (++last_pid >= next_safe)  // 尝试下一个pid
ffffffffc02033b2:	2685                	addiw	a3,a3,1
ffffffffc02033b4:	08c6d863          	bge	a3,a2,ffffffffc0203444 <do_fork+0x1c0>
ffffffffc02033b8:	679c                	ld	a5,8(a5)
ffffffffc02033ba:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc02033bc:	fe8797e3          	bne	a5,s0,ffffffffc02033aa <do_fork+0x126>
ffffffffc02033c0:	00080663          	beqz	a6,ffffffffc02033cc <do_fork+0x148>
ffffffffc02033c4:	00006797          	auipc	a5,0x6
ffffffffc02033c8:	c6c7a223          	sw	a2,-924(a5) # ffffffffc0209028 <next_safe.0>
ffffffffc02033cc:	c591                	beqz	a1,ffffffffc02033d8 <do_fork+0x154>
ffffffffc02033ce:	00006797          	auipc	a5,0x6
ffffffffc02033d2:	c4d7af23          	sw	a3,-930(a5) # ffffffffc020902c <last_pid.1>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc02033d6:	8536                	mv	a0,a3
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));  // 根据pid哈希值添加到对应链表
ffffffffc02033d8:	45a9                	li	a1,10
    proc->pid = get_pid();  // 为进程分配pid
ffffffffc02033da:	c0c8                	sw	a0,4(s1)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));  // 根据pid哈希值添加到对应链表
ffffffffc02033dc:	4c8000ef          	jal	ffffffffc02038a4 <hash32>
ffffffffc02033e0:	02051793          	slli	a5,a0,0x20
ffffffffc02033e4:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02033e8:	00006797          	auipc	a5,0x6
ffffffffc02033ec:	07078793          	addi	a5,a5,112 # ffffffffc0209458 <hash_list>
ffffffffc02033f0:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc02033f2:	6518                	ld	a4,8(a0)
ffffffffc02033f4:	0d848793          	addi	a5,s1,216
ffffffffc02033f8:	6414                	ld	a3,8(s0)
    prev->next = next->prev = elm;
ffffffffc02033fa:	e31c                	sd	a5,0(a4)
ffffffffc02033fc:	e51c                	sd	a5,8(a0)
    nr_process++;  // 增加进程计数
ffffffffc02033fe:	0000a797          	auipc	a5,0xa
ffffffffc0203402:	0d27a783          	lw	a5,210(a5) # ffffffffc020d4d0 <nr_process>
    elm->next = next;
ffffffffc0203406:	f0f8                	sd	a4,224(s1)
    elm->prev = prev;
ffffffffc0203408:	ece8                	sd	a0,216(s1)
    list_add(&proc_list, &(proc->list_link));  // 添加到进程链表
ffffffffc020340a:	0c848713          	addi	a4,s1,200
    prev->next = next->prev = elm;
ffffffffc020340e:	e298                	sd	a4,0(a3)
    wakeup_proc(proc);
ffffffffc0203410:	8526                	mv	a0,s1
    nr_process++;  // 增加进程计数
ffffffffc0203412:	2785                	addiw	a5,a5,1
    elm->next = next;
ffffffffc0203414:	e8f4                	sd	a3,208(s1)
    elm->prev = prev;
ffffffffc0203416:	e4e0                	sd	s0,200(s1)
    prev->next = next->prev = elm;
ffffffffc0203418:	e418                	sd	a4,8(s0)
ffffffffc020341a:	0000a717          	auipc	a4,0xa
ffffffffc020341e:	0af72b23          	sw	a5,182(a4) # ffffffffc020d4d0 <nr_process>
    wakeup_proc(proc);
ffffffffc0203422:	3bc000ef          	jal	ffffffffc02037de <wakeup_proc>
    ret = proc->pid;
ffffffffc0203426:	40c8                	lw	a0,4(s1)
}
ffffffffc0203428:	60e2                	ld	ra,24(sp)
ffffffffc020342a:	6442                	ld	s0,16(sp)
ffffffffc020342c:	64a2                	ld	s1,8(sp)
ffffffffc020342e:	6902                	ld	s2,0(sp)
ffffffffc0203430:	6105                	addi	sp,sp,32
ffffffffc0203432:	8082                	ret
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203434:	8936                	mv	s2,a3
ffffffffc0203436:	b701                	j	ffffffffc0203336 <do_fork+0xb2>
        last_pid = 1;  // 回绕到1
ffffffffc0203438:	4505                	li	a0,1
ffffffffc020343a:	00006797          	auipc	a5,0x6
ffffffffc020343e:	bea7a923          	sw	a0,-1038(a5) # ffffffffc020902c <last_pid.1>
        goto inside;
ffffffffc0203442:	bf05                	j	ffffffffc0203372 <do_fork+0xee>
                    if (last_pid >= MAX_PID)  // 如果超过最大值
ffffffffc0203444:	6789                	lui	a5,0x2
ffffffffc0203446:	00f6c363          	blt	a3,a5,ffffffffc020344c <do_fork+0x1c8>
                        last_pid = 1;  // 回绕到1
ffffffffc020344a:	4685                	li	a3,1
                    goto repeat;  // 重新开始查找
ffffffffc020344c:	4585                	li	a1,1
ffffffffc020344e:	bf3d                	j	ffffffffc020338c <do_fork+0x108>
    kfree(proc);  // 释放进程结构内存
ffffffffc0203450:	8526                	mv	a0,s1
ffffffffc0203452:	e34fe0ef          	jal	ffffffffc0201a86 <kfree>
    ret = -E_NO_MEM;  // 设置错误码为内存不足
ffffffffc0203456:	5571                	li	a0,-4
ffffffffc0203458:	bfc1                	j	ffffffffc0203428 <do_fork+0x1a4>
    int ret = -E_NO_FREE_PROC;  // 默认返回错误：无空闲进程
ffffffffc020345a:	556d                	li	a0,-5
}
ffffffffc020345c:	8082                	ret
    assert(current->mm == NULL);  // 断言当前进程没有内存管理结构（内核线程）
ffffffffc020345e:	00002697          	auipc	a3,0x2
ffffffffc0203462:	f7268693          	addi	a3,a3,-142 # ffffffffc02053d0 <etext+0x1648>
ffffffffc0203466:	00001617          	auipc	a2,0x1
ffffffffc020346a:	2ea60613          	addi	a2,a2,746 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020346e:	11e00593          	li	a1,286
ffffffffc0203472:	00002517          	auipc	a0,0x2
ffffffffc0203476:	f7650513          	addi	a0,a0,-138 # ffffffffc02053e8 <etext+0x1660>
ffffffffc020347a:	f8dfc0ef          	jal	ffffffffc0200406 <__panic>
ffffffffc020347e:	00001617          	auipc	a2,0x1
ffffffffc0203482:	61260613          	addi	a2,a2,1554 # ffffffffc0204a90 <etext+0xd08>
ffffffffc0203486:	07100593          	li	a1,113
ffffffffc020348a:	00001517          	auipc	a0,0x1
ffffffffc020348e:	62e50513          	addi	a0,a0,1582 # ffffffffc0204ab8 <etext+0xd30>
ffffffffc0203492:	f75fc0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0203496 <kernel_thread>:
{
ffffffffc0203496:	7129                	addi	sp,sp,-320
ffffffffc0203498:	fa22                	sd	s0,304(sp)
ffffffffc020349a:	f626                	sd	s1,296(sp)
ffffffffc020349c:	f24a                	sd	s2,288(sp)
ffffffffc020349e:	842a                	mv	s0,a0
ffffffffc02034a0:	84ae                	mv	s1,a1
ffffffffc02034a2:	8932                	mv	s2,a2
    memset(&tf, 0, sizeof(struct trapframe));  // 清空陷阱帧
ffffffffc02034a4:	850a                	mv	a0,sp
ffffffffc02034a6:	12000613          	li	a2,288
ffffffffc02034aa:	4581                	li	a1,0
{
ffffffffc02034ac:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));  // 清空陷阱帧
ffffffffc02034ae:	08d000ef          	jal	ffffffffc0203d3a <memset>
    tf.gpr.s0 = (uintptr_t)fn;     // 将函数指针保存在s0寄存器
ffffffffc02034b2:	e0a2                	sd	s0,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;    // 将参数指针保存在s1寄存器
ffffffffc02034b4:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;  // 设置状态寄存器
ffffffffc02034b6:	100027f3          	csrr	a5,sstatus
ffffffffc02034ba:	edd7f793          	andi	a5,a5,-291
ffffffffc02034be:	1207e793          	ori	a5,a5,288
    return do_fork(clone_flags | CLONE_VM, 0, &tf);  // 调用do_fork创建线程
ffffffffc02034c2:	860a                	mv	a2,sp
ffffffffc02034c4:	10096513          	ori	a0,s2,256
    tf.epc = (uintptr_t)kernel_thread_entry;  // 设置入口点为kernel_thread_entry
ffffffffc02034c8:	00000717          	auipc	a4,0x0
ffffffffc02034cc:	c8270713          	addi	a4,a4,-894 # ffffffffc020314a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);  // 调用do_fork创建线程
ffffffffc02034d0:	4581                	li	a1,0
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;  // 设置状态寄存器
ffffffffc02034d2:	e23e                	sd	a5,256(sp)
    tf.epc = (uintptr_t)kernel_thread_entry;  // 设置入口点为kernel_thread_entry
ffffffffc02034d4:	e63a                	sd	a4,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);  // 调用do_fork创建线程
ffffffffc02034d6:	dafff0ef          	jal	ffffffffc0203284 <do_fork>
}
ffffffffc02034da:	70f2                	ld	ra,312(sp)
ffffffffc02034dc:	7452                	ld	s0,304(sp)
ffffffffc02034de:	74b2                	ld	s1,296(sp)
ffffffffc02034e0:	7912                	ld	s2,288(sp)
ffffffffc02034e2:	6131                	addi	sp,sp,320
ffffffffc02034e4:	8082                	ret

ffffffffc02034e6 <do_exit>:
{
ffffffffc02034e6:	1141                	addi	sp,sp,-16
    panic("process exit!!.\n");  // 暂时用panic处理，实际实现需要完成上述步骤
ffffffffc02034e8:	00002617          	auipc	a2,0x2
ffffffffc02034ec:	f1860613          	addi	a2,a2,-232 # ffffffffc0205400 <etext+0x1678>
ffffffffc02034f0:	18c00593          	li	a1,396
ffffffffc02034f4:	00002517          	auipc	a0,0x2
ffffffffc02034f8:	ef450513          	addi	a0,a0,-268 # ffffffffc02053e8 <etext+0x1660>
{
ffffffffc02034fc:	e406                	sd	ra,8(sp)
    panic("process exit!!.\n");  // 暂时用panic处理，实际实现需要完成上述步骤
ffffffffc02034fe:	f09fc0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0203502 <proc_init>:

// proc_init - 设置第一个内核线程idleproc "idle"，并创建第二个内核线程init_main
void proc_init(void)
{
ffffffffc0203502:	7179                	addi	sp,sp,-48
ffffffffc0203504:	ec26                	sd	s1,24(sp)
    elm->prev = elm->next = elm;
ffffffffc0203506:	0000a797          	auipc	a5,0xa
ffffffffc020350a:	f5278793          	addi	a5,a5,-174 # ffffffffc020d458 <proc_list>
ffffffffc020350e:	f406                	sd	ra,40(sp)
ffffffffc0203510:	f022                	sd	s0,32(sp)
ffffffffc0203512:	e84a                	sd	s2,16(sp)
ffffffffc0203514:	e44e                	sd	s3,8(sp)
ffffffffc0203516:	00006497          	auipc	s1,0x6
ffffffffc020351a:	f4248493          	addi	s1,s1,-190 # ffffffffc0209458 <hash_list>
ffffffffc020351e:	e79c                	sd	a5,8(a5)
ffffffffc0203520:	e39c                	sd	a5,0(a5)
    int i;

    // 初始化进程链表
    list_init(&proc_list);
    // 初始化哈希链表数组
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0203522:	0000a717          	auipc	a4,0xa
ffffffffc0203526:	f3670713          	addi	a4,a4,-202 # ffffffffc020d458 <proc_list>
ffffffffc020352a:	87a6                	mv	a5,s1
ffffffffc020352c:	e79c                	sd	a5,8(a5)
ffffffffc020352e:	e39c                	sd	a5,0(a5)
ffffffffc0203530:	07c1                	addi	a5,a5,16
ffffffffc0203532:	fee79de3          	bne	a5,a4,ffffffffc020352c <proc_init+0x2a>
    {
        list_init(hash_list + i);
    }

    // 分配空闲进程结构
    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0203536:	c1dff0ef          	jal	ffffffffc0203152 <alloc_proc>
ffffffffc020353a:	0000a917          	auipc	s2,0xa
ffffffffc020353e:	fae90913          	addi	s2,s2,-82 # ffffffffc020d4e8 <idleproc>
ffffffffc0203542:	00a93023          	sd	a0,0(s2)
ffffffffc0203546:	1a050263          	beqz	a0,ffffffffc02036ea <proc_init+0x1e8>
    {
        panic("cannot alloc idleproc.\n");
    }

    // 检查进程结构初始化是否正确
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc020354a:	07000513          	li	a0,112
ffffffffc020354e:	c92fe0ef          	jal	ffffffffc02019e0 <kmalloc>
    memset(context_mem, 0, sizeof(struct context));
ffffffffc0203552:	07000613          	li	a2,112
ffffffffc0203556:	4581                	li	a1,0
    int *context_mem = (int *)kmalloc(sizeof(struct context));
ffffffffc0203558:	842a                	mv	s0,a0
    memset(context_mem, 0, sizeof(struct context));
ffffffffc020355a:	7e0000ef          	jal	ffffffffc0203d3a <memset>
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));
ffffffffc020355e:	00093503          	ld	a0,0(s2)
ffffffffc0203562:	85a2                	mv	a1,s0
ffffffffc0203564:	07000613          	li	a2,112
ffffffffc0203568:	03050513          	addi	a0,a0,48
ffffffffc020356c:	7f8000ef          	jal	ffffffffc0203d64 <memcmp>
ffffffffc0203570:	89aa                	mv	s3,a0

    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc0203572:	453d                	li	a0,15
ffffffffc0203574:	c6cfe0ef          	jal	ffffffffc02019e0 <kmalloc>
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc0203578:	463d                	li	a2,15
ffffffffc020357a:	4581                	li	a1,0
    int *proc_name_mem = (int *)kmalloc(PROC_NAME_LEN);
ffffffffc020357c:	842a                	mv	s0,a0
    memset(proc_name_mem, 0, PROC_NAME_LEN);
ffffffffc020357e:	7bc000ef          	jal	ffffffffc0203d3a <memset>
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);
ffffffffc0203582:	00093503          	ld	a0,0(s2)
ffffffffc0203586:	85a2                	mv	a1,s0
ffffffffc0203588:	463d                	li	a2,15
ffffffffc020358a:	0b450513          	addi	a0,a0,180
ffffffffc020358e:	7d6000ef          	jal	ffffffffc0203d64 <memcmp>

    // 验证所有字段都正确初始化
    if (idleproc->pgdir == boot_pgdir_pa && idleproc->tf == NULL && !context_init_flag && 
ffffffffc0203592:	00093783          	ld	a5,0(s2)
ffffffffc0203596:	0000a717          	auipc	a4,0xa
ffffffffc020359a:	f1273703          	ld	a4,-238(a4) # ffffffffc020d4a8 <boot_pgdir_pa>
ffffffffc020359e:	77d4                	ld	a3,168(a5)
ffffffffc02035a0:	0ee68863          	beq	a3,a4,ffffffffc0203690 <proc_init+0x18e>
        cprintf("alloc_proc() correct!\n");  // 分配进程结构正确
    }

    // 设置空闲进程属性
    idleproc->pid = 0;  // 空闲进程pid为0
    idleproc->state = PROC_RUNNABLE;  // 设置为可运行状态
ffffffffc02035a4:	4709                	li	a4,2
ffffffffc02035a6:	e398                	sd	a4,0(a5)
    idleproc->kstack = (uintptr_t)bootstack;  // 使用启动栈作为内核栈
ffffffffc02035a8:	00003717          	auipc	a4,0x3
ffffffffc02035ac:	a5870713          	addi	a4,a4,-1448 # ffffffffc0206000 <bootstack>
    memset(proc->name, 0, sizeof(proc->name));  // 先清空名称缓冲区
ffffffffc02035b0:	0b478413          	addi	s0,a5,180
    idleproc->kstack = (uintptr_t)bootstack;  // 使用启动栈作为内核栈
ffffffffc02035b4:	eb98                	sd	a4,16(a5)
    idleproc->need_resched = 1;  // 需要调度
ffffffffc02035b6:	4705                	li	a4,1
ffffffffc02035b8:	cf98                	sw	a4,24(a5)
    memset(proc->name, 0, sizeof(proc->name));  // 先清空名称缓冲区
ffffffffc02035ba:	8522                	mv	a0,s0
ffffffffc02035bc:	4641                	li	a2,16
ffffffffc02035be:	4581                	li	a1,0
ffffffffc02035c0:	77a000ef          	jal	ffffffffc0203d3a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);  // 复制新名称
ffffffffc02035c4:	8522                	mv	a0,s0
ffffffffc02035c6:	463d                	li	a2,15
ffffffffc02035c8:	00002597          	auipc	a1,0x2
ffffffffc02035cc:	e8058593          	addi	a1,a1,-384 # ffffffffc0205448 <etext+0x16c0>
ffffffffc02035d0:	77c000ef          	jal	ffffffffc0203d4c <memcpy>
    set_proc_name(idleproc, "idle");  // 设置进程名为"idle"
    nr_process++;  // 增加进程计数
ffffffffc02035d4:	0000a797          	auipc	a5,0xa
ffffffffc02035d8:	efc7a783          	lw	a5,-260(a5) # ffffffffc020d4d0 <nr_process>

    current = idleproc;  // 设置当前进程为空闲进程
ffffffffc02035dc:	00093703          	ld	a4,0(s2)

    // 创建初始化进程
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02035e0:	4601                	li	a2,0
    nr_process++;  // 增加进程计数
ffffffffc02035e2:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc02035e4:	00002597          	auipc	a1,0x2
ffffffffc02035e8:	e6c58593          	addi	a1,a1,-404 # ffffffffc0205450 <etext+0x16c8>
ffffffffc02035ec:	00000517          	auipc	a0,0x0
ffffffffc02035f0:	bd650513          	addi	a0,a0,-1066 # ffffffffc02031c2 <init_main>
    current = idleproc;  // 设置当前进程为空闲进程
ffffffffc02035f4:	0000a697          	auipc	a3,0xa
ffffffffc02035f8:	eee6b223          	sd	a4,-284(a3) # ffffffffc020d4d8 <current>
    nr_process++;  // 增加进程计数
ffffffffc02035fc:	0000a717          	auipc	a4,0xa
ffffffffc0203600:	ecf72a23          	sw	a5,-300(a4) # ffffffffc020d4d0 <nr_process>
    int pid = kernel_thread(init_main, "Hello world!!", 0);
ffffffffc0203604:	e93ff0ef          	jal	ffffffffc0203496 <kernel_thread>
ffffffffc0203608:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc020360a:	0ea05c63          	blez	a0,ffffffffc0203702 <proc_init+0x200>
    if (0 < pid && pid < MAX_PID)  // 检查pid有效性
ffffffffc020360e:	6789                	lui	a5,0x2
ffffffffc0203610:	17f9                	addi	a5,a5,-2 # 1ffe <kern_entry-0xffffffffc01fe002>
ffffffffc0203612:	fff5071b          	addiw	a4,a0,-1
ffffffffc0203616:	02e7e463          	bltu	a5,a4,ffffffffc020363e <proc_init+0x13c>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;  // 获取对应哈希桶
ffffffffc020361a:	45a9                	li	a1,10
ffffffffc020361c:	288000ef          	jal	ffffffffc02038a4 <hash32>
ffffffffc0203620:	02051713          	slli	a4,a0,0x20
ffffffffc0203624:	01c75793          	srli	a5,a4,0x1c
ffffffffc0203628:	00f486b3          	add	a3,s1,a5
ffffffffc020362c:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)  // 遍历哈希链表
ffffffffc020362e:	a029                	j	ffffffffc0203638 <proc_init+0x136>
            if (proc->pid == pid)  // 如果pid匹配
ffffffffc0203630:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0203634:	0a870863          	beq	a4,s0,ffffffffc02036e4 <proc_init+0x1e2>
    return listelm->next;
ffffffffc0203638:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)  // 遍历哈希链表
ffffffffc020363a:	fef69be3          	bne	a3,a5,ffffffffc0203630 <proc_init+0x12e>
    return NULL;  // 未找到返回NULL
ffffffffc020363e:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));  // 先清空名称缓冲区
ffffffffc0203640:	0b478413          	addi	s0,a5,180
ffffffffc0203644:	4641                	li	a2,16
ffffffffc0203646:	4581                	li	a1,0
ffffffffc0203648:	8522                	mv	a0,s0
    {
        panic("create init_main failed.\n");  // 创建失败则panic
    }

    initproc = find_proc(pid);  // 查找初始化进程
ffffffffc020364a:	0000a717          	auipc	a4,0xa
ffffffffc020364e:	e8f73b23          	sd	a5,-362(a4) # ffffffffc020d4e0 <initproc>
    memset(proc->name, 0, sizeof(proc->name));  // 先清空名称缓冲区
ffffffffc0203652:	6e8000ef          	jal	ffffffffc0203d3a <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);  // 复制新名称
ffffffffc0203656:	8522                	mv	a0,s0
ffffffffc0203658:	463d                	li	a2,15
ffffffffc020365a:	00002597          	auipc	a1,0x2
ffffffffc020365e:	e2658593          	addi	a1,a1,-474 # ffffffffc0205480 <etext+0x16f8>
ffffffffc0203662:	6ea000ef          	jal	ffffffffc0203d4c <memcpy>
    set_proc_name(initproc, "init");  // 设置进程名为"init"

    // 验证空闲进程和初始化进程创建成功
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0203666:	00093783          	ld	a5,0(s2)
ffffffffc020366a:	cbe1                	beqz	a5,ffffffffc020373a <proc_init+0x238>
ffffffffc020366c:	43dc                	lw	a5,4(a5)
ffffffffc020366e:	e7f1                	bnez	a5,ffffffffc020373a <proc_init+0x238>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0203670:	0000a797          	auipc	a5,0xa
ffffffffc0203674:	e707b783          	ld	a5,-400(a5) # ffffffffc020d4e0 <initproc>
ffffffffc0203678:	c3cd                	beqz	a5,ffffffffc020371a <proc_init+0x218>
ffffffffc020367a:	43d8                	lw	a4,4(a5)
ffffffffc020367c:	4785                	li	a5,1
ffffffffc020367e:	08f71e63          	bne	a4,a5,ffffffffc020371a <proc_init+0x218>
}
ffffffffc0203682:	70a2                	ld	ra,40(sp)
ffffffffc0203684:	7402                	ld	s0,32(sp)
ffffffffc0203686:	64e2                	ld	s1,24(sp)
ffffffffc0203688:	6942                	ld	s2,16(sp)
ffffffffc020368a:	69a2                	ld	s3,8(sp)
ffffffffc020368c:	6145                	addi	sp,sp,48
ffffffffc020368e:	8082                	ret
    if (idleproc->pgdir == boot_pgdir_pa && idleproc->tf == NULL && !context_init_flag && 
ffffffffc0203690:	73d8                	ld	a4,160(a5)
ffffffffc0203692:	f00719e3          	bnez	a4,ffffffffc02035a4 <proc_init+0xa2>
ffffffffc0203696:	f00997e3          	bnez	s3,ffffffffc02035a4 <proc_init+0xa2>
ffffffffc020369a:	4398                	lw	a4,0(a5)
ffffffffc020369c:	f00714e3          	bnez	a4,ffffffffc02035a4 <proc_init+0xa2>
        idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0 && 
ffffffffc02036a0:	43d4                	lw	a3,4(a5)
ffffffffc02036a2:	577d                	li	a4,-1
ffffffffc02036a4:	f0e690e3          	bne	a3,a4,ffffffffc02035a4 <proc_init+0xa2>
ffffffffc02036a8:	4798                	lw	a4,8(a5)
ffffffffc02036aa:	ee071de3          	bnez	a4,ffffffffc02035a4 <proc_init+0xa2>
ffffffffc02036ae:	6b98                	ld	a4,16(a5)
ffffffffc02036b0:	ee071ae3          	bnez	a4,ffffffffc02035a4 <proc_init+0xa2>
        idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL && 
ffffffffc02036b4:	4f98                	lw	a4,24(a5)
ffffffffc02036b6:	ee0717e3          	bnez	a4,ffffffffc02035a4 <proc_init+0xa2>
ffffffffc02036ba:	7398                	ld	a4,32(a5)
ffffffffc02036bc:	ee0714e3          	bnez	a4,ffffffffc02035a4 <proc_init+0xa2>
ffffffffc02036c0:	7798                	ld	a4,40(a5)
ffffffffc02036c2:	ee0711e3          	bnez	a4,ffffffffc02035a4 <proc_init+0xa2>
        idleproc->mm == NULL && idleproc->flags == 0 && !proc_name_flag)
ffffffffc02036c6:	0b07a703          	lw	a4,176(a5)
ffffffffc02036ca:	8f49                	or	a4,a4,a0
ffffffffc02036cc:	2701                	sext.w	a4,a4
ffffffffc02036ce:	ec071be3          	bnez	a4,ffffffffc02035a4 <proc_init+0xa2>
        cprintf("alloc_proc() correct!\n");  // 分配进程结构正确
ffffffffc02036d2:	00002517          	auipc	a0,0x2
ffffffffc02036d6:	d5e50513          	addi	a0,a0,-674 # ffffffffc0205430 <etext+0x16a8>
ffffffffc02036da:	abbfc0ef          	jal	ffffffffc0200194 <cprintf>
    idleproc->pid = 0;  // 空闲进程pid为0
ffffffffc02036de:	00093783          	ld	a5,0(s2)
ffffffffc02036e2:	b5c9                	j	ffffffffc02035a4 <proc_init+0xa2>
            struct proc_struct *proc = le2proc(le, hash_link);  // 获取进程结构
ffffffffc02036e4:	f2878793          	addi	a5,a5,-216
ffffffffc02036e8:	bfa1                	j	ffffffffc0203640 <proc_init+0x13e>
        panic("cannot alloc idleproc.\n");
ffffffffc02036ea:	00002617          	auipc	a2,0x2
ffffffffc02036ee:	d2e60613          	addi	a2,a2,-722 # ffffffffc0205418 <etext+0x1690>
ffffffffc02036f2:	1a900593          	li	a1,425
ffffffffc02036f6:	00002517          	auipc	a0,0x2
ffffffffc02036fa:	cf250513          	addi	a0,a0,-782 # ffffffffc02053e8 <etext+0x1660>
ffffffffc02036fe:	d09fc0ef          	jal	ffffffffc0200406 <__panic>
        panic("create init_main failed.\n");  // 创建失败则panic
ffffffffc0203702:	00002617          	auipc	a2,0x2
ffffffffc0203706:	d5e60613          	addi	a2,a2,-674 # ffffffffc0205460 <etext+0x16d8>
ffffffffc020370a:	1cc00593          	li	a1,460
ffffffffc020370e:	00002517          	auipc	a0,0x2
ffffffffc0203712:	cda50513          	addi	a0,a0,-806 # ffffffffc02053e8 <etext+0x1660>
ffffffffc0203716:	cf1fc0ef          	jal	ffffffffc0200406 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc020371a:	00002697          	auipc	a3,0x2
ffffffffc020371e:	d9668693          	addi	a3,a3,-618 # ffffffffc02054b0 <etext+0x1728>
ffffffffc0203722:	00001617          	auipc	a2,0x1
ffffffffc0203726:	02e60613          	addi	a2,a2,46 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020372a:	1d400593          	li	a1,468
ffffffffc020372e:	00002517          	auipc	a0,0x2
ffffffffc0203732:	cba50513          	addi	a0,a0,-838 # ffffffffc02053e8 <etext+0x1660>
ffffffffc0203736:	cd1fc0ef          	jal	ffffffffc0200406 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020373a:	00002697          	auipc	a3,0x2
ffffffffc020373e:	d4e68693          	addi	a3,a3,-690 # ffffffffc0205488 <etext+0x1700>
ffffffffc0203742:	00001617          	auipc	a2,0x1
ffffffffc0203746:	00e60613          	addi	a2,a2,14 # ffffffffc0204750 <etext+0x9c8>
ffffffffc020374a:	1d300593          	li	a1,467
ffffffffc020374e:	00002517          	auipc	a0,0x2
ffffffffc0203752:	c9a50513          	addi	a0,a0,-870 # ffffffffc02053e8 <etext+0x1660>
ffffffffc0203756:	cb1fc0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc020375a <cpu_idle>:

// cpu_idle - 在kern_init的最后，第一个内核线程idleproc将执行以下工作
void cpu_idle(void)
{
ffffffffc020375a:	1141                	addi	sp,sp,-16
ffffffffc020375c:	e022                	sd	s0,0(sp)
ffffffffc020375e:	e406                	sd	ra,8(sp)
ffffffffc0203760:	0000a417          	auipc	s0,0xa
ffffffffc0203764:	d7840413          	addi	s0,s0,-648 # ffffffffc020d4d8 <current>
    while (1)  // 无限循环
    {
        if (current->need_resched)  // 如果需要重新调度
ffffffffc0203768:	6018                	ld	a4,0(s0)
ffffffffc020376a:	4f1c                	lw	a5,24(a4)
ffffffffc020376c:	dffd                	beqz	a5,ffffffffc020376a <cpu_idle+0x10>
        {
            schedule();  // 调用调度器
ffffffffc020376e:	0a2000ef          	jal	ffffffffc0203810 <schedule>
ffffffffc0203772:	bfdd                	j	ffffffffc0203768 <cpu_idle+0xe>

ffffffffc0203774 <switch_to>:
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # 保存from进程的寄存器到其上下文结构中
    # a0寄存器包含from进程的context指针
    STORE ra, 0*REGBYTES(a0)   # 保存返回地址寄存器
ffffffffc0203774:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)   # 保存栈指针寄存器  
ffffffffc0203778:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)   # 保存s0寄存器
ffffffffc020377c:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)   # 保存s1寄存器
ffffffffc020377e:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)   # 保存s2寄存器
ffffffffc0203780:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)   # 保存s3寄存器
ffffffffc0203784:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)   # 保存s4寄存器
ffffffffc0203788:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)   # 保存s5寄存器
ffffffffc020378c:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)   # 保存s6寄存器
ffffffffc0203790:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)   # 保存s7寄存器
ffffffffc0203794:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)  # 保存s8寄存器
ffffffffc0203798:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)  # 保存s9寄存器
ffffffffc020379c:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0) # 保存s10寄存器
ffffffffc02037a0:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0) # 保存s11寄存器
ffffffffc02037a4:	07b53423          	sd	s11,104(a0)

    # 从to进程的上下文结构中恢复寄存器
    # a1寄存器包含to进程的context指针
    LOAD ra, 0*REGBYTES(a1)    # 恢复返回地址寄存器
ffffffffc02037a8:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)    # 恢复栈指针寄存器
ffffffffc02037ac:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)    # 恢复s0寄存器
ffffffffc02037b0:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)    # 恢复s1寄存器
ffffffffc02037b2:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)    # 恢复s2寄存器
ffffffffc02037b4:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)    # 恢复s3寄存器
ffffffffc02037b8:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)    # 恢复s4寄存器
ffffffffc02037bc:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)    # 恢复s5寄存器
ffffffffc02037c0:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)    # 恢复s6寄存器
ffffffffc02037c4:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)    # 恢复s7寄存器
ffffffffc02037c8:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)   # 恢复s8寄存器
ffffffffc02037cc:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)   # 恢复s9寄存器
ffffffffc02037d0:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)  # 恢复s10寄存器
ffffffffc02037d4:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)  # 恢复s11寄存器
ffffffffc02037d8:	0685bd83          	ld	s11,104(a1)

ffffffffc02037dc:	8082                	ret

ffffffffc02037de <wakeup_proc>:

// wakeup_proc - 唤醒进程，将其状态设置为可运行
void
wakeup_proc(struct proc_struct *proc) {
    // 断言：进程不能是僵尸状态或已经是可运行状态
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02037de:	411c                	lw	a5,0(a0)
ffffffffc02037e0:	4705                	li	a4,1
ffffffffc02037e2:	37f9                	addiw	a5,a5,-2
ffffffffc02037e4:	00f77563          	bgeu	a4,a5,ffffffffc02037ee <wakeup_proc+0x10>
    // 设置进程状态为可运行
    proc->state = PROC_RUNNABLE;
ffffffffc02037e8:	4789                	li	a5,2
ffffffffc02037ea:	c11c                	sw	a5,0(a0)
ffffffffc02037ec:	8082                	ret
wakeup_proc(struct proc_struct *proc) {
ffffffffc02037ee:	1141                	addi	sp,sp,-16
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc02037f0:	00002697          	auipc	a3,0x2
ffffffffc02037f4:	ce868693          	addi	a3,a3,-792 # ffffffffc02054d8 <etext+0x1750>
ffffffffc02037f8:	00001617          	auipc	a2,0x1
ffffffffc02037fc:	f5860613          	addi	a2,a2,-168 # ffffffffc0204750 <etext+0x9c8>
ffffffffc0203800:	45ad                	li	a1,11
ffffffffc0203802:	00002517          	auipc	a0,0x2
ffffffffc0203806:	d1650513          	addi	a0,a0,-746 # ffffffffc0205518 <etext+0x1790>
wakeup_proc(struct proc_struct *proc) {
ffffffffc020380a:	e406                	sd	ra,8(sp)
    assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
ffffffffc020380c:	bfbfc0ef          	jal	ffffffffc0200406 <__panic>

ffffffffc0203810 <schedule>:
}

// schedule - 进程调度函数，选择下一个要运行的进程
void
schedule(void) {
ffffffffc0203810:	1101                	addi	sp,sp,-32
ffffffffc0203812:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203814:	100027f3          	csrr	a5,sstatus
ffffffffc0203818:	8b89                	andi	a5,a5,2
ffffffffc020381a:	4301                	li	t1,0
ffffffffc020381c:	e3c1                	bnez	a5,ffffffffc020389c <schedule+0x8c>
    
    // 保存中断状态并禁用中断（临界区开始）
    local_intr_save(intr_flag);
    {
        // 清除当前进程的重新调度标志
        current->need_resched = 0;
ffffffffc020381e:	0000a897          	auipc	a7,0xa
ffffffffc0203822:	cba8b883          	ld	a7,-838(a7) # ffffffffc020d4d8 <current>
        
        // 确定遍历起始位置：如果当前是空闲进程，从链表头开始；否则从当前进程的下一个开始
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0203826:	0000a517          	auipc	a0,0xa
ffffffffc020382a:	cc253503          	ld	a0,-830(a0) # ffffffffc020d4e8 <idleproc>
        current->need_resched = 0;
ffffffffc020382e:	0008ac23          	sw	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0203832:	04a88f63          	beq	a7,a0,ffffffffc0203890 <schedule+0x80>
ffffffffc0203836:	0c888693          	addi	a3,a7,200
ffffffffc020383a:	0000a617          	auipc	a2,0xa
ffffffffc020383e:	c1e60613          	addi	a2,a2,-994 # ffffffffc020d458 <proc_list>
        le = last;
ffffffffc0203842:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;  // 下一个要运行的进程
ffffffffc0203844:	4581                	li	a1,0
        do {
            // 移动到下一个进程
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);  // 获取进程结构
                // 如果找到可运行进程，跳出循环
                if (next->state == PROC_RUNNABLE) {
ffffffffc0203846:	4809                	li	a6,2
ffffffffc0203848:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc020384a:	00c78863          	beq	a5,a2,ffffffffc020385a <schedule+0x4a>
                if (next->state == PROC_RUNNABLE) {
ffffffffc020384e:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);  // 获取进程结构
ffffffffc0203852:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0203856:	03070363          	beq	a4,a6,ffffffffc020387c <schedule+0x6c>
                    break;
                }
            }
        } while (le != last);  // 遍历直到回到起点
ffffffffc020385a:	fef697e3          	bne	a3,a5,ffffffffc0203848 <schedule+0x38>
        
        // 如果没有找到可运行进程，使用空闲进程
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020385e:	ed99                	bnez	a1,ffffffffc020387c <schedule+0x6c>
            next = idleproc;
        }
        
        // 增加选中进程的运行计数
        next->runs ++;
ffffffffc0203860:	451c                	lw	a5,8(a0)
ffffffffc0203862:	2785                	addiw	a5,a5,1
ffffffffc0203864:	c51c                	sw	a5,8(a0)
        
        // 如果选中的进程不是当前进程，进行进程切换
        if (next != current) {
ffffffffc0203866:	00a88663          	beq	a7,a0,ffffffffc0203872 <schedule+0x62>
ffffffffc020386a:	e41a                	sd	t1,8(sp)
            proc_run(next);  // 切换到新进程
ffffffffc020386c:	9c7ff0ef          	jal	ffffffffc0203232 <proc_run>
ffffffffc0203870:	6322                	ld	t1,8(sp)
    if (flag) {
ffffffffc0203872:	00031b63          	bnez	t1,ffffffffc0203888 <schedule+0x78>
        }
    }
    // 恢复中断状态（临界区结束）
    local_intr_restore(intr_flag);
ffffffffc0203876:	60e2                	ld	ra,24(sp)
ffffffffc0203878:	6105                	addi	sp,sp,32
ffffffffc020387a:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc020387c:	4198                	lw	a4,0(a1)
ffffffffc020387e:	4789                	li	a5,2
ffffffffc0203880:	fef710e3          	bne	a4,a5,ffffffffc0203860 <schedule+0x50>
ffffffffc0203884:	852e                	mv	a0,a1
ffffffffc0203886:	bfe9                	j	ffffffffc0203860 <schedule+0x50>
ffffffffc0203888:	60e2                	ld	ra,24(sp)
ffffffffc020388a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020388c:	fe3fc06f          	j	ffffffffc020086e <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0203890:	0000a617          	auipc	a2,0xa
ffffffffc0203894:	bc860613          	addi	a2,a2,-1080 # ffffffffc020d458 <proc_list>
ffffffffc0203898:	86b2                	mv	a3,a2
ffffffffc020389a:	b765                	j	ffffffffc0203842 <schedule+0x32>
        intr_disable();
ffffffffc020389c:	fd9fc0ef          	jal	ffffffffc0200874 <intr_disable>
        return 1;
ffffffffc02038a0:	4305                	li	t1,1
ffffffffc02038a2:	bfb5                	j	ffffffffc020381e <schedule+0xe>

ffffffffc02038a4 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02038a4:	9e3707b7          	lui	a5,0x9e370
ffffffffc02038a8:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <kern_entry-0x21e8ffff>
ffffffffc02038aa:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc02038ae:	02000513          	li	a0,32
ffffffffc02038b2:	9d0d                	subw	a0,a0,a1
}
ffffffffc02038b4:	00a7d53b          	srlw	a0,a5,a0
ffffffffc02038b8:	8082                	ret

ffffffffc02038ba <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02038ba:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02038bc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02038c0:	f022                	sd	s0,32(sp)
ffffffffc02038c2:	ec26                	sd	s1,24(sp)
ffffffffc02038c4:	e84a                	sd	s2,16(sp)
ffffffffc02038c6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02038c8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02038cc:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc02038ce:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02038d2:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02038d6:	84aa                	mv	s1,a0
ffffffffc02038d8:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc02038da:	03067d63          	bgeu	a2,a6,ffffffffc0203914 <printnum+0x5a>
ffffffffc02038de:	e44e                	sd	s3,8(sp)
ffffffffc02038e0:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02038e2:	4785                	li	a5,1
ffffffffc02038e4:	00e7d763          	bge	a5,a4,ffffffffc02038f2 <printnum+0x38>
            putch(padc, putdat);
ffffffffc02038e8:	85ca                	mv	a1,s2
ffffffffc02038ea:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc02038ec:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02038ee:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02038f0:	fc65                	bnez	s0,ffffffffc02038e8 <printnum+0x2e>
ffffffffc02038f2:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02038f4:	00002797          	auipc	a5,0x2
ffffffffc02038f8:	c3c78793          	addi	a5,a5,-964 # ffffffffc0205530 <etext+0x17a8>
ffffffffc02038fc:	97d2                	add	a5,a5,s4
}
ffffffffc02038fe:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203900:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0203904:	70a2                	ld	ra,40(sp)
ffffffffc0203906:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203908:	85ca                	mv	a1,s2
ffffffffc020390a:	87a6                	mv	a5,s1
}
ffffffffc020390c:	6942                	ld	s2,16(sp)
ffffffffc020390e:	64e2                	ld	s1,24(sp)
ffffffffc0203910:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203912:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203914:	03065633          	divu	a2,a2,a6
ffffffffc0203918:	8722                	mv	a4,s0
ffffffffc020391a:	fa1ff0ef          	jal	ffffffffc02038ba <printnum>
ffffffffc020391e:	bfd9                	j	ffffffffc02038f4 <printnum+0x3a>

ffffffffc0203920 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203920:	7119                	addi	sp,sp,-128
ffffffffc0203922:	f4a6                	sd	s1,104(sp)
ffffffffc0203924:	f0ca                	sd	s2,96(sp)
ffffffffc0203926:	ecce                	sd	s3,88(sp)
ffffffffc0203928:	e8d2                	sd	s4,80(sp)
ffffffffc020392a:	e4d6                	sd	s5,72(sp)
ffffffffc020392c:	e0da                	sd	s6,64(sp)
ffffffffc020392e:	f862                	sd	s8,48(sp)
ffffffffc0203930:	fc86                	sd	ra,120(sp)
ffffffffc0203932:	f8a2                	sd	s0,112(sp)
ffffffffc0203934:	fc5e                	sd	s7,56(sp)
ffffffffc0203936:	f466                	sd	s9,40(sp)
ffffffffc0203938:	f06a                	sd	s10,32(sp)
ffffffffc020393a:	ec6e                	sd	s11,24(sp)
ffffffffc020393c:	84aa                	mv	s1,a0
ffffffffc020393e:	8c32                	mv	s8,a2
ffffffffc0203940:	8a36                	mv	s4,a3
ffffffffc0203942:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203944:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203948:	05500b13          	li	s6,85
ffffffffc020394c:	00002a97          	auipc	s5,0x2
ffffffffc0203950:	d84a8a93          	addi	s5,s5,-636 # ffffffffc02056d0 <best_fit_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203954:	000c4503          	lbu	a0,0(s8)
ffffffffc0203958:	001c0413          	addi	s0,s8,1
ffffffffc020395c:	01350a63          	beq	a0,s3,ffffffffc0203970 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0203960:	cd0d                	beqz	a0,ffffffffc020399a <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0203962:	85ca                	mv	a1,s2
ffffffffc0203964:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203966:	00044503          	lbu	a0,0(s0)
ffffffffc020396a:	0405                	addi	s0,s0,1
ffffffffc020396c:	ff351ae3          	bne	a0,s3,ffffffffc0203960 <vprintfmt+0x40>
        width = precision = -1;
ffffffffc0203970:	5cfd                	li	s9,-1
ffffffffc0203972:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc0203974:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0203978:	4b81                	li	s7,0
ffffffffc020397a:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020397c:	00044683          	lbu	a3,0(s0)
ffffffffc0203980:	00140c13          	addi	s8,s0,1
ffffffffc0203984:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0203988:	0ff5f593          	zext.b	a1,a1
ffffffffc020398c:	02bb6663          	bltu	s6,a1,ffffffffc02039b8 <vprintfmt+0x98>
ffffffffc0203990:	058a                	slli	a1,a1,0x2
ffffffffc0203992:	95d6                	add	a1,a1,s5
ffffffffc0203994:	4198                	lw	a4,0(a1)
ffffffffc0203996:	9756                	add	a4,a4,s5
ffffffffc0203998:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc020399a:	70e6                	ld	ra,120(sp)
ffffffffc020399c:	7446                	ld	s0,112(sp)
ffffffffc020399e:	74a6                	ld	s1,104(sp)
ffffffffc02039a0:	7906                	ld	s2,96(sp)
ffffffffc02039a2:	69e6                	ld	s3,88(sp)
ffffffffc02039a4:	6a46                	ld	s4,80(sp)
ffffffffc02039a6:	6aa6                	ld	s5,72(sp)
ffffffffc02039a8:	6b06                	ld	s6,64(sp)
ffffffffc02039aa:	7be2                	ld	s7,56(sp)
ffffffffc02039ac:	7c42                	ld	s8,48(sp)
ffffffffc02039ae:	7ca2                	ld	s9,40(sp)
ffffffffc02039b0:	7d02                	ld	s10,32(sp)
ffffffffc02039b2:	6de2                	ld	s11,24(sp)
ffffffffc02039b4:	6109                	addi	sp,sp,128
ffffffffc02039b6:	8082                	ret
            putch('%', putdat);
ffffffffc02039b8:	85ca                	mv	a1,s2
ffffffffc02039ba:	02500513          	li	a0,37
ffffffffc02039be:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02039c0:	fff44783          	lbu	a5,-1(s0)
ffffffffc02039c4:	02500713          	li	a4,37
ffffffffc02039c8:	8c22                	mv	s8,s0
ffffffffc02039ca:	f8e785e3          	beq	a5,a4,ffffffffc0203954 <vprintfmt+0x34>
ffffffffc02039ce:	ffec4783          	lbu	a5,-2(s8)
ffffffffc02039d2:	1c7d                	addi	s8,s8,-1
ffffffffc02039d4:	fee79de3          	bne	a5,a4,ffffffffc02039ce <vprintfmt+0xae>
ffffffffc02039d8:	bfb5                	j	ffffffffc0203954 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc02039da:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc02039de:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc02039e0:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02039e4:	fd06071b          	addiw	a4,a2,-48
ffffffffc02039e8:	24e56a63          	bltu	a0,a4,ffffffffc0203c3c <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc02039ec:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02039ee:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc02039f0:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc02039f4:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02039f8:	0197073b          	addw	a4,a4,s9
ffffffffc02039fc:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203a00:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203a02:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0203a06:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203a08:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0203a0c:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc0203a10:	feb570e3          	bgeu	a0,a1,ffffffffc02039f0 <vprintfmt+0xd0>
            if (width < 0)
ffffffffc0203a14:	f60d54e3          	bgez	s10,ffffffffc020397c <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0203a18:	8d66                	mv	s10,s9
ffffffffc0203a1a:	5cfd                	li	s9,-1
ffffffffc0203a1c:	b785                	j	ffffffffc020397c <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203a1e:	8db6                	mv	s11,a3
ffffffffc0203a20:	8462                	mv	s0,s8
ffffffffc0203a22:	bfa9                	j	ffffffffc020397c <vprintfmt+0x5c>
ffffffffc0203a24:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0203a26:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0203a28:	bf91                	j	ffffffffc020397c <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0203a2a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203a2c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203a30:	00f74463          	blt	a4,a5,ffffffffc0203a38 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0203a34:	1a078763          	beqz	a5,ffffffffc0203be2 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0203a38:	000a3603          	ld	a2,0(s4)
ffffffffc0203a3c:	46c1                	li	a3,16
ffffffffc0203a3e:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203a40:	000d879b          	sext.w	a5,s11
ffffffffc0203a44:	876a                	mv	a4,s10
ffffffffc0203a46:	85ca                	mv	a1,s2
ffffffffc0203a48:	8526                	mv	a0,s1
ffffffffc0203a4a:	e71ff0ef          	jal	ffffffffc02038ba <printnum>
            break;
ffffffffc0203a4e:	b719                	j	ffffffffc0203954 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc0203a50:	000a2503          	lw	a0,0(s4)
ffffffffc0203a54:	85ca                	mv	a1,s2
ffffffffc0203a56:	0a21                	addi	s4,s4,8
ffffffffc0203a58:	9482                	jalr	s1
            break;
ffffffffc0203a5a:	bded                	j	ffffffffc0203954 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0203a5c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203a5e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203a62:	00f74463          	blt	a4,a5,ffffffffc0203a6a <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203a66:	16078963          	beqz	a5,ffffffffc0203bd8 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0203a6a:	000a3603          	ld	a2,0(s4)
ffffffffc0203a6e:	46a9                	li	a3,10
ffffffffc0203a70:	8a2e                	mv	s4,a1
ffffffffc0203a72:	b7f9                	j	ffffffffc0203a40 <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc0203a74:	85ca                	mv	a1,s2
ffffffffc0203a76:	03000513          	li	a0,48
ffffffffc0203a7a:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc0203a7c:	85ca                	mv	a1,s2
ffffffffc0203a7e:	07800513          	li	a0,120
ffffffffc0203a82:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203a84:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0203a88:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203a8a:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0203a8c:	bf55                	j	ffffffffc0203a40 <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc0203a8e:	85ca                	mv	a1,s2
ffffffffc0203a90:	02500513          	li	a0,37
ffffffffc0203a94:	9482                	jalr	s1
            break;
ffffffffc0203a96:	bd7d                	j	ffffffffc0203954 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0203a98:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203a9c:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0203a9e:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc0203aa0:	bf95                	j	ffffffffc0203a14 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc0203aa2:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203aa4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0203aa8:	00f74463          	blt	a4,a5,ffffffffc0203ab0 <vprintfmt+0x190>
    else if (lflag) {
ffffffffc0203aac:	12078163          	beqz	a5,ffffffffc0203bce <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc0203ab0:	000a3603          	ld	a2,0(s4)
ffffffffc0203ab4:	46a1                	li	a3,8
ffffffffc0203ab6:	8a2e                	mv	s4,a1
ffffffffc0203ab8:	b761                	j	ffffffffc0203a40 <vprintfmt+0x120>
            if (width < 0)
ffffffffc0203aba:	876a                	mv	a4,s10
ffffffffc0203abc:	000d5363          	bgez	s10,ffffffffc0203ac2 <vprintfmt+0x1a2>
ffffffffc0203ac0:	4701                	li	a4,0
ffffffffc0203ac2:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ac6:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0203ac8:	bd55                	j	ffffffffc020397c <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc0203aca:	000d841b          	sext.w	s0,s11
ffffffffc0203ace:	fd340793          	addi	a5,s0,-45
ffffffffc0203ad2:	00f037b3          	snez	a5,a5
ffffffffc0203ad6:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203ada:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc0203ade:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203ae0:	008a0793          	addi	a5,s4,8
ffffffffc0203ae4:	e43e                	sd	a5,8(sp)
ffffffffc0203ae6:	100d8c63          	beqz	s11,ffffffffc0203bfe <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0203aea:	12071363          	bnez	a4,ffffffffc0203c10 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203aee:	000dc783          	lbu	a5,0(s11)
ffffffffc0203af2:	0007851b          	sext.w	a0,a5
ffffffffc0203af6:	c78d                	beqz	a5,ffffffffc0203b20 <vprintfmt+0x200>
ffffffffc0203af8:	0d85                	addi	s11,s11,1
ffffffffc0203afa:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203afc:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203b00:	000cc563          	bltz	s9,ffffffffc0203b0a <vprintfmt+0x1ea>
ffffffffc0203b04:	3cfd                	addiw	s9,s9,-1
ffffffffc0203b06:	008c8d63          	beq	s9,s0,ffffffffc0203b20 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203b0a:	020b9663          	bnez	s7,ffffffffc0203b36 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc0203b0e:	85ca                	mv	a1,s2
ffffffffc0203b10:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203b12:	000dc783          	lbu	a5,0(s11)
ffffffffc0203b16:	0d85                	addi	s11,s11,1
ffffffffc0203b18:	3d7d                	addiw	s10,s10,-1
ffffffffc0203b1a:	0007851b          	sext.w	a0,a5
ffffffffc0203b1e:	f3ed                	bnez	a5,ffffffffc0203b00 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc0203b20:	01a05963          	blez	s10,ffffffffc0203b32 <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc0203b24:	85ca                	mv	a1,s2
ffffffffc0203b26:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0203b2a:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0203b2c:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc0203b2e:	fe0d1be3          	bnez	s10,ffffffffc0203b24 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203b32:	6a22                	ld	s4,8(sp)
ffffffffc0203b34:	b505                	j	ffffffffc0203954 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203b36:	3781                	addiw	a5,a5,-32
ffffffffc0203b38:	fcfa7be3          	bgeu	s4,a5,ffffffffc0203b0e <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc0203b3c:	03f00513          	li	a0,63
ffffffffc0203b40:	85ca                	mv	a1,s2
ffffffffc0203b42:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203b44:	000dc783          	lbu	a5,0(s11)
ffffffffc0203b48:	0d85                	addi	s11,s11,1
ffffffffc0203b4a:	3d7d                	addiw	s10,s10,-1
ffffffffc0203b4c:	0007851b          	sext.w	a0,a5
ffffffffc0203b50:	dbe1                	beqz	a5,ffffffffc0203b20 <vprintfmt+0x200>
ffffffffc0203b52:	fa0cd9e3          	bgez	s9,ffffffffc0203b04 <vprintfmt+0x1e4>
ffffffffc0203b56:	b7c5                	j	ffffffffc0203b36 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0203b58:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203b5c:	4619                	li	a2,6
            err = va_arg(ap, int);
ffffffffc0203b5e:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0203b60:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0203b64:	8fb9                	xor	a5,a5,a4
ffffffffc0203b66:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203b6a:	02d64563          	blt	a2,a3,ffffffffc0203b94 <vprintfmt+0x274>
ffffffffc0203b6e:	00002797          	auipc	a5,0x2
ffffffffc0203b72:	cba78793          	addi	a5,a5,-838 # ffffffffc0205828 <error_string>
ffffffffc0203b76:	00369713          	slli	a4,a3,0x3
ffffffffc0203b7a:	97ba                	add	a5,a5,a4
ffffffffc0203b7c:	639c                	ld	a5,0(a5)
ffffffffc0203b7e:	cb99                	beqz	a5,ffffffffc0203b94 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203b80:	86be                	mv	a3,a5
ffffffffc0203b82:	00000617          	auipc	a2,0x0
ffffffffc0203b86:	22e60613          	addi	a2,a2,558 # ffffffffc0203db0 <etext+0x28>
ffffffffc0203b8a:	85ca                	mv	a1,s2
ffffffffc0203b8c:	8526                	mv	a0,s1
ffffffffc0203b8e:	0d8000ef          	jal	ffffffffc0203c66 <printfmt>
ffffffffc0203b92:	b3c9                	j	ffffffffc0203954 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0203b94:	00002617          	auipc	a2,0x2
ffffffffc0203b98:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0205550 <etext+0x17c8>
ffffffffc0203b9c:	85ca                	mv	a1,s2
ffffffffc0203b9e:	8526                	mv	a0,s1
ffffffffc0203ba0:	0c6000ef          	jal	ffffffffc0203c66 <printfmt>
ffffffffc0203ba4:	bb45                	j	ffffffffc0203954 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0203ba6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0203ba8:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0203bac:	00f74363          	blt	a4,a5,ffffffffc0203bb2 <vprintfmt+0x292>
    else if (lflag) {
ffffffffc0203bb0:	cf81                	beqz	a5,ffffffffc0203bc8 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc0203bb2:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0203bb6:	02044b63          	bltz	s0,ffffffffc0203bec <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc0203bba:	8622                	mv	a2,s0
ffffffffc0203bbc:	8a5e                	mv	s4,s7
ffffffffc0203bbe:	46a9                	li	a3,10
ffffffffc0203bc0:	b541                	j	ffffffffc0203a40 <vprintfmt+0x120>
            lflag ++;
ffffffffc0203bc2:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203bc4:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0203bc6:	bb5d                	j	ffffffffc020397c <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc0203bc8:	000a2403          	lw	s0,0(s4)
ffffffffc0203bcc:	b7ed                	j	ffffffffc0203bb6 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc0203bce:	000a6603          	lwu	a2,0(s4)
ffffffffc0203bd2:	46a1                	li	a3,8
ffffffffc0203bd4:	8a2e                	mv	s4,a1
ffffffffc0203bd6:	b5ad                	j	ffffffffc0203a40 <vprintfmt+0x120>
ffffffffc0203bd8:	000a6603          	lwu	a2,0(s4)
ffffffffc0203bdc:	46a9                	li	a3,10
ffffffffc0203bde:	8a2e                	mv	s4,a1
ffffffffc0203be0:	b585                	j	ffffffffc0203a40 <vprintfmt+0x120>
ffffffffc0203be2:	000a6603          	lwu	a2,0(s4)
ffffffffc0203be6:	46c1                	li	a3,16
ffffffffc0203be8:	8a2e                	mv	s4,a1
ffffffffc0203bea:	bd99                	j	ffffffffc0203a40 <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc0203bec:	85ca                	mv	a1,s2
ffffffffc0203bee:	02d00513          	li	a0,45
ffffffffc0203bf2:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc0203bf4:	40800633          	neg	a2,s0
ffffffffc0203bf8:	8a5e                	mv	s4,s7
ffffffffc0203bfa:	46a9                	li	a3,10
ffffffffc0203bfc:	b591                	j	ffffffffc0203a40 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc0203bfe:	e329                	bnez	a4,ffffffffc0203c40 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203c00:	02800793          	li	a5,40
ffffffffc0203c04:	853e                	mv	a0,a5
ffffffffc0203c06:	00002d97          	auipc	s11,0x2
ffffffffc0203c0a:	943d8d93          	addi	s11,s11,-1725 # ffffffffc0205549 <etext+0x17c1>
ffffffffc0203c0e:	b5f5                	j	ffffffffc0203afa <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203c10:	85e6                	mv	a1,s9
ffffffffc0203c12:	856e                	mv	a0,s11
ffffffffc0203c14:	08a000ef          	jal	ffffffffc0203c9e <strnlen>
ffffffffc0203c18:	40ad0d3b          	subw	s10,s10,a0
ffffffffc0203c1c:	01a05863          	blez	s10,ffffffffc0203c2c <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc0203c20:	85ca                	mv	a1,s2
ffffffffc0203c22:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203c24:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc0203c26:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203c28:	fe0d1ce3          	bnez	s10,ffffffffc0203c20 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203c2c:	000dc783          	lbu	a5,0(s11)
ffffffffc0203c30:	0007851b          	sext.w	a0,a5
ffffffffc0203c34:	ec0792e3          	bnez	a5,ffffffffc0203af8 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203c38:	6a22                	ld	s4,8(sp)
ffffffffc0203c3a:	bb29                	j	ffffffffc0203954 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203c3c:	8462                	mv	s0,s8
ffffffffc0203c3e:	bbd9                	j	ffffffffc0203a14 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203c40:	85e6                	mv	a1,s9
ffffffffc0203c42:	00002517          	auipc	a0,0x2
ffffffffc0203c46:	90650513          	addi	a0,a0,-1786 # ffffffffc0205548 <etext+0x17c0>
ffffffffc0203c4a:	054000ef          	jal	ffffffffc0203c9e <strnlen>
ffffffffc0203c4e:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203c52:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0203c56:	00002d97          	auipc	s11,0x2
ffffffffc0203c5a:	8f2d8d93          	addi	s11,s11,-1806 # ffffffffc0205548 <etext+0x17c0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203c5e:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0203c60:	fda040e3          	bgtz	s10,ffffffffc0203c20 <vprintfmt+0x300>
ffffffffc0203c64:	bd51                	j	ffffffffc0203af8 <vprintfmt+0x1d8>

ffffffffc0203c66 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203c66:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0203c68:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203c6c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203c6e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0203c70:	ec06                	sd	ra,24(sp)
ffffffffc0203c72:	f83a                	sd	a4,48(sp)
ffffffffc0203c74:	fc3e                	sd	a5,56(sp)
ffffffffc0203c76:	e0c2                	sd	a6,64(sp)
ffffffffc0203c78:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0203c7a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0203c7c:	ca5ff0ef          	jal	ffffffffc0203920 <vprintfmt>
}
ffffffffc0203c80:	60e2                	ld	ra,24(sp)
ffffffffc0203c82:	6161                	addi	sp,sp,80
ffffffffc0203c84:	8082                	ret

ffffffffc0203c86 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0203c86:	00054783          	lbu	a5,0(a0)
ffffffffc0203c8a:	cb81                	beqz	a5,ffffffffc0203c9a <strlen+0x14>
    size_t cnt = 0;
ffffffffc0203c8c:	4781                	li	a5,0
        cnt ++;
ffffffffc0203c8e:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0203c90:	00f50733          	add	a4,a0,a5
ffffffffc0203c94:	00074703          	lbu	a4,0(a4)
ffffffffc0203c98:	fb7d                	bnez	a4,ffffffffc0203c8e <strlen+0x8>
    }
    return cnt;
}
ffffffffc0203c9a:	853e                	mv	a0,a5
ffffffffc0203c9c:	8082                	ret

ffffffffc0203c9e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0203c9e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203ca0:	e589                	bnez	a1,ffffffffc0203caa <strnlen+0xc>
ffffffffc0203ca2:	a811                	j	ffffffffc0203cb6 <strnlen+0x18>
        cnt ++;
ffffffffc0203ca4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0203ca6:	00f58863          	beq	a1,a5,ffffffffc0203cb6 <strnlen+0x18>
ffffffffc0203caa:	00f50733          	add	a4,a0,a5
ffffffffc0203cae:	00074703          	lbu	a4,0(a4)
ffffffffc0203cb2:	fb6d                	bnez	a4,ffffffffc0203ca4 <strnlen+0x6>
ffffffffc0203cb4:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0203cb6:	852e                	mv	a0,a1
ffffffffc0203cb8:	8082                	ret

ffffffffc0203cba <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0203cba:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0203cbc:	0005c703          	lbu	a4,0(a1)
ffffffffc0203cc0:	0585                	addi	a1,a1,1
ffffffffc0203cc2:	0785                	addi	a5,a5,1
ffffffffc0203cc4:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0203cc8:	fb75                	bnez	a4,ffffffffc0203cbc <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0203cca:	8082                	ret

ffffffffc0203ccc <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203ccc:	00054783          	lbu	a5,0(a0)
ffffffffc0203cd0:	e791                	bnez	a5,ffffffffc0203cdc <strcmp+0x10>
ffffffffc0203cd2:	a01d                	j	ffffffffc0203cf8 <strcmp+0x2c>
ffffffffc0203cd4:	00054783          	lbu	a5,0(a0)
ffffffffc0203cd8:	cb99                	beqz	a5,ffffffffc0203cee <strcmp+0x22>
ffffffffc0203cda:	0585                	addi	a1,a1,1
ffffffffc0203cdc:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc0203ce0:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0203ce2:	fef709e3          	beq	a4,a5,ffffffffc0203cd4 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203ce6:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0203cea:	9d19                	subw	a0,a0,a4
ffffffffc0203cec:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203cee:	0015c703          	lbu	a4,1(a1)
ffffffffc0203cf2:	4501                	li	a0,0
}
ffffffffc0203cf4:	9d19                	subw	a0,a0,a4
ffffffffc0203cf6:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203cf8:	0005c703          	lbu	a4,0(a1)
ffffffffc0203cfc:	4501                	li	a0,0
ffffffffc0203cfe:	b7f5                	j	ffffffffc0203cea <strcmp+0x1e>

ffffffffc0203d00 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203d00:	ce01                	beqz	a2,ffffffffc0203d18 <strncmp+0x18>
ffffffffc0203d02:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0203d06:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203d08:	cb91                	beqz	a5,ffffffffc0203d1c <strncmp+0x1c>
ffffffffc0203d0a:	0005c703          	lbu	a4,0(a1)
ffffffffc0203d0e:	00f71763          	bne	a4,a5,ffffffffc0203d1c <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc0203d12:	0505                	addi	a0,a0,1
ffffffffc0203d14:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0203d16:	f675                	bnez	a2,ffffffffc0203d02 <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203d18:	4501                	li	a0,0
ffffffffc0203d1a:	8082                	ret
ffffffffc0203d1c:	00054503          	lbu	a0,0(a0)
ffffffffc0203d20:	0005c783          	lbu	a5,0(a1)
ffffffffc0203d24:	9d1d                	subw	a0,a0,a5
}
ffffffffc0203d26:	8082                	ret

ffffffffc0203d28 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0203d28:	a021                	j	ffffffffc0203d30 <strchr+0x8>
        if (*s == c) {
ffffffffc0203d2a:	00f58763          	beq	a1,a5,ffffffffc0203d38 <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc0203d2e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0203d30:	00054783          	lbu	a5,0(a0)
ffffffffc0203d34:	fbfd                	bnez	a5,ffffffffc0203d2a <strchr+0x2>
    }
    return NULL;
ffffffffc0203d36:	4501                	li	a0,0
}
ffffffffc0203d38:	8082                	ret

ffffffffc0203d3a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0203d3a:	ca01                	beqz	a2,ffffffffc0203d4a <memset+0x10>
ffffffffc0203d3c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0203d3e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0203d40:	0785                	addi	a5,a5,1
ffffffffc0203d42:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0203d46:	fef61de3          	bne	a2,a5,ffffffffc0203d40 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0203d4a:	8082                	ret

ffffffffc0203d4c <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0203d4c:	ca19                	beqz	a2,ffffffffc0203d62 <memcpy+0x16>
ffffffffc0203d4e:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0203d50:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0203d52:	0005c703          	lbu	a4,0(a1)
ffffffffc0203d56:	0585                	addi	a1,a1,1
ffffffffc0203d58:	0785                	addi	a5,a5,1
ffffffffc0203d5a:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0203d5e:	feb61ae3          	bne	a2,a1,ffffffffc0203d52 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0203d62:	8082                	ret

ffffffffc0203d64 <memcmp>:
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
ffffffffc0203d64:	c205                	beqz	a2,ffffffffc0203d84 <memcmp+0x20>
ffffffffc0203d66:	962a                	add	a2,a2,a0
ffffffffc0203d68:	a019                	j	ffffffffc0203d6e <memcmp+0xa>
ffffffffc0203d6a:	00c50d63          	beq	a0,a2,ffffffffc0203d84 <memcmp+0x20>
        if (*s1 != *s2) {
ffffffffc0203d6e:	00054783          	lbu	a5,0(a0)
ffffffffc0203d72:	0005c703          	lbu	a4,0(a1)
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
ffffffffc0203d76:	0505                	addi	a0,a0,1
ffffffffc0203d78:	0585                	addi	a1,a1,1
        if (*s1 != *s2) {
ffffffffc0203d7a:	fee788e3          	beq	a5,a4,ffffffffc0203d6a <memcmp+0x6>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0203d7e:	40e7853b          	subw	a0,a5,a4
ffffffffc0203d82:	8082                	ret
    }
    return 0;
ffffffffc0203d84:	4501                	li	a0,0
}
ffffffffc0203d86:	8082                	ret
