
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00006297          	auipc	t0,0x6
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0206000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00006297          	auipc	t0,0x6
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0206008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02052b7          	lui	t0,0xc0205
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
ffffffffc020003c:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	0d628293          	addi	t0,t0,214 # ffffffffc02000d6 <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020004a:	1141                	addi	sp,sp,-16 # ffffffffc0204ff0 <bootstack+0x1ff0>
    extern char etext[], edata[], end[];
    cprintf("Special kernel symbols:\n");
ffffffffc020004c:	00001517          	auipc	a0,0x1
ffffffffc0200050:	68c50513          	addi	a0,a0,1676 # ffffffffc02016d8 <etext+0x6>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f2000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07c58593          	addi	a1,a1,124 # ffffffffc02000d6 <kern_init>
ffffffffc0200062:	00001517          	auipc	a0,0x1
ffffffffc0200066:	69650513          	addi	a0,a0,1686 # ffffffffc02016f8 <etext+0x26>
ffffffffc020006a:	0de000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00001597          	auipc	a1,0x1
ffffffffc0200072:	66458593          	addi	a1,a1,1636 # ffffffffc02016d2 <etext>
ffffffffc0200076:	00001517          	auipc	a0,0x1
ffffffffc020007a:	6a250513          	addi	a0,a0,1698 # ffffffffc0201718 <etext+0x46>
ffffffffc020007e:	0ca000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <cache_storage.0>
ffffffffc020008a:	00001517          	auipc	a0,0x1
ffffffffc020008e:	6ae50513          	addi	a0,a0,1710 # ffffffffc0201738 <etext+0x66>
ffffffffc0200092:	0b6000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00006597          	auipc	a1,0x6
ffffffffc020009a:	09258593          	addi	a1,a1,146 # ffffffffc0206128 <end>
ffffffffc020009e:	00001517          	auipc	a0,0x1
ffffffffc02000a2:	6ba50513          	addi	a0,a0,1722 # ffffffffc0201758 <etext+0x86>
ffffffffc02000a6:	0a2000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00000717          	auipc	a4,0x0
ffffffffc02000ae:	02c70713          	addi	a4,a4,44 # ffffffffc02000d6 <kern_init>
ffffffffc02000b2:	00006797          	auipc	a5,0x6
ffffffffc02000b6:	47578793          	addi	a5,a5,1141 # ffffffffc0206527 <end+0x3ff>
ffffffffc02000ba:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000bc:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000c0:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000c2:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c6:	95be                	add	a1,a1,a5
ffffffffc02000c8:	85a9                	srai	a1,a1,0xa
ffffffffc02000ca:	00001517          	auipc	a0,0x1
ffffffffc02000ce:	6ae50513          	addi	a0,a0,1710 # ffffffffc0201778 <etext+0xa6>
}
ffffffffc02000d2:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d4:	a895                	j	ffffffffc0200148 <cprintf>

ffffffffc02000d6 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d6:	00006517          	auipc	a0,0x6
ffffffffc02000da:	f4250513          	addi	a0,a0,-190 # ffffffffc0206018 <cache_storage.0>
ffffffffc02000de:	00006617          	auipc	a2,0x6
ffffffffc02000e2:	04a60613          	addi	a2,a2,74 # ffffffffc0206128 <end>
int kern_init(void) {
ffffffffc02000e6:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000e8:	8e09                	sub	a2,a2,a0
ffffffffc02000ea:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ec:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000ee:	5d2010ef          	jal	ffffffffc02016c0 <memset>
    dtb_init();
ffffffffc02000f2:	136000ef          	jal	ffffffffc0200228 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f6:	128000ef          	jal	ffffffffc020021e <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fa:	00002517          	auipc	a0,0x2
ffffffffc02000fe:	36e50513          	addi	a0,a0,878 # ffffffffc0202468 <etext+0xd96>
ffffffffc0200102:	07a000ef          	jal	ffffffffc020017c <cputs>

    print_kerninfo();
ffffffffc0200106:	f45ff0ef          	jal	ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010a:	47c000ef          	jal	ffffffffc0200586 <pmm_init>

    /* do nothing */
    while (1)
ffffffffc020010e:	a001                	j	ffffffffc020010e <kern_init+0x38>

ffffffffc0200110 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200110:	1101                	addi	sp,sp,-32
ffffffffc0200112:	ec06                	sd	ra,24(sp)
ffffffffc0200114:	e42e                	sd	a1,8(sp)
    cons_putc(c);
ffffffffc0200116:	10a000ef          	jal	ffffffffc0200220 <cons_putc>
    (*cnt) ++;
ffffffffc020011a:	65a2                	ld	a1,8(sp)
}
ffffffffc020011c:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
ffffffffc020011e:	419c                	lw	a5,0(a1)
ffffffffc0200120:	2785                	addiw	a5,a5,1
ffffffffc0200122:	c19c                	sw	a5,0(a1)
}
ffffffffc0200124:	6105                	addi	sp,sp,32
ffffffffc0200126:	8082                	ret

ffffffffc0200128 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200128:	1101                	addi	sp,sp,-32
ffffffffc020012a:	862a                	mv	a2,a0
ffffffffc020012c:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020012e:	00000517          	auipc	a0,0x0
ffffffffc0200132:	fe250513          	addi	a0,a0,-30 # ffffffffc0200110 <cputch>
ffffffffc0200136:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200138:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020013a:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020013c:	112010ef          	jal	ffffffffc020124e <vprintfmt>
    return cnt;
}
ffffffffc0200140:	60e2                	ld	ra,24(sp)
ffffffffc0200142:	4532                	lw	a0,12(sp)
ffffffffc0200144:	6105                	addi	sp,sp,32
ffffffffc0200146:	8082                	ret

ffffffffc0200148 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200148:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020014a:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc020014e:	f42e                	sd	a1,40(sp)
ffffffffc0200150:	f832                	sd	a2,48(sp)
ffffffffc0200152:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200154:	862a                	mv	a2,a0
ffffffffc0200156:	004c                	addi	a1,sp,4
ffffffffc0200158:	00000517          	auipc	a0,0x0
ffffffffc020015c:	fb850513          	addi	a0,a0,-72 # ffffffffc0200110 <cputch>
ffffffffc0200160:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc0200162:	ec06                	sd	ra,24(sp)
ffffffffc0200164:	e0ba                	sd	a4,64(sp)
ffffffffc0200166:	e4be                	sd	a5,72(sp)
ffffffffc0200168:	e8c2                	sd	a6,80(sp)
ffffffffc020016a:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc020016c:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc020016e:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	0de010ef          	jal	ffffffffc020124e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200174:	60e2                	ld	ra,24(sp)
ffffffffc0200176:	4512                	lw	a0,4(sp)
ffffffffc0200178:	6125                	addi	sp,sp,96
ffffffffc020017a:	8082                	ret

ffffffffc020017c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc020017c:	1101                	addi	sp,sp,-32
ffffffffc020017e:	e822                	sd	s0,16(sp)
ffffffffc0200180:	ec06                	sd	ra,24(sp)
ffffffffc0200182:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200184:	00054503          	lbu	a0,0(a0)
ffffffffc0200188:	c51d                	beqz	a0,ffffffffc02001b6 <cputs+0x3a>
ffffffffc020018a:	e426                	sd	s1,8(sp)
ffffffffc020018c:	0405                	addi	s0,s0,1
    int cnt = 0;
ffffffffc020018e:	4481                	li	s1,0
    cons_putc(c);
ffffffffc0200190:	090000ef          	jal	ffffffffc0200220 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200194:	00044503          	lbu	a0,0(s0)
ffffffffc0200198:	0405                	addi	s0,s0,1
ffffffffc020019a:	87a6                	mv	a5,s1
    (*cnt) ++;
ffffffffc020019c:	2485                	addiw	s1,s1,1
    while ((c = *str ++) != '\0') {
ffffffffc020019e:	f96d                	bnez	a0,ffffffffc0200190 <cputs+0x14>
    cons_putc(c);
ffffffffc02001a0:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc02001a2:	0027841b          	addiw	s0,a5,2
ffffffffc02001a6:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc02001a8:	078000ef          	jal	ffffffffc0200220 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001ac:	60e2                	ld	ra,24(sp)
ffffffffc02001ae:	8522                	mv	a0,s0
ffffffffc02001b0:	6442                	ld	s0,16(sp)
ffffffffc02001b2:	6105                	addi	sp,sp,32
ffffffffc02001b4:	8082                	ret
    cons_putc(c);
ffffffffc02001b6:	4529                	li	a0,10
ffffffffc02001b8:	068000ef          	jal	ffffffffc0200220 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001bc:	4405                	li	s0,1
}
ffffffffc02001be:	60e2                	ld	ra,24(sp)
ffffffffc02001c0:	8522                	mv	a0,s0
ffffffffc02001c2:	6442                	ld	s0,16(sp)
ffffffffc02001c4:	6105                	addi	sp,sp,32
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c8:	00006317          	auipc	t1,0x6
ffffffffc02001cc:	f1832303          	lw	t1,-232(t1) # ffffffffc02060e0 <is_panic>
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001d0:	715d                	addi	sp,sp,-80
ffffffffc02001d2:	ec06                	sd	ra,24(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001de:	00030363          	beqz	t1,ffffffffc02001e4 <__panic+0x1c>
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    while (1) {
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x1a>
    is_panic = 1;
ffffffffc02001e4:	4705                	li	a4,1
    va_start(ap, fmt);
ffffffffc02001e6:	103c                	addi	a5,sp,40
ffffffffc02001e8:	e822                	sd	s0,16(sp)
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	862e                	mv	a2,a1
ffffffffc02001ee:	85aa                	mv	a1,a0
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001f0:	00001517          	auipc	a0,0x1
ffffffffc02001f4:	5b850513          	addi	a0,a0,1464 # ffffffffc02017a8 <etext+0xd6>
    is_panic = 1;
ffffffffc02001f8:	00006697          	auipc	a3,0x6
ffffffffc02001fc:	eee6a423          	sw	a4,-280(a3) # ffffffffc02060e0 <is_panic>
    va_start(ap, fmt);
ffffffffc0200200:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200202:	f47ff0ef          	jal	ffffffffc0200148 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200206:	65a2                	ld	a1,8(sp)
ffffffffc0200208:	8522                	mv	a0,s0
ffffffffc020020a:	f1fff0ef          	jal	ffffffffc0200128 <vcprintf>
    cprintf("\n");
ffffffffc020020e:	00001517          	auipc	a0,0x1
ffffffffc0200212:	5ba50513          	addi	a0,a0,1466 # ffffffffc02017c8 <etext+0xf6>
ffffffffc0200216:	f33ff0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc020021a:	6442                	ld	s0,16(sp)
ffffffffc020021c:	b7d9                	j	ffffffffc02001e2 <__panic+0x1a>

ffffffffc020021e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020021e:	8082                	ret

ffffffffc0200220 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200220:	0ff57513          	zext.b	a0,a0
ffffffffc0200224:	3d60106f          	j	ffffffffc02015fa <sbi_console_putchar>

ffffffffc0200228 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200228:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc020022a:	00001517          	auipc	a0,0x1
ffffffffc020022e:	5a650513          	addi	a0,a0,1446 # ffffffffc02017d0 <etext+0xfe>
void dtb_init(void) {
ffffffffc0200232:	f406                	sd	ra,40(sp)
ffffffffc0200234:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc0200236:	f13ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc020023a:	00006597          	auipc	a1,0x6
ffffffffc020023e:	dc65b583          	ld	a1,-570(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200242:	00001517          	auipc	a0,0x1
ffffffffc0200246:	59e50513          	addi	a0,a0,1438 # ffffffffc02017e0 <etext+0x10e>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020024a:	00006417          	auipc	s0,0x6
ffffffffc020024e:	dbe40413          	addi	s0,s0,-578 # ffffffffc0206008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200252:	ef7ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200256:	600c                	ld	a1,0(s0)
ffffffffc0200258:	00001517          	auipc	a0,0x1
ffffffffc020025c:	59850513          	addi	a0,a0,1432 # ffffffffc02017f0 <etext+0x11e>
ffffffffc0200260:	ee9ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200264:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200266:	00001517          	auipc	a0,0x1
ffffffffc020026a:	5a250513          	addi	a0,a0,1442 # ffffffffc0201808 <etext+0x136>
    if (boot_dtb == 0) {
ffffffffc020026e:	10070163          	beqz	a4,ffffffffc0200370 <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200272:	57f5                	li	a5,-3
ffffffffc0200274:	07fa                	slli	a5,a5,0x1e
ffffffffc0200276:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200278:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc020027a:	d00e06b7          	lui	a3,0xd00e0
ffffffffc020027e:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfed9dc5>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200282:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200286:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020028a:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020028e:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200292:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200296:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200298:	8e49                	or	a2,a2,a0
ffffffffc020029a:	0ff7f793          	zext.b	a5,a5
ffffffffc020029e:	8dd1                	or	a1,a1,a2
ffffffffc02002a0:	07a2                	slli	a5,a5,0x8
ffffffffc02002a2:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002a4:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc02002a8:	0cd59863          	bne	a1,a3,ffffffffc0200378 <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02002ac:	4710                	lw	a2,8(a4)
ffffffffc02002ae:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02002b0:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002b2:	0086541b          	srliw	s0,a2,0x8
ffffffffc02002b6:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ba:	01865e1b          	srliw	t3,a2,0x18
ffffffffc02002be:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002c2:	0186151b          	slliw	a0,a2,0x18
ffffffffc02002c6:	0186959b          	slliw	a1,a3,0x18
ffffffffc02002ca:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ce:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002d2:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002d6:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02002da:	01c56533          	or	a0,a0,t3
ffffffffc02002de:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002e2:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e6:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002ea:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ee:	0ff6f693          	zext.b	a3,a3
ffffffffc02002f2:	8c49                	or	s0,s0,a0
ffffffffc02002f4:	0622                	slli	a2,a2,0x8
ffffffffc02002f6:	8fcd                	or	a5,a5,a1
ffffffffc02002f8:	06a2                	slli	a3,a3,0x8
ffffffffc02002fa:	8c51                	or	s0,s0,a2
ffffffffc02002fc:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02002fe:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200300:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200302:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200304:	9381                	srli	a5,a5,0x20
ffffffffc0200306:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc0200308:	4301                	li	t1,0
        switch (token) {
ffffffffc020030a:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020030c:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020030e:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc0200312:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200314:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200316:	0087579b          	srliw	a5,a4,0x8
ffffffffc020031a:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020031e:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200322:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200326:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020032a:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020032e:	8ed1                	or	a3,a3,a2
ffffffffc0200330:	0ff77713          	zext.b	a4,a4
ffffffffc0200334:	8fd5                	or	a5,a5,a3
ffffffffc0200336:	0722                	slli	a4,a4,0x8
ffffffffc0200338:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc020033a:	05178763          	beq	a5,a7,ffffffffc0200388 <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020033e:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc0200340:	00f8e963          	bltu	a7,a5,ffffffffc0200352 <dtb_init+0x12a>
ffffffffc0200344:	07c78d63          	beq	a5,t3,ffffffffc02003be <dtb_init+0x196>
ffffffffc0200348:	4709                	li	a4,2
ffffffffc020034a:	00e79763          	bne	a5,a4,ffffffffc0200358 <dtb_init+0x130>
ffffffffc020034e:	4301                	li	t1,0
ffffffffc0200350:	b7d1                	j	ffffffffc0200314 <dtb_init+0xec>
ffffffffc0200352:	4711                	li	a4,4
ffffffffc0200354:	fce780e3          	beq	a5,a4,ffffffffc0200314 <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200358:	00001517          	auipc	a0,0x1
ffffffffc020035c:	57850513          	addi	a0,a0,1400 # ffffffffc02018d0 <etext+0x1fe>
ffffffffc0200360:	de9ff0ef          	jal	ffffffffc0200148 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200364:	64e2                	ld	s1,24(sp)
ffffffffc0200366:	6942                	ld	s2,16(sp)
ffffffffc0200368:	00001517          	auipc	a0,0x1
ffffffffc020036c:	5a050513          	addi	a0,a0,1440 # ffffffffc0201908 <etext+0x236>
}
ffffffffc0200370:	7402                	ld	s0,32(sp)
ffffffffc0200372:	70a2                	ld	ra,40(sp)
ffffffffc0200374:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc0200376:	bbc9                	j	ffffffffc0200148 <cprintf>
}
ffffffffc0200378:	7402                	ld	s0,32(sp)
ffffffffc020037a:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020037c:	00001517          	auipc	a0,0x1
ffffffffc0200380:	4ac50513          	addi	a0,a0,1196 # ffffffffc0201828 <etext+0x156>
}
ffffffffc0200384:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200386:	b3c9                	j	ffffffffc0200148 <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200388:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020038a:	0087579b          	srliw	a5,a4,0x8
ffffffffc020038e:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200392:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200396:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020039a:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020039e:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02003a2:	8ed1                	or	a3,a3,a2
ffffffffc02003a4:	0ff77713          	zext.b	a4,a4
ffffffffc02003a8:	8fd5                	or	a5,a5,a3
ffffffffc02003aa:	0722                	slli	a4,a4,0x8
ffffffffc02003ac:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02003ae:	04031463          	bnez	t1,ffffffffc02003f6 <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02003b2:	1782                	slli	a5,a5,0x20
ffffffffc02003b4:	9381                	srli	a5,a5,0x20
ffffffffc02003b6:	043d                	addi	s0,s0,15
ffffffffc02003b8:	943e                	add	s0,s0,a5
ffffffffc02003ba:	9871                	andi	s0,s0,-4
                break;
ffffffffc02003bc:	bfa1                	j	ffffffffc0200314 <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc02003be:	8522                	mv	a0,s0
ffffffffc02003c0:	e01a                	sd	t1,0(sp)
ffffffffc02003c2:	252010ef          	jal	ffffffffc0201614 <strlen>
ffffffffc02003c6:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003c8:	4619                	li	a2,6
ffffffffc02003ca:	8522                	mv	a0,s0
ffffffffc02003cc:	00001597          	auipc	a1,0x1
ffffffffc02003d0:	48458593          	addi	a1,a1,1156 # ffffffffc0201850 <etext+0x17e>
ffffffffc02003d4:	2c4010ef          	jal	ffffffffc0201698 <strncmp>
ffffffffc02003d8:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003da:	0411                	addi	s0,s0,4
ffffffffc02003dc:	0004879b          	sext.w	a5,s1
ffffffffc02003e0:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e2:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003e6:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e8:	00a36333          	or	t1,t1,a0
                break;
ffffffffc02003ec:	00ff0837          	lui	a6,0xff0
ffffffffc02003f0:	488d                	li	a7,3
ffffffffc02003f2:	4e05                	li	t3,1
ffffffffc02003f4:	b705                	j	ffffffffc0200314 <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02003f6:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02003f8:	00001597          	auipc	a1,0x1
ffffffffc02003fc:	46058593          	addi	a1,a1,1120 # ffffffffc0201858 <etext+0x186>
ffffffffc0200400:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200402:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200406:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020040a:	0187169b          	slliw	a3,a4,0x18
ffffffffc020040e:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200412:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200416:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020041a:	8ed1                	or	a3,a3,a2
ffffffffc020041c:	0ff77713          	zext.b	a4,a4
ffffffffc0200420:	0722                	slli	a4,a4,0x8
ffffffffc0200422:	8d55                	or	a0,a0,a3
ffffffffc0200424:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200426:	1502                	slli	a0,a0,0x20
ffffffffc0200428:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020042a:	954a                	add	a0,a0,s2
ffffffffc020042c:	e01a                	sd	t1,0(sp)
ffffffffc020042e:	236010ef          	jal	ffffffffc0201664 <strcmp>
ffffffffc0200432:	67a2                	ld	a5,8(sp)
ffffffffc0200434:	473d                	li	a4,15
ffffffffc0200436:	6302                	ld	t1,0(sp)
ffffffffc0200438:	00ff0837          	lui	a6,0xff0
ffffffffc020043c:	488d                	li	a7,3
ffffffffc020043e:	4e05                	li	t3,1
ffffffffc0200440:	f6f779e3          	bgeu	a4,a5,ffffffffc02003b2 <dtb_init+0x18a>
ffffffffc0200444:	f53d                	bnez	a0,ffffffffc02003b2 <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200446:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020044a:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020044e:	00001517          	auipc	a0,0x1
ffffffffc0200452:	41250513          	addi	a0,a0,1042 # ffffffffc0201860 <etext+0x18e>
           fdt32_to_cpu(x >> 32);
ffffffffc0200456:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020045a:	0087d31b          	srliw	t1,a5,0x8
ffffffffc020045e:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200462:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200466:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020046a:	0187959b          	slliw	a1,a5,0x18
ffffffffc020046e:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200472:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200476:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020047a:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020047e:	01037333          	and	t1,t1,a6
ffffffffc0200482:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200486:	01e5e5b3          	or	a1,a1,t5
ffffffffc020048a:	0ff7f793          	zext.b	a5,a5
ffffffffc020048e:	01de6e33          	or	t3,t3,t4
ffffffffc0200492:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200496:	01067633          	and	a2,a2,a6
ffffffffc020049a:	0086d31b          	srliw	t1,a3,0x8
ffffffffc020049e:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004a2:	07a2                	slli	a5,a5,0x8
ffffffffc02004a4:	0108d89b          	srliw	a7,a7,0x10
ffffffffc02004a8:	0186df1b          	srliw	t5,a3,0x18
ffffffffc02004ac:	01875e9b          	srliw	t4,a4,0x18
ffffffffc02004b0:	8ddd                	or	a1,a1,a5
ffffffffc02004b2:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b6:	0186979b          	slliw	a5,a3,0x18
ffffffffc02004ba:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004be:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c2:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004c6:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004ca:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ce:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004d2:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004d6:	08a2                	slli	a7,a7,0x8
ffffffffc02004d8:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004dc:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004e0:	0ff6f693          	zext.b	a3,a3
ffffffffc02004e4:	01de6833          	or	a6,t3,t4
ffffffffc02004e8:	0ff77713          	zext.b	a4,a4
ffffffffc02004ec:	01166633          	or	a2,a2,a7
ffffffffc02004f0:	0067e7b3          	or	a5,a5,t1
ffffffffc02004f4:	06a2                	slli	a3,a3,0x8
ffffffffc02004f6:	01046433          	or	s0,s0,a6
ffffffffc02004fa:	0722                	slli	a4,a4,0x8
ffffffffc02004fc:	8fd5                	or	a5,a5,a3
ffffffffc02004fe:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc0200500:	1582                	slli	a1,a1,0x20
ffffffffc0200502:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200504:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200506:	9201                	srli	a2,a2,0x20
ffffffffc0200508:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020050a:	1402                	slli	s0,s0,0x20
ffffffffc020050c:	00b7e4b3          	or	s1,a5,a1
ffffffffc0200510:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200512:	c37ff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200516:	85a6                	mv	a1,s1
ffffffffc0200518:	00001517          	auipc	a0,0x1
ffffffffc020051c:	36850513          	addi	a0,a0,872 # ffffffffc0201880 <etext+0x1ae>
ffffffffc0200520:	c29ff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200524:	01445613          	srli	a2,s0,0x14
ffffffffc0200528:	85a2                	mv	a1,s0
ffffffffc020052a:	00001517          	auipc	a0,0x1
ffffffffc020052e:	36e50513          	addi	a0,a0,878 # ffffffffc0201898 <etext+0x1c6>
ffffffffc0200532:	c17ff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200536:	009405b3          	add	a1,s0,s1
ffffffffc020053a:	15fd                	addi	a1,a1,-1
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	37c50513          	addi	a0,a0,892 # ffffffffc02018b8 <etext+0x1e6>
ffffffffc0200544:	c05ff0ef          	jal	ffffffffc0200148 <cprintf>
        memory_base = mem_base;
ffffffffc0200548:	00006797          	auipc	a5,0x6
ffffffffc020054c:	ba97b423          	sd	s1,-1112(a5) # ffffffffc02060f0 <memory_base>
        memory_size = mem_size;
ffffffffc0200550:	00006797          	auipc	a5,0x6
ffffffffc0200554:	b887bc23          	sd	s0,-1128(a5) # ffffffffc02060e8 <memory_size>
ffffffffc0200558:	b531                	j	ffffffffc0200364 <dtb_init+0x13c>

ffffffffc020055a <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020055a:	00006517          	auipc	a0,0x6
ffffffffc020055e:	b9653503          	ld	a0,-1130(a0) # ffffffffc02060f0 <memory_base>
ffffffffc0200562:	8082                	ret

ffffffffc0200564 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc0200564:	00006517          	auipc	a0,0x6
ffffffffc0200568:	b8453503          	ld	a0,-1148(a0) # ffffffffc02060e8 <memory_size>
ffffffffc020056c:	8082                	ret

ffffffffc020056e <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc020056e:	00006797          	auipc	a5,0x6
ffffffffc0200572:	b8a7b783          	ld	a5,-1142(a5) # ffffffffc02060f8 <pmm_manager>
ffffffffc0200576:	6f9c                	ld	a5,24(a5)
ffffffffc0200578:	8782                	jr	a5

ffffffffc020057a <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc020057a:	00006797          	auipc	a5,0x6
ffffffffc020057e:	b7e7b783          	ld	a5,-1154(a5) # ffffffffc02060f8 <pmm_manager>
ffffffffc0200582:	739c                	ld	a5,32(a5)
ffffffffc0200584:	8782                	jr	a5

ffffffffc0200586 <pmm_init>:
    pmm_manager = &slub_pmm_manager;
ffffffffc0200586:	00002797          	auipc	a5,0x2
ffffffffc020058a:	f0278793          	addi	a5,a5,-254 # ffffffffc0202488 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020058e:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200590:	7139                	addi	sp,sp,-64
ffffffffc0200592:	fc06                	sd	ra,56(sp)
ffffffffc0200594:	f822                	sd	s0,48(sp)
ffffffffc0200596:	f426                	sd	s1,40(sp)
ffffffffc0200598:	ec4e                	sd	s3,24(sp)
ffffffffc020059a:	f04a                	sd	s2,32(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc020059c:	00006417          	auipc	s0,0x6
ffffffffc02005a0:	b5c40413          	addi	s0,s0,-1188 # ffffffffc02060f8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005a4:	00001517          	auipc	a0,0x1
ffffffffc02005a8:	37c50513          	addi	a0,a0,892 # ffffffffc0201920 <etext+0x24e>
    pmm_manager = &slub_pmm_manager;
ffffffffc02005ac:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02005ae:	b9bff0ef          	jal	ffffffffc0200148 <cprintf>
    pmm_manager->init();
ffffffffc02005b2:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02005b4:	00006497          	auipc	s1,0x6
ffffffffc02005b8:	b5c48493          	addi	s1,s1,-1188 # ffffffffc0206110 <va_pa_offset>
    pmm_manager->init();
ffffffffc02005bc:	679c                	ld	a5,8(a5)
ffffffffc02005be:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02005c0:	57f5                	li	a5,-3
ffffffffc02005c2:	07fa                	slli	a5,a5,0x1e
ffffffffc02005c4:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc02005c6:	f95ff0ef          	jal	ffffffffc020055a <get_memory_base>
ffffffffc02005ca:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc02005cc:	f99ff0ef          	jal	ffffffffc0200564 <get_memory_size>
    if (mem_size == 0) {
ffffffffc02005d0:	14050b63          	beqz	a0,ffffffffc0200726 <pmm_init+0x1a0>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc02005d4:	00a98933          	add	s2,s3,a0
ffffffffc02005d8:	e42a                	sd	a0,8(sp)
    cprintf("physcial memory map:\n");
ffffffffc02005da:	00001517          	auipc	a0,0x1
ffffffffc02005de:	38e50513          	addi	a0,a0,910 # ffffffffc0201968 <etext+0x296>
ffffffffc02005e2:	b67ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02005e6:	65a2                	ld	a1,8(sp)
ffffffffc02005e8:	864e                	mv	a2,s3
ffffffffc02005ea:	fff90693          	addi	a3,s2,-1
ffffffffc02005ee:	00001517          	auipc	a0,0x1
ffffffffc02005f2:	39250513          	addi	a0,a0,914 # ffffffffc0201980 <etext+0x2ae>
ffffffffc02005f6:	b53ff0ef          	jal	ffffffffc0200148 <cprintf>
    if (maxpa > KERNTOP) {
ffffffffc02005fa:	c80007b7          	lui	a5,0xc8000
ffffffffc02005fe:	85ca                	mv	a1,s2
ffffffffc0200600:	0d27e163          	bltu	a5,s2,ffffffffc02006c2 <pmm_init+0x13c>
ffffffffc0200604:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200606:	00007697          	auipc	a3,0x7
ffffffffc020060a:	b2168693          	addi	a3,a3,-1247 # ffffffffc0207127 <end+0xfff>
ffffffffc020060e:	8efd                	and	a3,a3,a5
    npage = maxpa / PGSIZE;
ffffffffc0200610:	81b1                	srli	a1,a1,0xc
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200612:	fff80837          	lui	a6,0xfff80
    npage = maxpa / PGSIZE;
ffffffffc0200616:	00006797          	auipc	a5,0x6
ffffffffc020061a:	b0b7b123          	sd	a1,-1278(a5) # ffffffffc0206118 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020061e:	00006797          	auipc	a5,0x6
ffffffffc0200622:	b0d7b123          	sd	a3,-1278(a5) # ffffffffc0206120 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200626:	982e                	add	a6,a6,a1
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200628:	88b6                	mv	a7,a3
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020062a:	02080963          	beqz	a6,ffffffffc020065c <pmm_init+0xd6>
ffffffffc020062e:	00259613          	slli	a2,a1,0x2
ffffffffc0200632:	962e                	add	a2,a2,a1
ffffffffc0200634:	fec007b7          	lui	a5,0xfec00
ffffffffc0200638:	97b6                	add	a5,a5,a3
ffffffffc020063a:	060e                	slli	a2,a2,0x3
ffffffffc020063c:	963e                	add	a2,a2,a5
ffffffffc020063e:	87b6                	mv	a5,a3
        SetPageReserved(pages + i);
ffffffffc0200640:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200642:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f9f00>
        SetPageReserved(pages + i);
ffffffffc0200646:	00176713          	ori	a4,a4,1
ffffffffc020064a:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020064e:	fec799e3          	bne	a5,a2,ffffffffc0200640 <pmm_init+0xba>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200652:	00281793          	slli	a5,a6,0x2
ffffffffc0200656:	97c2                	add	a5,a5,a6
ffffffffc0200658:	078e                	slli	a5,a5,0x3
ffffffffc020065a:	96be                	add	a3,a3,a5
ffffffffc020065c:	c02007b7          	lui	a5,0xc0200
ffffffffc0200660:	0af6e763          	bltu	a3,a5,ffffffffc020070e <pmm_init+0x188>
ffffffffc0200664:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0200666:	77fd                	lui	a5,0xfffff
ffffffffc0200668:	00f97933          	and	s2,s2,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020066c:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc020066e:	0526ec63          	bltu	a3,s2,ffffffffc02006c6 <pmm_init+0x140>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200672:	601c                	ld	a5,0(s0)
ffffffffc0200674:	7b9c                	ld	a5,48(a5)
ffffffffc0200676:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200678:	00001517          	auipc	a0,0x1
ffffffffc020067c:	39050513          	addi	a0,a0,912 # ffffffffc0201a08 <etext+0x336>
ffffffffc0200680:	ac9ff0ef          	jal	ffffffffc0200148 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200684:	00005597          	auipc	a1,0x5
ffffffffc0200688:	97c58593          	addi	a1,a1,-1668 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020068c:	00006797          	auipc	a5,0x6
ffffffffc0200690:	a6b7be23          	sd	a1,-1412(a5) # ffffffffc0206108 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200694:	c02007b7          	lui	a5,0xc0200
ffffffffc0200698:	0af5e363          	bltu	a1,a5,ffffffffc020073e <pmm_init+0x1b8>
ffffffffc020069c:	609c                	ld	a5,0(s1)
}
ffffffffc020069e:	7442                	ld	s0,48(sp)
ffffffffc02006a0:	70e2                	ld	ra,56(sp)
ffffffffc02006a2:	74a2                	ld	s1,40(sp)
ffffffffc02006a4:	7902                	ld	s2,32(sp)
ffffffffc02006a6:	69e2                	ld	s3,24(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02006a8:	40f586b3          	sub	a3,a1,a5
ffffffffc02006ac:	00006797          	auipc	a5,0x6
ffffffffc02006b0:	a4d7ba23          	sd	a3,-1452(a5) # ffffffffc0206100 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02006b4:	00001517          	auipc	a0,0x1
ffffffffc02006b8:	37450513          	addi	a0,a0,884 # ffffffffc0201a28 <etext+0x356>
ffffffffc02006bc:	8636                	mv	a2,a3
}
ffffffffc02006be:	6121                	addi	sp,sp,64
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02006c0:	b461                	j	ffffffffc0200148 <cprintf>
    if (maxpa > KERNTOP) {
ffffffffc02006c2:	85be                	mv	a1,a5
ffffffffc02006c4:	b781                	j	ffffffffc0200604 <pmm_init+0x7e>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02006c6:	6705                	lui	a4,0x1
ffffffffc02006c8:	177d                	addi	a4,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc02006ca:	96ba                	add	a3,a3,a4
ffffffffc02006cc:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02006ce:	00c6d793          	srli	a5,a3,0xc
ffffffffc02006d2:	02b7f263          	bgeu	a5,a1,ffffffffc02006f6 <pmm_init+0x170>
    pmm_manager->init_memmap(base, n);
ffffffffc02006d6:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02006d8:	fff80637          	lui	a2,0xfff80
ffffffffc02006dc:	97b2                	add	a5,a5,a2
ffffffffc02006de:	00279513          	slli	a0,a5,0x2
ffffffffc02006e2:	953e                	add	a0,a0,a5
ffffffffc02006e4:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02006e6:	40d90933          	sub	s2,s2,a3
ffffffffc02006ea:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02006ec:	00c95593          	srli	a1,s2,0xc
ffffffffc02006f0:	9546                	add	a0,a0,a7
ffffffffc02006f2:	9782                	jalr	a5
}
ffffffffc02006f4:	bfbd                	j	ffffffffc0200672 <pmm_init+0xec>
        panic("pa2page called with invalid pa");
ffffffffc02006f6:	00001617          	auipc	a2,0x1
ffffffffc02006fa:	2e260613          	addi	a2,a2,738 # ffffffffc02019d8 <etext+0x306>
ffffffffc02006fe:	06a00593          	li	a1,106
ffffffffc0200702:	00001517          	auipc	a0,0x1
ffffffffc0200706:	2f650513          	addi	a0,a0,758 # ffffffffc02019f8 <etext+0x326>
ffffffffc020070a:	abfff0ef          	jal	ffffffffc02001c8 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020070e:	00001617          	auipc	a2,0x1
ffffffffc0200712:	2a260613          	addi	a2,a2,674 # ffffffffc02019b0 <etext+0x2de>
ffffffffc0200716:	06400593          	li	a1,100
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	23e50513          	addi	a0,a0,574 # ffffffffc0201958 <etext+0x286>
ffffffffc0200722:	aa7ff0ef          	jal	ffffffffc02001c8 <__panic>
        panic("DTB memory info not available");
ffffffffc0200726:	00001617          	auipc	a2,0x1
ffffffffc020072a:	21260613          	addi	a2,a2,530 # ffffffffc0201938 <etext+0x266>
ffffffffc020072e:	04c00593          	li	a1,76
ffffffffc0200732:	00001517          	auipc	a0,0x1
ffffffffc0200736:	22650513          	addi	a0,a0,550 # ffffffffc0201958 <etext+0x286>
ffffffffc020073a:	a8fff0ef          	jal	ffffffffc02001c8 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc020073e:	86ae                	mv	a3,a1
ffffffffc0200740:	00001617          	auipc	a2,0x1
ffffffffc0200744:	27060613          	addi	a2,a2,624 # ffffffffc02019b0 <etext+0x2de>
ffffffffc0200748:	07f00593          	li	a1,127
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	20c50513          	addi	a0,a0,524 # ffffffffc0201958 <etext+0x286>
ffffffffc0200754:	a75ff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc0200758 <slub_nr_free_pages>:
    cprintf("释放完成，当前空闲: %u\n", nr_free);
}

static size_t slub_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200758:	00006517          	auipc	a0,0x6
ffffffffc020075c:	98056503          	lwu	a0,-1664(a0) # ffffffffc02060d8 <free_area+0x10>
ffffffffc0200760:	8082                	ret

ffffffffc0200762 <slub_alloc_pages>:
static struct Page *slub_alloc_pages(size_t n) {
ffffffffc0200762:	1101                	addi	sp,sp,-32
ffffffffc0200764:	ec06                	sd	ra,24(sp)
    assert(n > 0);
ffffffffc0200766:	12050e63          	beqz	a0,ffffffffc02008a2 <slub_alloc_pages+0x140>
    cprintf("slub_alloc_pages: 请求 %u 页，当前空闲: %u\n", n, nr_free);
ffffffffc020076a:	00006617          	auipc	a2,0x6
ffffffffc020076e:	96e62603          	lw	a2,-1682(a2) # ffffffffc02060d8 <free_area+0x10>
ffffffffc0200772:	85aa                	mv	a1,a0
ffffffffc0200774:	e02a                	sd	a0,0(sp)
ffffffffc0200776:	00001517          	auipc	a0,0x1
ffffffffc020077a:	32a50513          	addi	a0,a0,810 # ffffffffc0201aa0 <etext+0x3ce>
ffffffffc020077e:	9cbff0ef          	jal	ffffffffc0200148 <cprintf>
    if (n > nr_free) {
ffffffffc0200782:	00006697          	auipc	a3,0x6
ffffffffc0200786:	9566a683          	lw	a3,-1706(a3) # ffffffffc02060d8 <free_area+0x10>
ffffffffc020078a:	6582                	ld	a1,0(sp)
    list_entry_t *le = &free_list;
ffffffffc020078c:	00006817          	auipc	a6,0x6
ffffffffc0200790:	93c80813          	addi	a6,a6,-1732 # ffffffffc02060c8 <free_area>
    if (n > nr_free) {
ffffffffc0200794:	02069713          	slli	a4,a3,0x20
ffffffffc0200798:	9301                	srli	a4,a4,0x20
    list_entry_t *le = &free_list;
ffffffffc020079a:	87c2                	mv	a5,a6
    if (n > nr_free) {
ffffffffc020079c:	00b77763          	bgeu	a4,a1,ffffffffc02007aa <slub_alloc_pages+0x48>
ffffffffc02007a0:	a8c5                	j	ffffffffc0200890 <slub_alloc_pages+0x12e>
        if (p->property >= n) {
ffffffffc02007a2:	ff87e703          	lwu	a4,-8(a5)
ffffffffc02007a6:	06b77663          	bgeu	a4,a1,ffffffffc0200812 <slub_alloc_pages+0xb0>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02007aa:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02007ac:	ff079be3          	bne	a5,a6,ffffffffc02007a2 <slub_alloc_pages+0x40>
        cprintf("错误: 没有找到足够大的连续页面块\n");
ffffffffc02007b0:	00001517          	auipc	a0,0x1
ffffffffc02007b4:	35850513          	addi	a0,a0,856 # ffffffffc0201b08 <etext+0x436>
ffffffffc02007b8:	e03e                	sd	a5,0(sp)
ffffffffc02007ba:	98fff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("调试信息: 遍历空闲链表...\n");
ffffffffc02007be:	00001517          	auipc	a0,0x1
ffffffffc02007c2:	38250513          	addi	a0,a0,898 # ffffffffc0201b40 <etext+0x46e>
ffffffffc02007c6:	983ff0ef          	jal	ffffffffc0200148 <cprintf>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02007ca:	6782                	ld	a5,0(sp)
        int count = 0;
ffffffffc02007cc:	4581                	li	a1,0
        while ((le = list_next(le)) != &free_list) {
ffffffffc02007ce:	00006817          	auipc	a6,0x6
ffffffffc02007d2:	8fa80813          	addi	a6,a6,-1798 # ffffffffc02060c8 <free_area>
ffffffffc02007d6:	a011                	j	ffffffffc02007da <slub_alloc_pages+0x78>
            cprintf("页面 %d: 地址=%p, property=%u\n", count++, p, p->property);
ffffffffc02007d8:	85ba                	mv	a1,a4
ffffffffc02007da:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != &free_list) {
ffffffffc02007dc:	03078963          	beq	a5,a6,ffffffffc020080e <slub_alloc_pages+0xac>
            cprintf("页面 %d: 地址=%p, property=%u\n", count++, p, p->property);
ffffffffc02007e0:	ff87a683          	lw	a3,-8(a5)
ffffffffc02007e4:	0015871b          	addiw	a4,a1,1
ffffffffc02007e8:	fe878613          	addi	a2,a5,-24
ffffffffc02007ec:	00001517          	auipc	a0,0x1
ffffffffc02007f0:	37c50513          	addi	a0,a0,892 # ffffffffc0201b68 <etext+0x496>
ffffffffc02007f4:	e43e                	sd	a5,8(sp)
ffffffffc02007f6:	e03a                	sd	a4,0(sp)
ffffffffc02007f8:	951ff0ef          	jal	ffffffffc0200148 <cprintf>
            if (count > 10) break; // 只显示前10个
ffffffffc02007fc:	6702                	ld	a4,0(sp)
ffffffffc02007fe:	46ad                	li	a3,11
ffffffffc0200800:	67a2                	ld	a5,8(sp)
ffffffffc0200802:	00006817          	auipc	a6,0x6
ffffffffc0200806:	8c680813          	addi	a6,a6,-1850 # ffffffffc02060c8 <free_area>
ffffffffc020080a:	fcd717e3          	bne	a4,a3,ffffffffc02007d8 <slub_alloc_pages+0x76>
        return NULL;
ffffffffc020080e:	4601                	li	a2,0
ffffffffc0200810:	a091                	j	ffffffffc0200854 <slub_alloc_pages+0xf2>
    if (page->property > n) {
ffffffffc0200812:	ff87a503          	lw	a0,-8(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200816:	0007b883          	ld	a7,0(a5)
ffffffffc020081a:	6798                	ld	a4,8(a5)
ffffffffc020081c:	02051313          	slli	t1,a0,0x20
ffffffffc0200820:	02035313          	srli	t1,t1,0x20
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200824:	00e8b423          	sd	a4,8(a7)
    next->prev = prev;
ffffffffc0200828:	01173023          	sd	a7,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc020082c:	fe878613          	addi	a2,a5,-24
    if (page->property > n) {
ffffffffc0200830:	0265e663          	bltu	a1,t1,ffffffffc020085c <slub_alloc_pages+0xfa>
    ClearPageProperty(page);
ffffffffc0200834:	ff07b703          	ld	a4,-16(a5)
    nr_free -= n;
ffffffffc0200838:	9e8d                	subw	a3,a3,a1
ffffffffc020083a:	00d82823          	sw	a3,16(a6)
    ClearPageProperty(page);
ffffffffc020083e:	9b75                	andi	a4,a4,-3
ffffffffc0200840:	fee7b823          	sd	a4,-16(a5)
    cprintf("分配成功: 分配 %u 页，页面地址: %p，剩余空闲: %u\n", n, page, nr_free);
ffffffffc0200844:	00001517          	auipc	a0,0x1
ffffffffc0200848:	34c50513          	addi	a0,a0,844 # ffffffffc0201b90 <etext+0x4be>
ffffffffc020084c:	e032                	sd	a2,0(sp)
ffffffffc020084e:	8fbff0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc0200852:	6602                	ld	a2,0(sp)
}
ffffffffc0200854:	60e2                	ld	ra,24(sp)
ffffffffc0200856:	8532                	mv	a0,a2
ffffffffc0200858:	6105                	addi	sp,sp,32
ffffffffc020085a:	8082                	ret
        struct Page *p = page + n;
ffffffffc020085c:	00259713          	slli	a4,a1,0x2
ffffffffc0200860:	972e                	add	a4,a4,a1
ffffffffc0200862:	070e                	slli	a4,a4,0x3
ffffffffc0200864:	9732                	add	a4,a4,a2
        SetPageProperty(p);
ffffffffc0200866:	00873883          	ld	a7,8(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc020086a:	00883303          	ld	t1,8(a6)
        p->property = page->property - n;
ffffffffc020086e:	9d0d                	subw	a0,a0,a1
        SetPageProperty(p);
ffffffffc0200870:	0028e893          	ori	a7,a7,2
        p->property = page->property - n;
ffffffffc0200874:	cb08                	sw	a0,16(a4)
        SetPageProperty(p);
ffffffffc0200876:	01173423          	sd	a7,8(a4)
        list_add(&free_list, &(p->page_link));
ffffffffc020087a:	01870513          	addi	a0,a4,24
    prev->next = next->prev = elm;
ffffffffc020087e:	00a33023          	sd	a0,0(t1)
ffffffffc0200882:	00a83423          	sd	a0,8(a6)
    elm->next = next;
ffffffffc0200886:	02673023          	sd	t1,32(a4)
    elm->prev = prev;
ffffffffc020088a:	01073c23          	sd	a6,24(a4)
}
ffffffffc020088e:	b75d                	j	ffffffffc0200834 <slub_alloc_pages+0xd2>
        cprintf("错误: 请求 %u 页但只有 %u 页空闲\n", n, nr_free);
ffffffffc0200890:	8636                	mv	a2,a3
ffffffffc0200892:	00001517          	auipc	a0,0x1
ffffffffc0200896:	24650513          	addi	a0,a0,582 # ffffffffc0201ad8 <etext+0x406>
ffffffffc020089a:	8afff0ef          	jal	ffffffffc0200148 <cprintf>
        return NULL;
ffffffffc020089e:	4601                	li	a2,0
ffffffffc02008a0:	bf55                	j	ffffffffc0200854 <slub_alloc_pages+0xf2>
    assert(n > 0);
ffffffffc02008a2:	00001697          	auipc	a3,0x1
ffffffffc02008a6:	1c668693          	addi	a3,a3,454 # ffffffffc0201a68 <etext+0x396>
ffffffffc02008aa:	00001617          	auipc	a2,0x1
ffffffffc02008ae:	1c660613          	addi	a2,a2,454 # ffffffffc0201a70 <etext+0x39e>
ffffffffc02008b2:	0fb00593          	li	a1,251
ffffffffc02008b6:	00001517          	auipc	a0,0x1
ffffffffc02008ba:	1d250513          	addi	a0,a0,466 # ffffffffc0201a88 <etext+0x3b6>
ffffffffc02008be:	90bff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc02008c2 <slub_free_pages>:
static void slub_free_pages(struct Page *base, size_t n) {
ffffffffc02008c2:	1101                	addi	sp,sp,-32
ffffffffc02008c4:	ec06                	sd	ra,24(sp)
ffffffffc02008c6:	e822                	sd	s0,16(sp)
ffffffffc02008c8:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc02008ca:	12058463          	beqz	a1,ffffffffc02009f2 <slub_free_pages+0x130>
    cprintf("slub_free_pages: 释放 %u 页，释放前空闲: %u\n", n, nr_free);
ffffffffc02008ce:	00006617          	auipc	a2,0x6
ffffffffc02008d2:	80a62603          	lw	a2,-2038(a2) # ffffffffc02060d8 <free_area+0x10>
ffffffffc02008d6:	842a                	mv	s0,a0
ffffffffc02008d8:	00001517          	auipc	a0,0x1
ffffffffc02008dc:	30050513          	addi	a0,a0,768 # ffffffffc0201bd8 <etext+0x506>
ffffffffc02008e0:	84ae                	mv	s1,a1
ffffffffc02008e2:	867ff0ef          	jal	ffffffffc0200148 <cprintf>
    for (; p != base + n; p++) {
ffffffffc02008e6:	00249713          	slli	a4,s1,0x2
ffffffffc02008ea:	9726                	add	a4,a4,s1
ffffffffc02008ec:	070e                	slli	a4,a4,0x3
ffffffffc02008ee:	00e406b3          	add	a3,s0,a4
    struct Page *p = base;
ffffffffc02008f2:	87a2                	mv	a5,s0
    for (; p != base + n; p++) {
ffffffffc02008f4:	cf01                	beqz	a4,ffffffffc020090c <slub_free_pages+0x4a>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02008f6:	6798                	ld	a4,8(a5)
ffffffffc02008f8:	8b0d                	andi	a4,a4,3
ffffffffc02008fa:	ef61                	bnez	a4,ffffffffc02009d2 <slub_free_pages+0x110>
        p->flags = 0;
ffffffffc02008fc:	0007b423          	sd	zero,8(a5)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200900:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++) {
ffffffffc0200904:	02878793          	addi	a5,a5,40
ffffffffc0200908:	fed797e3          	bne	a5,a3,ffffffffc02008f6 <slub_free_pages+0x34>
    SetPageProperty(base);
ffffffffc020090c:	641c                	ld	a5,8(s0)
    return listelm->next;
ffffffffc020090e:	00005317          	auipc	t1,0x5
ffffffffc0200912:	7ba30313          	addi	t1,t1,1978 # ffffffffc02060c8 <free_area>
ffffffffc0200916:	00833703          	ld	a4,8(t1)
ffffffffc020091a:	0027e793          	ori	a5,a5,2
    base->property = n;
ffffffffc020091e:	c804                	sw	s1,16(s0)
    SetPageProperty(base);
ffffffffc0200920:	e41c                	sd	a5,8(s0)
    while (le != &free_list) {
ffffffffc0200922:	0004881b          	sext.w	a6,s1
ffffffffc0200926:	06670163          	beq	a4,t1,ffffffffc0200988 <slub_free_pages+0xc6>
        if (base + base->property == p) {
ffffffffc020092a:	02081613          	slli	a2,a6,0x20
ffffffffc020092e:	9201                	srli	a2,a2,0x20
ffffffffc0200930:	00261793          	slli	a5,a2,0x2
ffffffffc0200934:	97b2                	add	a5,a5,a2
ffffffffc0200936:	078e                	slli	a5,a5,0x3
        p = le2page(le, page_link);
ffffffffc0200938:	fe870513          	addi	a0,a4,-24
        if (base + base->property == p) {
ffffffffc020093c:	97a2                	add	a5,a5,s0
ffffffffc020093e:	6714                	ld	a3,8(a4)
            base->property += p->property;
ffffffffc0200940:	ff872603          	lw	a2,-8(a4)
        if (base + base->property == p) {
ffffffffc0200944:	06f50b63          	beq	a0,a5,ffffffffc02009ba <slub_free_pages+0xf8>
        else if (p + p->property == base) {
ffffffffc0200948:	02061893          	slli	a7,a2,0x20
ffffffffc020094c:	0208d893          	srli	a7,a7,0x20
ffffffffc0200950:	00289793          	slli	a5,a7,0x2
ffffffffc0200954:	97c6                	add	a5,a5,a7
ffffffffc0200956:	078e                	slli	a5,a5,0x3
ffffffffc0200958:	97aa                	add	a5,a5,a0
ffffffffc020095a:	00f40863          	beq	s0,a5,ffffffffc020096a <slub_free_pages+0xa8>
    while (le != &free_list) {
ffffffffc020095e:	02668363          	beq	a3,t1,ffffffffc0200984 <slub_free_pages+0xc2>
        if (base + base->property == p) {
ffffffffc0200962:	01042803          	lw	a6,16(s0)
ffffffffc0200966:	8736                	mv	a4,a3
ffffffffc0200968:	b7c9                	j	ffffffffc020092a <slub_free_pages+0x68>
            ClearPageProperty(base);
ffffffffc020096a:	641c                	ld	a5,8(s0)
    __list_del(listelm->prev, listelm->next);
ffffffffc020096c:	630c                	ld	a1,0(a4)
            p->property += base->property;
ffffffffc020096e:	0106063b          	addw	a2,a2,a6
ffffffffc0200972:	fec72c23          	sw	a2,-8(a4)
            ClearPageProperty(base);
ffffffffc0200976:	9bf5                	andi	a5,a5,-3
ffffffffc0200978:	e41c                	sd	a5,8(s0)
    prev->next = next;
ffffffffc020097a:	e594                	sd	a3,8(a1)
    next->prev = prev;
ffffffffc020097c:	e28c                	sd	a1,0(a3)
            base = p;
ffffffffc020097e:	842a                	mv	s0,a0
    while (le != &free_list) {
ffffffffc0200980:	fe6691e3          	bne	a3,t1,ffffffffc0200962 <slub_free_pages+0xa0>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200984:	00833703          	ld	a4,8(t1)
    nr_free += n;
ffffffffc0200988:	00005597          	auipc	a1,0x5
ffffffffc020098c:	7505a583          	lw	a1,1872(a1) # ffffffffc02060d8 <free_area+0x10>
    list_add(&free_list, &(base->page_link));
ffffffffc0200990:	01840793          	addi	a5,s0,24
}
ffffffffc0200994:	60e2                	ld	ra,24(sp)
    nr_free += n;
ffffffffc0200996:	9da5                	addw	a1,a1,s1
ffffffffc0200998:	00b32823          	sw	a1,16(t1)
    prev->next = next->prev = elm;
ffffffffc020099c:	e31c                	sd	a5,0(a4)
    elm->next = next;
ffffffffc020099e:	f018                	sd	a4,32(s0)
    elm->prev = prev;
ffffffffc02009a0:	00643c23          	sd	t1,24(s0)
}
ffffffffc02009a4:	6442                	ld	s0,16(sp)
ffffffffc02009a6:	64a2                	ld	s1,8(sp)
    prev->next = next->prev = elm;
ffffffffc02009a8:	00f33423          	sd	a5,8(t1)
    cprintf("释放完成，当前空闲: %u\n", nr_free);
ffffffffc02009ac:	00001517          	auipc	a0,0x1
ffffffffc02009b0:	28c50513          	addi	a0,a0,652 # ffffffffc0201c38 <etext+0x566>
}
ffffffffc02009b4:	6105                	addi	sp,sp,32
    cprintf("释放完成，当前空闲: %u\n", nr_free);
ffffffffc02009b6:	f92ff06f          	j	ffffffffc0200148 <cprintf>
            ClearPageProperty(p);
ffffffffc02009ba:	ff073783          	ld	a5,-16(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02009be:	630c                	ld	a1,0(a4)
            base->property += p->property;
ffffffffc02009c0:	0106063b          	addw	a2,a2,a6
ffffffffc02009c4:	c810                	sw	a2,16(s0)
            ClearPageProperty(p);
ffffffffc02009c6:	9bf5                	andi	a5,a5,-3
ffffffffc02009c8:	fef73823          	sd	a5,-16(a4)
    prev->next = next;
ffffffffc02009cc:	e594                	sd	a3,8(a1)
    next->prev = prev;
ffffffffc02009ce:	e28c                	sd	a1,0(a3)
}
ffffffffc02009d0:	b779                	j	ffffffffc020095e <slub_free_pages+0x9c>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02009d2:	00001697          	auipc	a3,0x1
ffffffffc02009d6:	23e68693          	addi	a3,a3,574 # ffffffffc0201c10 <etext+0x53e>
ffffffffc02009da:	00001617          	auipc	a2,0x1
ffffffffc02009de:	09660613          	addi	a2,a2,150 # ffffffffc0201a70 <etext+0x39e>
ffffffffc02009e2:	13800593          	li	a1,312
ffffffffc02009e6:	00001517          	auipc	a0,0x1
ffffffffc02009ea:	0a250513          	addi	a0,a0,162 # ffffffffc0201a88 <etext+0x3b6>
ffffffffc02009ee:	fdaff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc02009f2:	00001697          	auipc	a3,0x1
ffffffffc02009f6:	07668693          	addi	a3,a3,118 # ffffffffc0201a68 <etext+0x396>
ffffffffc02009fa:	00001617          	auipc	a2,0x1
ffffffffc02009fe:	07660613          	addi	a2,a2,118 # ffffffffc0201a70 <etext+0x39e>
ffffffffc0200a02:	13200593          	li	a1,306
ffffffffc0200a06:	00001517          	auipc	a0,0x1
ffffffffc0200a0a:	08250513          	addi	a0,a0,130 # ffffffffc0201a88 <etext+0x3b6>
ffffffffc0200a0e:	fbaff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc0200a12 <slub_init_memmap>:
static void slub_init_memmap(struct Page *base, size_t n) {
ffffffffc0200a12:	1141                	addi	sp,sp,-16
ffffffffc0200a14:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200a16:	c9d9                	beqz	a1,ffffffffc0200aac <slub_init_memmap+0x9a>
    for (; p != base + n; p++) {
ffffffffc0200a18:	00259693          	slli	a3,a1,0x2
ffffffffc0200a1c:	96ae                	add	a3,a3,a1
ffffffffc0200a1e:	068e                	slli	a3,a3,0x3
ffffffffc0200a20:	00005817          	auipc	a6,0x5
ffffffffc0200a24:	6a880813          	addi	a6,a6,1704 # ffffffffc02060c8 <free_area>
ffffffffc0200a28:	ce9d                	beqz	a3,ffffffffc0200a66 <slub_init_memmap+0x54>
ffffffffc0200a2a:	00083703          	ld	a4,0(a6)
ffffffffc0200a2e:	96aa                	add	a3,a3,a0
ffffffffc0200a30:	4881                	li	a7,0
        p->property = 1;  // 每个页面初始化为1页大小
ffffffffc0200a32:	4e05                	li	t3,1
        SetPageProperty(p);
ffffffffc0200a34:	4309                	li	t1,2
ffffffffc0200a36:	a011                	j	ffffffffc0200a3a <slub_init_memmap+0x28>
    prev->next = next->prev = elm;
ffffffffc0200a38:	873e                	mv	a4,a5
        assert(PageReserved(p));
ffffffffc0200a3a:	651c                	ld	a5,8(a0)
ffffffffc0200a3c:	8b85                	andi	a5,a5,1
ffffffffc0200a3e:	c3b9                	beqz	a5,ffffffffc0200a84 <slub_init_memmap+0x72>
        p->property = 1;  // 每个页面初始化为1页大小
ffffffffc0200a40:	01c52823          	sw	t3,16(a0)
ffffffffc0200a44:	00052023          	sw	zero,0(a0)
        SetPageProperty(p);
ffffffffc0200a48:	00653423          	sd	t1,8(a0)
        list_add_before(&free_list, &(p->page_link));
ffffffffc0200a4c:	01850793          	addi	a5,a0,24
ffffffffc0200a50:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc0200a52:	03053023          	sd	a6,32(a0)
    elm->prev = prev;
ffffffffc0200a56:	ed18                	sd	a4,24(a0)
    for (; p != base + n; p++) {
ffffffffc0200a58:	02850513          	addi	a0,a0,40
ffffffffc0200a5c:	4885                	li	a7,1
ffffffffc0200a5e:	fcd51de3          	bne	a0,a3,ffffffffc0200a38 <slub_init_memmap+0x26>
ffffffffc0200a62:	00f83023          	sd	a5,0(a6)
    nr_free += n;
ffffffffc0200a66:	00005617          	auipc	a2,0x5
ffffffffc0200a6a:	67262603          	lw	a2,1650(a2) # ffffffffc02060d8 <free_area+0x10>
}
ffffffffc0200a6e:	60a2                	ld	ra,8(sp)
    cprintf("slub_init_memmap: 初始化 %u 页，总空闲页: %u\n", n, nr_free);
ffffffffc0200a70:	00001517          	auipc	a0,0x1
ffffffffc0200a74:	20050513          	addi	a0,a0,512 # ffffffffc0201c70 <etext+0x59e>
    nr_free += n;
ffffffffc0200a78:	9e2d                	addw	a2,a2,a1
ffffffffc0200a7a:	00c82823          	sw	a2,16(a6)
}
ffffffffc0200a7e:	0141                	addi	sp,sp,16
    cprintf("slub_init_memmap: 初始化 %u 页，总空闲页: %u\n", n, nr_free);
ffffffffc0200a80:	ec8ff06f          	j	ffffffffc0200148 <cprintf>
ffffffffc0200a84:	00088463          	beqz	a7,ffffffffc0200a8c <slub_init_memmap+0x7a>
ffffffffc0200a88:	00e83023          	sd	a4,0(a6)
        assert(PageReserved(p));
ffffffffc0200a8c:	00001697          	auipc	a3,0x1
ffffffffc0200a90:	1d468693          	addi	a3,a3,468 # ffffffffc0201c60 <etext+0x58e>
ffffffffc0200a94:	00001617          	auipc	a2,0x1
ffffffffc0200a98:	fdc60613          	addi	a2,a2,-36 # ffffffffc0201a70 <etext+0x39e>
ffffffffc0200a9c:	0ef00593          	li	a1,239
ffffffffc0200aa0:	00001517          	auipc	a0,0x1
ffffffffc0200aa4:	fe850513          	addi	a0,a0,-24 # ffffffffc0201a88 <etext+0x3b6>
ffffffffc0200aa8:	f20ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0200aac:	00001697          	auipc	a3,0x1
ffffffffc0200ab0:	fbc68693          	addi	a3,a3,-68 # ffffffffc0201a68 <etext+0x396>
ffffffffc0200ab4:	00001617          	auipc	a2,0x1
ffffffffc0200ab8:	fbc60613          	addi	a2,a2,-68 # ffffffffc0201a70 <etext+0x39e>
ffffffffc0200abc:	0ec00593          	li	a1,236
ffffffffc0200ac0:	00001517          	auipc	a0,0x1
ffffffffc0200ac4:	fc850513          	addi	a0,a0,-56 # ffffffffc0201a88 <etext+0x3b6>
ffffffffc0200ac8:	f00ff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc0200acc <kmem_cache_create>:
struct kmem_cache *kmem_cache_create(const char *name, size_t size) {
ffffffffc0200acc:	1141                	addi	sp,sp,-16
ffffffffc0200ace:	e022                	sd	s0,0(sp)
    strncpy(cache->name, name, SLUB_NAME_LEN - 1);
ffffffffc0200ad0:	467d                	li	a2,31
struct kmem_cache *kmem_cache_create(const char *name, size_t size) {
ffffffffc0200ad2:	842e                	mv	s0,a1
    strncpy(cache->name, name, SLUB_NAME_LEN - 1);
ffffffffc0200ad4:	85aa                	mv	a1,a0
ffffffffc0200ad6:	00005517          	auipc	a0,0x5
ffffffffc0200ada:	54250513          	addi	a0,a0,1346 # ffffffffc0206018 <cache_storage.0>
struct kmem_cache *kmem_cache_create(const char *name, size_t size) {
ffffffffc0200ade:	e406                	sd	ra,8(sp)
    strncpy(cache->name, name, SLUB_NAME_LEN - 1);
ffffffffc0200ae0:	369000ef          	jal	ffffffffc0201648 <strncpy>
    cache->name[SLUB_NAME_LEN - 1] = '\0';
ffffffffc0200ae4:	00005797          	auipc	a5,0x5
ffffffffc0200ae8:	540789a3          	sb	zero,1363(a5) # ffffffffc0206037 <cache_storage.0+0x1f>
    cache->size = calculate_aligned_size(size);
ffffffffc0200aec:	0004061b          	sext.w	a2,s0
    if (size < 16) return 16;
ffffffffc0200af0:	47bd                	li	a5,15
ffffffffc0200af2:	06c7f763          	bgeu	a5,a2,ffffffffc0200b60 <kmem_cache_create+0x94>
    return (size + 15) & ~15;
ffffffffc0200af6:	263d                	addiw	a2,a2,15
ffffffffc0200af8:	9a41                	andi	a2,a2,-16
    cache->size = calculate_aligned_size(size);
ffffffffc0200afa:	00005597          	auipc	a1,0x5
ffffffffc0200afe:	51e58593          	addi	a1,a1,1310 # ffffffffc0206018 <cache_storage.0>
    cache->objs_per_slab = 1;
ffffffffc0200b02:	4785                	li	a5,1
    elm->prev = elm->next = elm;
ffffffffc0200b04:	00005697          	auipc	a3,0x5
ffffffffc0200b08:	54468693          	addi	a3,a3,1348 # ffffffffc0206048 <cache_storage.0+0x30>
ffffffffc0200b0c:	00005717          	auipc	a4,0x5
ffffffffc0200b10:	54c70713          	addi	a4,a4,1356 # ffffffffc0206058 <cache_storage.0+0x40>
ffffffffc0200b14:	d1dc                	sw	a5,36(a1)
    cprintf("创建SLUB缓存: %s, 对象大小: %u\n", cache->name, cache->size);
ffffffffc0200b16:	00001517          	auipc	a0,0x1
ffffffffc0200b1a:	19250513          	addi	a0,a0,402 # ffffffffc0201ca8 <etext+0x5d6>
ffffffffc0200b1e:	00005797          	auipc	a5,0x5
ffffffffc0200b22:	54a78793          	addi	a5,a5,1354 # ffffffffc0206068 <cache_storage.0+0x50>
    cache->size = calculate_aligned_size(size);
ffffffffc0200b26:	d190                	sw	a2,32(a1)
    cache->order = 0;
ffffffffc0200b28:	00005817          	auipc	a6,0x5
ffffffffc0200b2c:	50083c23          	sd	zero,1304(a6) # ffffffffc0206040 <cache_storage.0+0x28>
    cache->num_slabs = 0;
ffffffffc0200b30:	00005817          	auipc	a6,0x5
ffffffffc0200b34:	54083423          	sd	zero,1352(a6) # ffffffffc0206078 <cache_storage.0+0x60>
    cache->num_free = 0;
ffffffffc0200b38:	00005817          	auipc	a6,0x5
ffffffffc0200b3c:	54082423          	sw	zero,1352(a6) # ffffffffc0206080 <cache_storage.0+0x68>
ffffffffc0200b40:	fd94                	sd	a3,56(a1)
ffffffffc0200b42:	f994                	sd	a3,48(a1)
ffffffffc0200b44:	e5b8                	sd	a4,72(a1)
ffffffffc0200b46:	e1b8                	sd	a4,64(a1)
ffffffffc0200b48:	edbc                	sd	a5,88(a1)
ffffffffc0200b4a:	e9bc                	sd	a5,80(a1)
    cprintf("创建SLUB缓存: %s, 对象大小: %u\n", cache->name, cache->size);
ffffffffc0200b4c:	dfcff0ef          	jal	ffffffffc0200148 <cprintf>
}
ffffffffc0200b50:	60a2                	ld	ra,8(sp)
ffffffffc0200b52:	6402                	ld	s0,0(sp)
ffffffffc0200b54:	00005517          	auipc	a0,0x5
ffffffffc0200b58:	4c450513          	addi	a0,a0,1220 # ffffffffc0206018 <cache_storage.0>
ffffffffc0200b5c:	0141                	addi	sp,sp,16
ffffffffc0200b5e:	8082                	ret
    if (size < 16) return 16;
ffffffffc0200b60:	4641                	li	a2,16
ffffffffc0200b62:	bf61                	j	ffffffffc0200afa <kmem_cache_create+0x2e>

ffffffffc0200b64 <slub_init>:
static void slub_init(void) {
ffffffffc0200b64:	715d                	addi	sp,sp,-80
ffffffffc0200b66:	e0a2                	sd	s0,64(sp)
ffffffffc0200b68:	fc26                	sd	s1,56(sp)
ffffffffc0200b6a:	f44e                	sd	s3,40(sp)
ffffffffc0200b6c:	e486                	sd	ra,72(sp)
ffffffffc0200b6e:	f84a                	sd	s2,48(sp)
ffffffffc0200b70:	00005797          	auipc	a5,0x5
ffffffffc0200b74:	55878793          	addi	a5,a5,1368 # ffffffffc02060c8 <free_area>
    cprintf("初始化SLUB内存管理器\n");
ffffffffc0200b78:	00001517          	auipc	a0,0x1
ffffffffc0200b7c:	15850513          	addi	a0,a0,344 # ffffffffc0201cd0 <etext+0x5fe>
    nr_free = 0;
ffffffffc0200b80:	00005717          	auipc	a4,0x5
ffffffffc0200b84:	54072c23          	sw	zero,1368(a4) # ffffffffc02060d8 <free_area+0x10>
ffffffffc0200b88:	e79c                	sd	a5,8(a5)
ffffffffc0200b8a:	e39c                	sd	a5,0(a5)
    cprintf("初始化SLUB内存管理器\n");
ffffffffc0200b8c:	00002417          	auipc	s0,0x2
ffffffffc0200b90:	93440413          	addi	s0,s0,-1740 # ffffffffc02024c0 <cache_sizes>
ffffffffc0200b94:	db4ff0ef          	jal	ffffffffc0200148 <cprintf>
    for (int i = 0; i < sizeof(cache_sizes)/sizeof(cache_sizes[0]); i++) {
ffffffffc0200b98:	00005497          	auipc	s1,0x5
ffffffffc0200b9c:	4f048493          	addi	s1,s1,1264 # ffffffffc0206088 <slub_caches>
ffffffffc0200ba0:	00002997          	auipc	s3,0x2
ffffffffc0200ba4:	94098993          	addi	s3,s3,-1728 # ffffffffc02024e0 <cache_sizes+0x20>
        snprintf(name, SLUB_NAME_LEN, "size-%u", cache_sizes[i]);
ffffffffc0200ba8:	00042903          	lw	s2,0(s0)
ffffffffc0200bac:	00001617          	auipc	a2,0x1
ffffffffc0200bb0:	14460613          	addi	a2,a2,324 # ffffffffc0201cf0 <etext+0x61e>
ffffffffc0200bb4:	02000593          	li	a1,32
ffffffffc0200bb8:	86ca                	mv	a3,s2
ffffffffc0200bba:	850a                	mv	a0,sp
ffffffffc0200bbc:	1f9000ef          	jal	ffffffffc02015b4 <snprintf>
        slub_caches[i] = kmem_cache_create(name, cache_sizes[i]);
ffffffffc0200bc0:	02091593          	slli	a1,s2,0x20
ffffffffc0200bc4:	9181                	srli	a1,a1,0x20
ffffffffc0200bc6:	850a                	mv	a0,sp
ffffffffc0200bc8:	f05ff0ef          	jal	ffffffffc0200acc <kmem_cache_create>
ffffffffc0200bcc:	e088                	sd	a0,0(s1)
            cprintf("成功创建缓存: %s\n", name);
ffffffffc0200bce:	858a                	mv	a1,sp
ffffffffc0200bd0:	00001517          	auipc	a0,0x1
ffffffffc0200bd4:	12850513          	addi	a0,a0,296 # ffffffffc0201cf8 <etext+0x626>
    for (int i = 0; i < sizeof(cache_sizes)/sizeof(cache_sizes[0]); i++) {
ffffffffc0200bd8:	0411                	addi	s0,s0,4
            cprintf("成功创建缓存: %s\n", name);
ffffffffc0200bda:	d6eff0ef          	jal	ffffffffc0200148 <cprintf>
    for (int i = 0; i < sizeof(cache_sizes)/sizeof(cache_sizes[0]); i++) {
ffffffffc0200bde:	04a1                	addi	s1,s1,8
ffffffffc0200be0:	fd3414e3          	bne	s0,s3,ffffffffc0200ba8 <slub_init+0x44>
}
ffffffffc0200be4:	6406                	ld	s0,64(sp)
ffffffffc0200be6:	60a6                	ld	ra,72(sp)
ffffffffc0200be8:	74e2                	ld	s1,56(sp)
ffffffffc0200bea:	7942                	ld	s2,48(sp)
ffffffffc0200bec:	79a2                	ld	s3,40(sp)
    cprintf("SLUB内存管理器初始化完成\n");
ffffffffc0200bee:	00001517          	auipc	a0,0x1
ffffffffc0200bf2:	12250513          	addi	a0,a0,290 # ffffffffc0201d10 <etext+0x63e>
}
ffffffffc0200bf6:	6161                	addi	sp,sp,80
    cprintf("SLUB内存管理器初始化完成\n");
ffffffffc0200bf8:	d50ff06f          	j	ffffffffc0200148 <cprintf>

ffffffffc0200bfc <kmem_cache_alloc>:
void *kmem_cache_alloc(struct kmem_cache *cache) {
ffffffffc0200bfc:	1101                	addi	sp,sp,-32
ffffffffc0200bfe:	ec06                	sd	ra,24(sp)
    if (!cache) {
ffffffffc0200c00:	c941                	beqz	a0,ffffffffc0200c90 <kmem_cache_alloc+0x94>
    cprintf("尝试分配对象，缓存: %s, 当前空闲页面: %u\n", cache->name, nr_free);
ffffffffc0200c02:	00005617          	auipc	a2,0x5
ffffffffc0200c06:	4d662603          	lw	a2,1238(a2) # ffffffffc02060d8 <free_area+0x10>
ffffffffc0200c0a:	85aa                	mv	a1,a0
ffffffffc0200c0c:	e822                	sd	s0,16(sp)
ffffffffc0200c0e:	842a                	mv	s0,a0
ffffffffc0200c10:	00001517          	auipc	a0,0x1
ffffffffc0200c14:	15850513          	addi	a0,a0,344 # ffffffffc0201d68 <etext+0x696>
ffffffffc0200c18:	d30ff0ef          	jal	ffffffffc0200148 <cprintf>
    struct Page *page = alloc_pages(1);
ffffffffc0200c1c:	4505                	li	a0,1
ffffffffc0200c1e:	951ff0ef          	jal	ffffffffc020056e <alloc_pages>
ffffffffc0200c22:	85aa                	mv	a1,a0
    if (!page) {
ffffffffc0200c24:	cd35                	beqz	a0,ffffffffc0200ca0 <kmem_cache_alloc+0xa4>
    cprintf("成功分配页面: %p\n", page);
ffffffffc0200c26:	e42a                	sd	a0,8(sp)
ffffffffc0200c28:	00001517          	auipc	a0,0x1
ffffffffc0200c2c:	1a050513          	addi	a0,a0,416 # ffffffffc0201dc8 <etext+0x6f6>
ffffffffc0200c30:	d18ff0ef          	jal	ffffffffc0200148 <cprintf>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c34:	65a2                	ld	a1,8(sp)
ffffffffc0200c36:	00005717          	auipc	a4,0x5
ffffffffc0200c3a:	4ea73703          	ld	a4,1258(a4) # ffffffffc0206120 <pages>
ffffffffc0200c3e:	ccccd7b7          	lui	a5,0xccccd
ffffffffc0200c42:	ccd78793          	addi	a5,a5,-819 # ffffffffcccccccd <end+0xcac6ba5>
ffffffffc0200c46:	40e58633          	sub	a2,a1,a4
ffffffffc0200c4a:	02079713          	slli	a4,a5,0x20
ffffffffc0200c4e:	97ba                	add	a5,a5,a4
ffffffffc0200c50:	860d                	srai	a2,a2,0x3
ffffffffc0200c52:	02f60633          	mul	a2,a2,a5
ffffffffc0200c56:	00002797          	auipc	a5,0x2
ffffffffc0200c5a:	a1a7b783          	ld	a5,-1510(a5) # ffffffffc0202670 <nbase>
    cprintf("分配对象成功: 缓存=%s, 对象地址=%p\n", cache->name, obj);
ffffffffc0200c5e:	85a2                	mv	a1,s0
ffffffffc0200c60:	00001517          	auipc	a0,0x1
ffffffffc0200c64:	18050513          	addi	a0,a0,384 # ffffffffc0201de0 <etext+0x70e>
ffffffffc0200c68:	963e                	add	a2,a2,a5
    return (void *)(pa + KERNBASE);
ffffffffc0200c6a:	0632                	slli	a2,a2,0xc
ffffffffc0200c6c:	c02007b7          	lui	a5,0xc0200
ffffffffc0200c70:	963e                	add	a2,a2,a5
    cprintf("分配对象成功: 缓存=%s, 对象地址=%p\n", cache->name, obj);
ffffffffc0200c72:	e432                	sd	a2,8(sp)
ffffffffc0200c74:	cd4ff0ef          	jal	ffffffffc0200148 <cprintf>
    cache->num_slabs++;
ffffffffc0200c78:	5038                	lw	a4,96(s0)
    cache->num_objects++;
ffffffffc0200c7a:	507c                	lw	a5,100(s0)
ffffffffc0200c7c:	6622                	ld	a2,8(sp)
    cache->num_slabs++;
ffffffffc0200c7e:	2705                	addiw	a4,a4,1
    cache->num_objects++;
ffffffffc0200c80:	2785                	addiw	a5,a5,1 # ffffffffc0200001 <kern_entry+0x1>
    cache->num_slabs++;
ffffffffc0200c82:	d038                	sw	a4,96(s0)
    cache->num_objects++;
ffffffffc0200c84:	d07c                	sw	a5,100(s0)
ffffffffc0200c86:	6442                	ld	s0,16(sp)
}
ffffffffc0200c88:	60e2                	ld	ra,24(sp)
ffffffffc0200c8a:	8532                	mv	a0,a2
ffffffffc0200c8c:	6105                	addi	sp,sp,32
ffffffffc0200c8e:	8082                	ret
        cprintf("错误: 缓存为NULL\n");
ffffffffc0200c90:	00001517          	auipc	a0,0x1
ffffffffc0200c94:	0c050513          	addi	a0,a0,192 # ffffffffc0201d50 <etext+0x67e>
ffffffffc0200c98:	cb0ff0ef          	jal	ffffffffc0200148 <cprintf>
        return NULL;
ffffffffc0200c9c:	4601                	li	a2,0
ffffffffc0200c9e:	b7ed                	j	ffffffffc0200c88 <kmem_cache_alloc+0x8c>
        cprintf("错误: 分配页面失败\n");
ffffffffc0200ca0:	00001517          	auipc	a0,0x1
ffffffffc0200ca4:	10850513          	addi	a0,a0,264 # ffffffffc0201da8 <etext+0x6d6>
ffffffffc0200ca8:	ca0ff0ef          	jal	ffffffffc0200148 <cprintf>
        return NULL;
ffffffffc0200cac:	4601                	li	a2,0
        cprintf("错误: 分配页面失败\n");
ffffffffc0200cae:	6442                	ld	s0,16(sp)
ffffffffc0200cb0:	bfe1                	j	ffffffffc0200c88 <kmem_cache_alloc+0x8c>

ffffffffc0200cb2 <kmem_cache_free>:
    if (!cache || !obj) {
ffffffffc0200cb2:	cd25                	beqz	a0,ffffffffc0200d2a <kmem_cache_free+0x78>
ffffffffc0200cb4:	c9bd                	beqz	a1,ffffffffc0200d2a <kmem_cache_free+0x78>
void kmem_cache_free(struct kmem_cache *cache, void *obj) {
ffffffffc0200cb6:	1101                	addi	sp,sp,-32
ffffffffc0200cb8:	862e                	mv	a2,a1
ffffffffc0200cba:	e822                	sd	s0,16(sp)
    cprintf("释放对象: 缓存=%s, 对象地址=%p\n", cache->name, obj);
ffffffffc0200cbc:	e42e                	sd	a1,8(sp)
ffffffffc0200cbe:	842a                	mv	s0,a0
ffffffffc0200cc0:	85aa                	mv	a1,a0
ffffffffc0200cc2:	00001517          	auipc	a0,0x1
ffffffffc0200cc6:	16650513          	addi	a0,a0,358 # ffffffffc0201e28 <etext+0x756>
void kmem_cache_free(struct kmem_cache *cache, void *obj) {
ffffffffc0200cca:	ec06                	sd	ra,24(sp)
    cprintf("释放对象: 缓存=%s, 对象地址=%p\n", cache->name, obj);
ffffffffc0200ccc:	c7cff0ef          	jal	ffffffffc0200148 <cprintf>
    return (uintptr_t)kva - KERNBASE;
ffffffffc0200cd0:	6622                	ld	a2,8(sp)
ffffffffc0200cd2:	3fe00737          	lui	a4,0x3fe00
    if (PPN(pa) >= npage) {
ffffffffc0200cd6:	00005797          	auipc	a5,0x5
ffffffffc0200cda:	4427b783          	ld	a5,1090(a5) # ffffffffc0206118 <npage>
ffffffffc0200cde:	963a                	add	a2,a2,a4
ffffffffc0200ce0:	8231                	srli	a2,a2,0xc
ffffffffc0200ce2:	06f67363          	bgeu	a2,a5,ffffffffc0200d48 <kmem_cache_free+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0200ce6:	00002797          	auipc	a5,0x2
ffffffffc0200cea:	98a7b783          	ld	a5,-1654(a5) # ffffffffc0202670 <nbase>
ffffffffc0200cee:	00005517          	auipc	a0,0x5
ffffffffc0200cf2:	43253503          	ld	a0,1074(a0) # ffffffffc0206120 <pages>
ffffffffc0200cf6:	8e1d                	sub	a2,a2,a5
ffffffffc0200cf8:	00261793          	slli	a5,a2,0x2
ffffffffc0200cfc:	97b2                	add	a5,a5,a2
ffffffffc0200cfe:	078e                	slli	a5,a5,0x3
ffffffffc0200d00:	953e                	add	a0,a0,a5
    if (!page) {
ffffffffc0200d02:	c915                	beqz	a0,ffffffffc0200d36 <kmem_cache_free+0x84>
    free_pages(page, 1);
ffffffffc0200d04:	4585                	li	a1,1
ffffffffc0200d06:	875ff0ef          	jal	ffffffffc020057a <free_pages>
    cprintf("成功释放页面\n");
ffffffffc0200d0a:	00001517          	auipc	a0,0x1
ffffffffc0200d0e:	17650513          	addi	a0,a0,374 # ffffffffc0201e80 <etext+0x7ae>
ffffffffc0200d12:	c36ff0ef          	jal	ffffffffc0200148 <cprintf>
    cache->num_slabs--;
ffffffffc0200d16:	5038                	lw	a4,96(s0)
    cache->num_objects--;
ffffffffc0200d18:	507c                	lw	a5,100(s0)
}
ffffffffc0200d1a:	60e2                	ld	ra,24(sp)
    cache->num_slabs--;
ffffffffc0200d1c:	377d                	addiw	a4,a4,-1 # 3fdfffff <kern_entry-0xffffffff80400001>
    cache->num_objects--;
ffffffffc0200d1e:	37fd                	addiw	a5,a5,-1
    cache->num_slabs--;
ffffffffc0200d20:	d038                	sw	a4,96(s0)
    cache->num_objects--;
ffffffffc0200d22:	d07c                	sw	a5,100(s0)
}
ffffffffc0200d24:	6442                	ld	s0,16(sp)
ffffffffc0200d26:	6105                	addi	sp,sp,32
ffffffffc0200d28:	8082                	ret
        cprintf("错误: 参数无效\n");
ffffffffc0200d2a:	00001517          	auipc	a0,0x1
ffffffffc0200d2e:	0e650513          	addi	a0,a0,230 # ffffffffc0201e10 <etext+0x73e>
ffffffffc0200d32:	c16ff06f          	j	ffffffffc0200148 <cprintf>
}
ffffffffc0200d36:	6442                	ld	s0,16(sp)
ffffffffc0200d38:	60e2                	ld	ra,24(sp)
        cprintf("错误: 找不到对应的页面\n");
ffffffffc0200d3a:	00001517          	auipc	a0,0x1
ffffffffc0200d3e:	11e50513          	addi	a0,a0,286 # ffffffffc0201e58 <etext+0x786>
}
ffffffffc0200d42:	6105                	addi	sp,sp,32
        cprintf("错误: 找不到对应的页面\n");
ffffffffc0200d44:	c04ff06f          	j	ffffffffc0200148 <cprintf>
        panic("pa2page called with invalid pa");
ffffffffc0200d48:	00001617          	auipc	a2,0x1
ffffffffc0200d4c:	c9060613          	addi	a2,a2,-880 # ffffffffc02019d8 <etext+0x306>
ffffffffc0200d50:	06a00593          	li	a1,106
ffffffffc0200d54:	00001517          	auipc	a0,0x1
ffffffffc0200d58:	ca450513          	addi	a0,a0,-860 # ffffffffc02019f8 <etext+0x326>
ffffffffc0200d5c:	c6cff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc0200d60 <kmalloc>:
void *kmalloc(size_t size) {
ffffffffc0200d60:	1101                	addi	sp,sp,-32
ffffffffc0200d62:	ec06                	sd	ra,24(sp)
ffffffffc0200d64:	e822                	sd	s0,16(sp)
    if (size == 0) {
ffffffffc0200d66:	c555                	beqz	a0,ffffffffc0200e12 <kmalloc+0xb2>
    cprintf("kmalloc: 请求大小 %u\n", size);
ffffffffc0200d68:	85aa                	mv	a1,a0
ffffffffc0200d6a:	842a                	mv	s0,a0
ffffffffc0200d6c:	00001517          	auipc	a0,0x1
ffffffffc0200d70:	14c50513          	addi	a0,a0,332 # ffffffffc0201eb8 <etext+0x7e6>
ffffffffc0200d74:	bd4ff0ef          	jal	ffffffffc0200148 <cprintf>
    for (int i = 0; i < sizeof(cache_sizes)/sizeof(cache_sizes[0]); i++) {
ffffffffc0200d78:	00005697          	auipc	a3,0x5
ffffffffc0200d7c:	31068693          	addi	a3,a3,784 # ffffffffc0206088 <slub_caches>
ffffffffc0200d80:	00001717          	auipc	a4,0x1
ffffffffc0200d84:	74070713          	addi	a4,a4,1856 # ffffffffc02024c0 <cache_sizes>
ffffffffc0200d88:	4781                	li	a5,0
ffffffffc0200d8a:	45a1                	li	a1,8
        if (size <= cache_sizes[i]) {
ffffffffc0200d8c:	4310                	lw	a2,0(a4)
    for (int i = 0; i < sizeof(cache_sizes)/sizeof(cache_sizes[0]); i++) {
ffffffffc0200d8e:	0711                	addi	a4,a4,4
        if (size <= cache_sizes[i]) {
ffffffffc0200d90:	02061513          	slli	a0,a2,0x20
ffffffffc0200d94:	9101                	srli	a0,a0,0x20
ffffffffc0200d96:	00856463          	bltu	a0,s0,ffffffffc0200d9e <kmalloc+0x3e>
            if (slub_caches[i]) {
ffffffffc0200d9a:	6288                	ld	a0,0(a3)
ffffffffc0200d9c:	ed59                	bnez	a0,ffffffffc0200e3a <kmalloc+0xda>
    for (int i = 0; i < sizeof(cache_sizes)/sizeof(cache_sizes[0]); i++) {
ffffffffc0200d9e:	2785                	addiw	a5,a5,1
ffffffffc0200da0:	06a1                	addi	a3,a3,8
ffffffffc0200da2:	feb795e3          	bne	a5,a1,ffffffffc0200d8c <kmalloc+0x2c>
    cprintf("没有合适的缓存，使用页面分配\n");
ffffffffc0200da6:	00001517          	auipc	a0,0x1
ffffffffc0200daa:	14a50513          	addi	a0,a0,330 # ffffffffc0201ef0 <etext+0x81e>
ffffffffc0200dae:	b9aff0ef          	jal	ffffffffc0200148 <cprintf>
    unsigned int pages = (size + PGSIZE - 1) / PGSIZE;
ffffffffc0200db2:	6785                	lui	a5,0x1
ffffffffc0200db4:	17fd                	addi	a5,a5,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0200db6:	00f40533          	add	a0,s0,a5
    struct Page *page = alloc_pages(pages);
ffffffffc0200dba:	01451793          	slli	a5,a0,0x14
ffffffffc0200dbe:	0207d513          	srli	a0,a5,0x20
ffffffffc0200dc2:	facff0ef          	jal	ffffffffc020056e <alloc_pages>
    if (page) {
ffffffffc0200dc6:	c135                	beqz	a0,ffffffffc0200e2a <kmalloc+0xca>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200dc8:	00005697          	auipc	a3,0x5
ffffffffc0200dcc:	3586b683          	ld	a3,856(a3) # ffffffffc0206120 <pages>
ffffffffc0200dd0:	ccccd7b7          	lui	a5,0xccccd
ffffffffc0200dd4:	ccd78793          	addi	a5,a5,-819 # ffffffffcccccccd <end+0xcac6ba5>
ffffffffc0200dd8:	40d50433          	sub	s0,a0,a3
ffffffffc0200ddc:	02079713          	slli	a4,a5,0x20
ffffffffc0200de0:	973e                	add	a4,a4,a5
ffffffffc0200de2:	840d                	srai	s0,s0,0x3
ffffffffc0200de4:	02e40433          	mul	s0,s0,a4
ffffffffc0200de8:	00002797          	auipc	a5,0x2
ffffffffc0200dec:	8887b783          	ld	a5,-1912(a5) # ffffffffc0202670 <nbase>
        cprintf("页面分配成功: %p\n", obj);
ffffffffc0200df0:	00001517          	auipc	a0,0x1
ffffffffc0200df4:	13050513          	addi	a0,a0,304 # ffffffffc0201f20 <etext+0x84e>
ffffffffc0200df8:	943e                	add	s0,s0,a5
    return (void *)(pa + KERNBASE);
ffffffffc0200dfa:	0432                	slli	s0,s0,0xc
ffffffffc0200dfc:	c02007b7          	lui	a5,0xc0200
ffffffffc0200e00:	943e                	add	s0,s0,a5
        cprintf("页面分配成功: %p\n", obj);
ffffffffc0200e02:	85a2                	mv	a1,s0
ffffffffc0200e04:	b44ff0ef          	jal	ffffffffc0200148 <cprintf>
}
ffffffffc0200e08:	60e2                	ld	ra,24(sp)
ffffffffc0200e0a:	8522                	mv	a0,s0
ffffffffc0200e0c:	6442                	ld	s0,16(sp)
ffffffffc0200e0e:	6105                	addi	sp,sp,32
ffffffffc0200e10:	8082                	ret
        cprintf("kmalloc: 请求大小为0\n");
ffffffffc0200e12:	00001517          	auipc	a0,0x1
ffffffffc0200e16:	08650513          	addi	a0,a0,134 # ffffffffc0201e98 <etext+0x7c6>
ffffffffc0200e1a:	b2eff0ef          	jal	ffffffffc0200148 <cprintf>
        return NULL;
ffffffffc0200e1e:	4401                	li	s0,0
}
ffffffffc0200e20:	60e2                	ld	ra,24(sp)
ffffffffc0200e22:	8522                	mv	a0,s0
ffffffffc0200e24:	6442                	ld	s0,16(sp)
ffffffffc0200e26:	6105                	addi	sp,sp,32
ffffffffc0200e28:	8082                	ret
    cprintf("页面分配失败\n");
ffffffffc0200e2a:	00001517          	auipc	a0,0x1
ffffffffc0200e2e:	10e50513          	addi	a0,a0,270 # ffffffffc0201f38 <etext+0x866>
ffffffffc0200e32:	b16ff0ef          	jal	ffffffffc0200148 <cprintf>
        return NULL;
ffffffffc0200e36:	4401                	li	s0,0
ffffffffc0200e38:	b7e5                	j	ffffffffc0200e20 <kmalloc+0xc0>
                cprintf("使用缓存: size-%u\n", cache_sizes[i]);
ffffffffc0200e3a:	85b2                	mv	a1,a2
ffffffffc0200e3c:	00001517          	auipc	a0,0x1
ffffffffc0200e40:	09c50513          	addi	a0,a0,156 # ffffffffc0201ed8 <etext+0x806>
ffffffffc0200e44:	e43e                	sd	a5,8(sp)
ffffffffc0200e46:	b02ff0ef          	jal	ffffffffc0200148 <cprintf>
                return kmem_cache_alloc(slub_caches[i]);
ffffffffc0200e4a:	67a2                	ld	a5,8(sp)
ffffffffc0200e4c:	00005817          	auipc	a6,0x5
ffffffffc0200e50:	23c80813          	addi	a6,a6,572 # ffffffffc0206088 <slub_caches>
}
ffffffffc0200e54:	6442                	ld	s0,16(sp)
                return kmem_cache_alloc(slub_caches[i]);
ffffffffc0200e56:	078e                	slli	a5,a5,0x3
ffffffffc0200e58:	983e                	add	a6,a6,a5
}
ffffffffc0200e5a:	60e2                	ld	ra,24(sp)
                return kmem_cache_alloc(slub_caches[i]);
ffffffffc0200e5c:	00083503          	ld	a0,0(a6)
}
ffffffffc0200e60:	6105                	addi	sp,sp,32
                return kmem_cache_alloc(slub_caches[i]);
ffffffffc0200e62:	bb69                	j	ffffffffc0200bfc <kmem_cache_alloc>

ffffffffc0200e64 <kfree>:
    if (!obj) {
ffffffffc0200e64:	c93d                	beqz	a0,ffffffffc0200eda <kfree+0x76>
void kfree(void *obj) {
ffffffffc0200e66:	1101                	addi	sp,sp,-32
ffffffffc0200e68:	85aa                	mv	a1,a0
    cprintf("kfree: 释放对象 %p\n", obj);
ffffffffc0200e6a:	e42a                	sd	a0,8(sp)
ffffffffc0200e6c:	00001517          	auipc	a0,0x1
ffffffffc0200e70:	0fc50513          	addi	a0,a0,252 # ffffffffc0201f68 <etext+0x896>
void kfree(void *obj) {
ffffffffc0200e74:	ec06                	sd	ra,24(sp)
    cprintf("kfree: 释放对象 %p\n", obj);
ffffffffc0200e76:	ad2ff0ef          	jal	ffffffffc0200148 <cprintf>
    if (slub_caches[0]) {
ffffffffc0200e7a:	00005517          	auipc	a0,0x5
ffffffffc0200e7e:	20e53503          	ld	a0,526(a0) # ffffffffc0206088 <slub_caches>
ffffffffc0200e82:	65a2                	ld	a1,8(sp)
ffffffffc0200e84:	c501                	beqz	a0,ffffffffc0200e8c <kfree+0x28>
}
ffffffffc0200e86:	60e2                	ld	ra,24(sp)
ffffffffc0200e88:	6105                	addi	sp,sp,32
        kmem_cache_free(slub_caches[0], obj);
ffffffffc0200e8a:	b525                	j	ffffffffc0200cb2 <kmem_cache_free>
    return (uintptr_t)kva - KERNBASE;
ffffffffc0200e8c:	3fe00737          	lui	a4,0x3fe00
    if (PPN(pa) >= npage) {
ffffffffc0200e90:	00005797          	auipc	a5,0x5
ffffffffc0200e94:	2887b783          	ld	a5,648(a5) # ffffffffc0206118 <npage>
ffffffffc0200e98:	95ba                	add	a1,a1,a4
ffffffffc0200e9a:	81b1                	srli	a1,a1,0xc
ffffffffc0200e9c:	04f5f563          	bgeu	a1,a5,ffffffffc0200ee6 <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc0200ea0:	00001797          	auipc	a5,0x1
ffffffffc0200ea4:	7d07b783          	ld	a5,2000(a5) # ffffffffc0202670 <nbase>
ffffffffc0200ea8:	00005517          	auipc	a0,0x5
ffffffffc0200eac:	27853503          	ld	a0,632(a0) # ffffffffc0206120 <pages>
ffffffffc0200eb0:	8d9d                	sub	a1,a1,a5
ffffffffc0200eb2:	00259793          	slli	a5,a1,0x2
ffffffffc0200eb6:	97ae                	add	a5,a5,a1
ffffffffc0200eb8:	078e                	slli	a5,a5,0x3
ffffffffc0200eba:	953e                	add	a0,a0,a5
        if (page) {
ffffffffc0200ebc:	cd01                	beqz	a0,ffffffffc0200ed4 <kfree+0x70>
            free_pages(page, 1);
ffffffffc0200ebe:	4585                	li	a1,1
ffffffffc0200ec0:	ebaff0ef          	jal	ffffffffc020057a <free_pages>
}
ffffffffc0200ec4:	60e2                	ld	ra,24(sp)
            cprintf("页面释放成功\n");
ffffffffc0200ec6:	00001517          	auipc	a0,0x1
ffffffffc0200eca:	0ba50513          	addi	a0,a0,186 # ffffffffc0201f80 <etext+0x8ae>
}
ffffffffc0200ece:	6105                	addi	sp,sp,32
            cprintf("页面释放成功\n");
ffffffffc0200ed0:	a78ff06f          	j	ffffffffc0200148 <cprintf>
}
ffffffffc0200ed4:	60e2                	ld	ra,24(sp)
ffffffffc0200ed6:	6105                	addi	sp,sp,32
ffffffffc0200ed8:	8082                	ret
        cprintf("kfree: 对象为NULL\n");
ffffffffc0200eda:	00001517          	auipc	a0,0x1
ffffffffc0200ede:	07650513          	addi	a0,a0,118 # ffffffffc0201f50 <etext+0x87e>
ffffffffc0200ee2:	a66ff06f          	j	ffffffffc0200148 <cprintf>
        panic("pa2page called with invalid pa");
ffffffffc0200ee6:	00001617          	auipc	a2,0x1
ffffffffc0200eea:	af260613          	addi	a2,a2,-1294 # ffffffffc02019d8 <etext+0x306>
ffffffffc0200eee:	06a00593          	li	a1,106
ffffffffc0200ef2:	00001517          	auipc	a0,0x1
ffffffffc0200ef6:	b0650513          	addi	a0,a0,-1274 # ffffffffc02019f8 <etext+0x326>
ffffffffc0200efa:	aceff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc0200efe <slub_check>:

// SLUB 特定测试
static void slub_check(void) {
ffffffffc0200efe:	1101                	addi	sp,sp,-32
    cprintf("\n=== 开始SLUB分配器测试 ===\n");
ffffffffc0200f00:	00001517          	auipc	a0,0x1
ffffffffc0200f04:	09850513          	addi	a0,a0,152 # ffffffffc0201f98 <etext+0x8c6>
static void slub_check(void) {
ffffffffc0200f08:	ec06                	sd	ra,24(sp)
ffffffffc0200f0a:	e822                	sd	s0,16(sp)
ffffffffc0200f0c:	e426                	sd	s1,8(sp)
ffffffffc0200f0e:	e04a                	sd	s2,0(sp)
    cprintf("\n=== 开始SLUB分配器测试 ===\n");
ffffffffc0200f10:	a38ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("测试前系统空闲页面: %u\n", nr_free);
ffffffffc0200f14:	00005597          	auipc	a1,0x5
ffffffffc0200f18:	1c45a583          	lw	a1,452(a1) # ffffffffc02060d8 <free_area+0x10>
ffffffffc0200f1c:	00001517          	auipc	a0,0x1
ffffffffc0200f20:	0a450513          	addi	a0,a0,164 # ffffffffc0201fc0 <etext+0x8ee>
ffffffffc0200f24:	a24ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    // 测试1: 基本页面分配（不通过SLUB）
    cprintf("\n测试1: 基本页面分配\n");
ffffffffc0200f28:	00001517          	auipc	a0,0x1
ffffffffc0200f2c:	0c050513          	addi	a0,a0,192 # ffffffffc0201fe8 <etext+0x916>
ffffffffc0200f30:	a18ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("测试直接页面分配...\n");
ffffffffc0200f34:	00001517          	auipc	a0,0x1
ffffffffc0200f38:	0d450513          	addi	a0,a0,212 # ffffffffc0202008 <etext+0x936>
ffffffffc0200f3c:	a0cff0ef          	jal	ffffffffc0200148 <cprintf>
    
    struct Page *test_page = alloc_pages(1);
ffffffffc0200f40:	4505                	li	a0,1
ffffffffc0200f42:	e2cff0ef          	jal	ffffffffc020056e <alloc_pages>
    if (test_page) {
ffffffffc0200f46:	26050263          	beqz	a0,ffffffffc02011aa <slub_check+0x2ac>
        cprintf("基本页面分配成功: %p\n", test_page);
ffffffffc0200f4a:	842a                	mv	s0,a0
ffffffffc0200f4c:	85aa                	mv	a1,a0
ffffffffc0200f4e:	00001517          	auipc	a0,0x1
ffffffffc0200f52:	0da50513          	addi	a0,a0,218 # ffffffffc0202028 <etext+0x956>
ffffffffc0200f56:	9f2ff0ef          	jal	ffffffffc0200148 <cprintf>
        free_pages(test_page, 1);
ffffffffc0200f5a:	4585                	li	a1,1
ffffffffc0200f5c:	8522                	mv	a0,s0
ffffffffc0200f5e:	e1cff0ef          	jal	ffffffffc020057a <free_pages>
        cprintf("基本页面释放成功\n");
ffffffffc0200f62:	00001517          	auipc	a0,0x1
ffffffffc0200f66:	0e650513          	addi	a0,a0,230 # ffffffffc0202048 <etext+0x976>
ffffffffc0200f6a:	9deff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("测试1 通过\n");
ffffffffc0200f6e:	00001517          	auipc	a0,0x1
ffffffffc0200f72:	0fa50513          	addi	a0,a0,250 # ffffffffc0202068 <etext+0x996>
ffffffffc0200f76:	9d2ff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("错误: 基本页面分配失败\n");
        panic("基本功能测试失败");
    }
    
    // 测试2: 基本缓存操作
    cprintf("\n测试2: 基本缓存操作\n");
ffffffffc0200f7a:	00001517          	auipc	a0,0x1
ffffffffc0200f7e:	0fe50513          	addi	a0,a0,254 # ffffffffc0202078 <etext+0x9a6>
ffffffffc0200f82:	9c6ff0ef          	jal	ffffffffc0200148 <cprintf>
    struct kmem_cache *test_cache = kmem_cache_create("test-cache", 64);
ffffffffc0200f86:	04000593          	li	a1,64
ffffffffc0200f8a:	00001517          	auipc	a0,0x1
ffffffffc0200f8e:	10e50513          	addi	a0,a0,270 # ffffffffc0202098 <etext+0x9c6>
ffffffffc0200f92:	b3bff0ef          	jal	ffffffffc0200acc <kmem_cache_create>
ffffffffc0200f96:	842a                	mv	s0,a0
    assert(test_cache != NULL);
    
    cprintf("创建测试缓存成功，开始分配对象...\n");
ffffffffc0200f98:	00001517          	auipc	a0,0x1
ffffffffc0200f9c:	11050513          	addi	a0,a0,272 # ffffffffc02020a8 <etext+0x9d6>
ffffffffc0200fa0:	9a8ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    void *obj1 = kmem_cache_alloc(test_cache);
ffffffffc0200fa4:	8522                	mv	a0,s0
ffffffffc0200fa6:	c57ff0ef          	jal	ffffffffc0200bfc <kmem_cache_alloc>
    cprintf("第一次分配结果: %p\n", obj1);
ffffffffc0200faa:	85aa                	mv	a1,a0
    void *obj1 = kmem_cache_alloc(test_cache);
ffffffffc0200fac:	892a                	mv	s2,a0
    cprintf("第一次分配结果: %p\n", obj1);
ffffffffc0200fae:	00001517          	auipc	a0,0x1
ffffffffc0200fb2:	13250513          	addi	a0,a0,306 # ffffffffc02020e0 <etext+0xa0e>
ffffffffc0200fb6:	992ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    void *obj2 = kmem_cache_alloc(test_cache);
ffffffffc0200fba:	8522                	mv	a0,s0
ffffffffc0200fbc:	c41ff0ef          	jal	ffffffffc0200bfc <kmem_cache_alloc>
ffffffffc0200fc0:	84aa                	mv	s1,a0
    cprintf("第二次分配结果: %p\n", obj2);
ffffffffc0200fc2:	85aa                	mv	a1,a0
ffffffffc0200fc4:	00001517          	auipc	a0,0x1
ffffffffc0200fc8:	13c50513          	addi	a0,a0,316 # ffffffffc0202100 <etext+0xa2e>
ffffffffc0200fcc:	97cff0ef          	jal	ffffffffc0200148 <cprintf>
    
    if (obj1 == NULL || obj2 == NULL) {
ffffffffc0200fd0:	1a090163          	beqz	s2,ffffffffc0201172 <slub_check+0x274>
ffffffffc0200fd4:	18048f63          	beqz	s1,ffffffffc0201172 <slub_check+0x274>
    }
    
    assert(obj1 != NULL);
    assert(obj2 != NULL);
    
    cprintf("成功分配两个对象\n");
ffffffffc0200fd8:	00001517          	auipc	a0,0x1
ffffffffc0200fdc:	1e050513          	addi	a0,a0,480 # ffffffffc02021b8 <etext+0xae6>
ffffffffc0200fe0:	968ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("分配后空闲页面: %u\n", nr_free);
ffffffffc0200fe4:	00005597          	auipc	a1,0x5
ffffffffc0200fe8:	0f45a583          	lw	a1,244(a1) # ffffffffc02060d8 <free_area+0x10>
ffffffffc0200fec:	00001517          	auipc	a0,0x1
ffffffffc0200ff0:	1ec50513          	addi	a0,a0,492 # ffffffffc02021d8 <etext+0xb06>
ffffffffc0200ff4:	954ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    kmem_cache_free(test_cache, obj1);
ffffffffc0200ff8:	85ca                	mv	a1,s2
ffffffffc0200ffa:	8522                	mv	a0,s0
ffffffffc0200ffc:	cb7ff0ef          	jal	ffffffffc0200cb2 <kmem_cache_free>
    kmem_cache_free(test_cache, obj2);
ffffffffc0201000:	85a6                	mv	a1,s1
ffffffffc0201002:	8522                	mv	a0,s0
ffffffffc0201004:	cafff0ef          	jal	ffffffffc0200cb2 <kmem_cache_free>
    cprintf("成功释放两个对象\n");
ffffffffc0201008:	00001517          	auipc	a0,0x1
ffffffffc020100c:	1f050513          	addi	a0,a0,496 # ffffffffc02021f8 <etext+0xb26>
ffffffffc0201010:	938ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("释放后空闲页面: %u\n", nr_free);
ffffffffc0201014:	00005597          	auipc	a1,0x5
ffffffffc0201018:	0c45a583          	lw	a1,196(a1) # ffffffffc02060d8 <free_area+0x10>
ffffffffc020101c:	00001517          	auipc	a0,0x1
ffffffffc0201020:	1fc50513          	addi	a0,a0,508 # ffffffffc0202218 <etext+0xb46>
ffffffffc0201024:	924ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("销毁SLUB缓存: %s\n", cache->name);
ffffffffc0201028:	85a2                	mv	a1,s0
ffffffffc020102a:	00001517          	auipc	a0,0x1
ffffffffc020102e:	d0e50513          	addi	a0,a0,-754 # ffffffffc0201d38 <etext+0x666>
ffffffffc0201032:	916ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    kmem_cache_destroy(test_cache);
    cprintf("测试2 通过\n");
ffffffffc0201036:	00001517          	auipc	a0,0x1
ffffffffc020103a:	20250513          	addi	a0,a0,514 # ffffffffc0202238 <etext+0xb66>
ffffffffc020103e:	90aff0ef          	jal	ffffffffc0200148 <cprintf>
    
    // 测试3: 通用内存分配
    cprintf("\n测试3: 通用内存分配\n");
ffffffffc0201042:	00001517          	auipc	a0,0x1
ffffffffc0201046:	20650513          	addi	a0,a0,518 # ffffffffc0202248 <etext+0xb76>
ffffffffc020104a:	8feff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("测试前空闲页面: %u\n", nr_free);
ffffffffc020104e:	00005597          	auipc	a1,0x5
ffffffffc0201052:	08a5a583          	lw	a1,138(a1) # ffffffffc02060d8 <free_area+0x10>
ffffffffc0201056:	00001517          	auipc	a0,0x1
ffffffffc020105a:	21250513          	addi	a0,a0,530 # ffffffffc0202268 <etext+0xb96>
ffffffffc020105e:	8eaff0ef          	jal	ffffffffc0200148 <cprintf>
    
    void *mem1 = kmalloc(32);
ffffffffc0201062:	02000513          	li	a0,32
ffffffffc0201066:	cfbff0ef          	jal	ffffffffc0200d60 <kmalloc>
ffffffffc020106a:	84aa                	mv	s1,a0
    void *mem2 = kmalloc(128);
ffffffffc020106c:	08000513          	li	a0,128
ffffffffc0201070:	cf1ff0ef          	jal	ffffffffc0200d60 <kmalloc>
ffffffffc0201074:	842a                	mv	s0,a0
    void *mem3 = kmalloc(512);
ffffffffc0201076:	20000513          	li	a0,512
ffffffffc020107a:	ce7ff0ef          	jal	ffffffffc0200d60 <kmalloc>
    
    cprintf("分配结果: mem1=%p, mem2=%p, mem3=%p\n", mem1, mem2, mem3);
ffffffffc020107e:	86aa                	mv	a3,a0
ffffffffc0201080:	8622                	mv	a2,s0
ffffffffc0201082:	85a6                	mv	a1,s1
    void *mem3 = kmalloc(512);
ffffffffc0201084:	892a                	mv	s2,a0
    cprintf("分配结果: mem1=%p, mem2=%p, mem3=%p\n", mem1, mem2, mem3);
ffffffffc0201086:	00001517          	auipc	a0,0x1
ffffffffc020108a:	20250513          	addi	a0,a0,514 # ffffffffc0202288 <etext+0xbb6>
ffffffffc020108e:	8baff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("分配后空闲页面: %u\n", nr_free);
ffffffffc0201092:	00005597          	auipc	a1,0x5
ffffffffc0201096:	0465a583          	lw	a1,70(a1) # ffffffffc02060d8 <free_area+0x10>
ffffffffc020109a:	00001517          	auipc	a0,0x1
ffffffffc020109e:	13e50513          	addi	a0,a0,318 # ffffffffc02021d8 <etext+0xb06>
ffffffffc02010a2:	8a6ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    if (mem1 == NULL || mem2 == NULL || mem3 == NULL) {
ffffffffc02010a6:	0014b793          	seqz	a5,s1
ffffffffc02010aa:	00143713          	seqz	a4,s0
ffffffffc02010ae:	8fd9                	or	a5,a5,a4
ffffffffc02010b0:	efd9                	bnez	a5,ffffffffc020114e <slub_check+0x250>
ffffffffc02010b2:	08090e63          	beqz	s2,ffffffffc020114e <slub_check+0x250>
    
    assert(mem1 != NULL);
    assert(mem2 != NULL); 
    assert(mem3 != NULL);
    
    cprintf("通用分配测试通过\n");
ffffffffc02010b6:	00001517          	auipc	a0,0x1
ffffffffc02010ba:	22250513          	addi	a0,a0,546 # ffffffffc02022d8 <etext+0xc06>
ffffffffc02010be:	88aff0ef          	jal	ffffffffc0200148 <cprintf>
    
    kfree(mem1);
ffffffffc02010c2:	8526                	mv	a0,s1
ffffffffc02010c4:	da1ff0ef          	jal	ffffffffc0200e64 <kfree>
    kfree(mem2);
ffffffffc02010c8:	8522                	mv	a0,s0
ffffffffc02010ca:	d9bff0ef          	jal	ffffffffc0200e64 <kfree>
    kfree(mem3);
ffffffffc02010ce:	854a                	mv	a0,s2
ffffffffc02010d0:	d95ff0ef          	jal	ffffffffc0200e64 <kfree>
    cprintf("释放后空闲页面: %u\n", nr_free);
ffffffffc02010d4:	00005597          	auipc	a1,0x5
ffffffffc02010d8:	0045a583          	lw	a1,4(a1) # ffffffffc02060d8 <free_area+0x10>
ffffffffc02010dc:	00001517          	auipc	a0,0x1
ffffffffc02010e0:	13c50513          	addi	a0,a0,316 # ffffffffc0202218 <etext+0xb46>
ffffffffc02010e4:	864ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("测试3 通过\n");
ffffffffc02010e8:	00001517          	auipc	a0,0x1
ffffffffc02010ec:	21050513          	addi	a0,a0,528 # ffffffffc02022f8 <etext+0xc26>
ffffffffc02010f0:	858ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    // 测试4: 边界情况
    cprintf("\n测试4: 边界情况\n");
ffffffffc02010f4:	00001517          	auipc	a0,0x1
ffffffffc02010f8:	21450513          	addi	a0,a0,532 # ffffffffc0202308 <etext+0xc36>
ffffffffc02010fc:	84cff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("kmalloc: 请求大小为0\n");
ffffffffc0201100:	00001517          	auipc	a0,0x1
ffffffffc0201104:	d9850513          	addi	a0,a0,-616 # ffffffffc0201e98 <etext+0x7c6>
ffffffffc0201108:	840ff0ef          	jal	ffffffffc0200148 <cprintf>
    void *null_obj = kmalloc(0);
    assert(null_obj == NULL);
    cprintf("零大小分配正确返回NULL\n");
ffffffffc020110c:	00001517          	auipc	a0,0x1
ffffffffc0201110:	21450513          	addi	a0,a0,532 # ffffffffc0202320 <etext+0xc4e>
ffffffffc0201114:	834ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    cprintf("测试4 通过\n");
ffffffffc0201118:	00001517          	auipc	a0,0x1
ffffffffc020111c:	23050513          	addi	a0,a0,560 # ffffffffc0202348 <etext+0xc76>
ffffffffc0201120:	828ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    cprintf("\n=== 所有SLUB测试通过 ===\n");
ffffffffc0201124:	00001517          	auipc	a0,0x1
ffffffffc0201128:	23450513          	addi	a0,a0,564 # ffffffffc0202358 <etext+0xc86>
ffffffffc020112c:	81cff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("最终空闲页面: %u\n", nr_free);
}
ffffffffc0201130:	6442                	ld	s0,16(sp)
ffffffffc0201132:	60e2                	ld	ra,24(sp)
ffffffffc0201134:	64a2                	ld	s1,8(sp)
ffffffffc0201136:	6902                	ld	s2,0(sp)
    cprintf("最终空闲页面: %u\n", nr_free);
ffffffffc0201138:	00005597          	auipc	a1,0x5
ffffffffc020113c:	fa05a583          	lw	a1,-96(a1) # ffffffffc02060d8 <free_area+0x10>
ffffffffc0201140:	00001517          	auipc	a0,0x1
ffffffffc0201144:	24050513          	addi	a0,a0,576 # ffffffffc0202380 <etext+0xcae>
}
ffffffffc0201148:	6105                	addi	sp,sp,32
    cprintf("最终空闲页面: %u\n", nr_free);
ffffffffc020114a:	ffffe06f          	j	ffffffffc0200148 <cprintf>
        cprintf("错误: 通用分配失败\n");
ffffffffc020114e:	00001517          	auipc	a0,0x1
ffffffffc0201152:	16a50513          	addi	a0,a0,362 # ffffffffc02022b8 <etext+0xbe6>
ffffffffc0201156:	ff3fe0ef          	jal	ffffffffc0200148 <cprintf>
        panic("SLUB测试失败");
ffffffffc020115a:	00001617          	auipc	a2,0x1
ffffffffc020115e:	04660613          	addi	a2,a2,70 # ffffffffc02021a0 <etext+0xace>
ffffffffc0201162:	1a200593          	li	a1,418
ffffffffc0201166:	00001517          	auipc	a0,0x1
ffffffffc020116a:	92250513          	addi	a0,a0,-1758 # ffffffffc0201a88 <etext+0x3b6>
ffffffffc020116e:	85aff0ef          	jal	ffffffffc02001c8 <__panic>
        cprintf("错误: 对象分配失败\n");
ffffffffc0201172:	00001517          	auipc	a0,0x1
ffffffffc0201176:	ff650513          	addi	a0,a0,-10 # ffffffffc0202168 <etext+0xa96>
ffffffffc020117a:	fcffe0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("当前空闲页面: %u\n", nr_free);
ffffffffc020117e:	00005597          	auipc	a1,0x5
ffffffffc0201182:	f5a5a583          	lw	a1,-166(a1) # ffffffffc02060d8 <free_area+0x10>
ffffffffc0201186:	00001517          	auipc	a0,0x1
ffffffffc020118a:	00250513          	addi	a0,a0,2 # ffffffffc0202188 <etext+0xab6>
ffffffffc020118e:	fbbfe0ef          	jal	ffffffffc0200148 <cprintf>
        panic("SLUB测试失败");
ffffffffc0201192:	00001617          	auipc	a2,0x1
ffffffffc0201196:	00e60613          	addi	a2,a2,14 # ffffffffc02021a0 <etext+0xace>
ffffffffc020119a:	18400593          	li	a1,388
ffffffffc020119e:	00001517          	auipc	a0,0x1
ffffffffc02011a2:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0201a88 <etext+0x3b6>
ffffffffc02011a6:	822ff0ef          	jal	ffffffffc02001c8 <__panic>
        cprintf("错误: 基本页面分配失败\n");
ffffffffc02011aa:	00001517          	auipc	a0,0x1
ffffffffc02011ae:	f7650513          	addi	a0,a0,-138 # ffffffffc0202120 <etext+0xa4e>
ffffffffc02011b2:	f97fe0ef          	jal	ffffffffc0200148 <cprintf>
        panic("基本功能测试失败");
ffffffffc02011b6:	00001617          	auipc	a2,0x1
ffffffffc02011ba:	f9260613          	addi	a2,a2,-110 # ffffffffc0202148 <etext+0xa76>
ffffffffc02011be:	17100593          	li	a1,369
ffffffffc02011c2:	00001517          	auipc	a0,0x1
ffffffffc02011c6:	8c650513          	addi	a0,a0,-1850 # ffffffffc0201a88 <etext+0x3b6>
ffffffffc02011ca:	ffffe0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc02011ce <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02011ce:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02011d0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02011d4:	f022                	sd	s0,32(sp)
ffffffffc02011d6:	ec26                	sd	s1,24(sp)
ffffffffc02011d8:	e84a                	sd	s2,16(sp)
ffffffffc02011da:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02011dc:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02011e0:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc02011e2:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02011e6:	fff7041b          	addiw	s0,a4,-1 # 3fdfffff <kern_entry-0xffffffff80400001>
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02011ea:	84aa                	mv	s1,a0
ffffffffc02011ec:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc02011ee:	03067d63          	bgeu	a2,a6,ffffffffc0201228 <printnum+0x5a>
ffffffffc02011f2:	e44e                	sd	s3,8(sp)
ffffffffc02011f4:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02011f6:	4785                	li	a5,1
ffffffffc02011f8:	00e7d763          	bge	a5,a4,ffffffffc0201206 <printnum+0x38>
            putch(padc, putdat);
ffffffffc02011fc:	85ca                	mv	a1,s2
ffffffffc02011fe:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc0201200:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201202:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201204:	fc65                	bnez	s0,ffffffffc02011fc <printnum+0x2e>
ffffffffc0201206:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201208:	00001797          	auipc	a5,0x1
ffffffffc020120c:	1a878793          	addi	a5,a5,424 # ffffffffc02023b0 <etext+0xcde>
ffffffffc0201210:	97d2                	add	a5,a5,s4
}
ffffffffc0201212:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201214:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0201218:	70a2                	ld	ra,40(sp)
ffffffffc020121a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020121c:	85ca                	mv	a1,s2
ffffffffc020121e:	87a6                	mv	a5,s1
}
ffffffffc0201220:	6942                	ld	s2,16(sp)
ffffffffc0201222:	64e2                	ld	s1,24(sp)
ffffffffc0201224:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201226:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201228:	03065633          	divu	a2,a2,a6
ffffffffc020122c:	8722                	mv	a4,s0
ffffffffc020122e:	fa1ff0ef          	jal	ffffffffc02011ce <printnum>
ffffffffc0201232:	bfd9                	j	ffffffffc0201208 <printnum+0x3a>

ffffffffc0201234 <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
ffffffffc0201234:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
ffffffffc0201236:	6198                	ld	a4,0(a1)
ffffffffc0201238:	6594                	ld	a3,8(a1)
    b->cnt ++;
ffffffffc020123a:	2785                	addiw	a5,a5,1
ffffffffc020123c:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
ffffffffc020123e:	00d77763          	bgeu	a4,a3,ffffffffc020124c <sprintputch+0x18>
        *b->buf ++ = ch;
ffffffffc0201242:	00170793          	addi	a5,a4,1
ffffffffc0201246:	e19c                	sd	a5,0(a1)
ffffffffc0201248:	00a70023          	sb	a0,0(a4)
    }
}
ffffffffc020124c:	8082                	ret

ffffffffc020124e <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020124e:	7119                	addi	sp,sp,-128
ffffffffc0201250:	f4a6                	sd	s1,104(sp)
ffffffffc0201252:	f0ca                	sd	s2,96(sp)
ffffffffc0201254:	ecce                	sd	s3,88(sp)
ffffffffc0201256:	e8d2                	sd	s4,80(sp)
ffffffffc0201258:	e4d6                	sd	s5,72(sp)
ffffffffc020125a:	e0da                	sd	s6,64(sp)
ffffffffc020125c:	f862                	sd	s8,48(sp)
ffffffffc020125e:	fc86                	sd	ra,120(sp)
ffffffffc0201260:	f8a2                	sd	s0,112(sp)
ffffffffc0201262:	fc5e                	sd	s7,56(sp)
ffffffffc0201264:	f466                	sd	s9,40(sp)
ffffffffc0201266:	f06a                	sd	s10,32(sp)
ffffffffc0201268:	ec6e                	sd	s11,24(sp)
ffffffffc020126a:	84aa                	mv	s1,a0
ffffffffc020126c:	8c32                	mv	s8,a2
ffffffffc020126e:	8a36                	mv	s4,a3
ffffffffc0201270:	892e                	mv	s2,a1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201272:	02500993          	li	s3,37
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201276:	05500b13          	li	s6,85
ffffffffc020127a:	00001a97          	auipc	s5,0x1
ffffffffc020127e:	266a8a93          	addi	s5,s5,614 # ffffffffc02024e0 <cache_sizes+0x20>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201282:	000c4503          	lbu	a0,0(s8)
ffffffffc0201286:	001c0413          	addi	s0,s8,1
ffffffffc020128a:	01350a63          	beq	a0,s3,ffffffffc020129e <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc020128e:	cd0d                	beqz	a0,ffffffffc02012c8 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0201290:	85ca                	mv	a1,s2
ffffffffc0201292:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201294:	00044503          	lbu	a0,0(s0)
ffffffffc0201298:	0405                	addi	s0,s0,1
ffffffffc020129a:	ff351ae3          	bne	a0,s3,ffffffffc020128e <vprintfmt+0x40>
        width = precision = -1;
ffffffffc020129e:	5cfd                	li	s9,-1
ffffffffc02012a0:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc02012a2:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc02012a6:	4b81                	li	s7,0
ffffffffc02012a8:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02012aa:	00044683          	lbu	a3,0(s0)
ffffffffc02012ae:	00140c13          	addi	s8,s0,1
ffffffffc02012b2:	fdd6859b          	addiw	a1,a3,-35
ffffffffc02012b6:	0ff5f593          	zext.b	a1,a1
ffffffffc02012ba:	02bb6663          	bltu	s6,a1,ffffffffc02012e6 <vprintfmt+0x98>
ffffffffc02012be:	058a                	slli	a1,a1,0x2
ffffffffc02012c0:	95d6                	add	a1,a1,s5
ffffffffc02012c2:	4198                	lw	a4,0(a1)
ffffffffc02012c4:	9756                	add	a4,a4,s5
ffffffffc02012c6:	8702                	jr	a4
}
ffffffffc02012c8:	70e6                	ld	ra,120(sp)
ffffffffc02012ca:	7446                	ld	s0,112(sp)
ffffffffc02012cc:	74a6                	ld	s1,104(sp)
ffffffffc02012ce:	7906                	ld	s2,96(sp)
ffffffffc02012d0:	69e6                	ld	s3,88(sp)
ffffffffc02012d2:	6a46                	ld	s4,80(sp)
ffffffffc02012d4:	6aa6                	ld	s5,72(sp)
ffffffffc02012d6:	6b06                	ld	s6,64(sp)
ffffffffc02012d8:	7be2                	ld	s7,56(sp)
ffffffffc02012da:	7c42                	ld	s8,48(sp)
ffffffffc02012dc:	7ca2                	ld	s9,40(sp)
ffffffffc02012de:	7d02                	ld	s10,32(sp)
ffffffffc02012e0:	6de2                	ld	s11,24(sp)
ffffffffc02012e2:	6109                	addi	sp,sp,128
ffffffffc02012e4:	8082                	ret
            putch('%', putdat);
ffffffffc02012e6:	85ca                	mv	a1,s2
ffffffffc02012e8:	02500513          	li	a0,37
ffffffffc02012ec:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02012ee:	fff44783          	lbu	a5,-1(s0)
ffffffffc02012f2:	02500713          	li	a4,37
ffffffffc02012f6:	8c22                	mv	s8,s0
ffffffffc02012f8:	f8e785e3          	beq	a5,a4,ffffffffc0201282 <vprintfmt+0x34>
ffffffffc02012fc:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0201300:	1c7d                	addi	s8,s8,-1
ffffffffc0201302:	fee79de3          	bne	a5,a4,ffffffffc02012fc <vprintfmt+0xae>
ffffffffc0201306:	bfb5                	j	ffffffffc0201282 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0201308:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc020130c:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc020130e:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc0201312:	fd06071b          	addiw	a4,a2,-48
ffffffffc0201316:	24e56a63          	bltu	a0,a4,ffffffffc020156a <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc020131a:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020131c:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc020131e:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc0201322:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201326:	0197073b          	addw	a4,a4,s9
ffffffffc020132a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020132e:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201330:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201334:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201336:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020133a:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc020133e:	feb570e3          	bgeu	a0,a1,ffffffffc020131e <vprintfmt+0xd0>
            if (width < 0)
ffffffffc0201342:	f60d54e3          	bgez	s10,ffffffffc02012aa <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0201346:	8d66                	mv	s10,s9
ffffffffc0201348:	5cfd                	li	s9,-1
ffffffffc020134a:	b785                	j	ffffffffc02012aa <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020134c:	8db6                	mv	s11,a3
ffffffffc020134e:	8462                	mv	s0,s8
ffffffffc0201350:	bfa9                	j	ffffffffc02012aa <vprintfmt+0x5c>
ffffffffc0201352:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0201354:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0201356:	bf91                	j	ffffffffc02012aa <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0201358:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020135a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020135e:	00f74463          	blt	a4,a5,ffffffffc0201366 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0201362:	1a078763          	beqz	a5,ffffffffc0201510 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0201366:	000a3603          	ld	a2,0(s4)
ffffffffc020136a:	46c1                	li	a3,16
ffffffffc020136c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020136e:	000d879b          	sext.w	a5,s11
ffffffffc0201372:	876a                	mv	a4,s10
ffffffffc0201374:	85ca                	mv	a1,s2
ffffffffc0201376:	8526                	mv	a0,s1
ffffffffc0201378:	e57ff0ef          	jal	ffffffffc02011ce <printnum>
            break;
ffffffffc020137c:	b719                	j	ffffffffc0201282 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020137e:	000a2503          	lw	a0,0(s4)
ffffffffc0201382:	85ca                	mv	a1,s2
ffffffffc0201384:	0a21                	addi	s4,s4,8
ffffffffc0201386:	9482                	jalr	s1
            break;
ffffffffc0201388:	bded                	j	ffffffffc0201282 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc020138a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020138c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201390:	00f74463          	blt	a4,a5,ffffffffc0201398 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201394:	16078963          	beqz	a5,ffffffffc0201506 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0201398:	000a3603          	ld	a2,0(s4)
ffffffffc020139c:	46a9                	li	a3,10
ffffffffc020139e:	8a2e                	mv	s4,a1
ffffffffc02013a0:	b7f9                	j	ffffffffc020136e <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc02013a2:	85ca                	mv	a1,s2
ffffffffc02013a4:	03000513          	li	a0,48
ffffffffc02013a8:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc02013aa:	85ca                	mv	a1,s2
ffffffffc02013ac:	07800513          	li	a0,120
ffffffffc02013b0:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02013b2:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc02013b6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02013b8:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02013ba:	bf55                	j	ffffffffc020136e <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc02013bc:	85ca                	mv	a1,s2
ffffffffc02013be:	02500513          	li	a0,37
ffffffffc02013c2:	9482                	jalr	s1
            break;
ffffffffc02013c4:	bd7d                	j	ffffffffc0201282 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc02013c6:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013ca:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc02013cc:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc02013ce:	bf95                	j	ffffffffc0201342 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc02013d0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02013d2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02013d6:	00f74463          	blt	a4,a5,ffffffffc02013de <vprintfmt+0x190>
    else if (lflag) {
ffffffffc02013da:	12078163          	beqz	a5,ffffffffc02014fc <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc02013de:	000a3603          	ld	a2,0(s4)
ffffffffc02013e2:	46a1                	li	a3,8
ffffffffc02013e4:	8a2e                	mv	s4,a1
ffffffffc02013e6:	b761                	j	ffffffffc020136e <vprintfmt+0x120>
            if (width < 0)
ffffffffc02013e8:	876a                	mv	a4,s10
ffffffffc02013ea:	000d5363          	bgez	s10,ffffffffc02013f0 <vprintfmt+0x1a2>
ffffffffc02013ee:	4701                	li	a4,0
ffffffffc02013f0:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013f4:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02013f6:	bd55                	j	ffffffffc02012aa <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc02013f8:	000d841b          	sext.w	s0,s11
ffffffffc02013fc:	fd340793          	addi	a5,s0,-45
ffffffffc0201400:	00f037b3          	snez	a5,a5
ffffffffc0201404:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201408:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc020140c:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020140e:	008a0793          	addi	a5,s4,8
ffffffffc0201412:	e43e                	sd	a5,8(sp)
ffffffffc0201414:	100d8c63          	beqz	s11,ffffffffc020152c <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0201418:	12071363          	bnez	a4,ffffffffc020153e <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020141c:	000dc783          	lbu	a5,0(s11)
ffffffffc0201420:	0007851b          	sext.w	a0,a5
ffffffffc0201424:	c78d                	beqz	a5,ffffffffc020144e <vprintfmt+0x200>
ffffffffc0201426:	0d85                	addi	s11,s11,1
ffffffffc0201428:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020142a:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020142e:	000cc563          	bltz	s9,ffffffffc0201438 <vprintfmt+0x1ea>
ffffffffc0201432:	3cfd                	addiw	s9,s9,-1
ffffffffc0201434:	008c8d63          	beq	s9,s0,ffffffffc020144e <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201438:	020b9663          	bnez	s7,ffffffffc0201464 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc020143c:	85ca                	mv	a1,s2
ffffffffc020143e:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201440:	000dc783          	lbu	a5,0(s11)
ffffffffc0201444:	0d85                	addi	s11,s11,1
ffffffffc0201446:	3d7d                	addiw	s10,s10,-1
ffffffffc0201448:	0007851b          	sext.w	a0,a5
ffffffffc020144c:	f3ed                	bnez	a5,ffffffffc020142e <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc020144e:	01a05963          	blez	s10,ffffffffc0201460 <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc0201452:	85ca                	mv	a1,s2
ffffffffc0201454:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0201458:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc020145a:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc020145c:	fe0d1be3          	bnez	s10,ffffffffc0201452 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201460:	6a22                	ld	s4,8(sp)
ffffffffc0201462:	b505                	j	ffffffffc0201282 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201464:	3781                	addiw	a5,a5,-32
ffffffffc0201466:	fcfa7be3          	bgeu	s4,a5,ffffffffc020143c <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc020146a:	03f00513          	li	a0,63
ffffffffc020146e:	85ca                	mv	a1,s2
ffffffffc0201470:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201472:	000dc783          	lbu	a5,0(s11)
ffffffffc0201476:	0d85                	addi	s11,s11,1
ffffffffc0201478:	3d7d                	addiw	s10,s10,-1
ffffffffc020147a:	0007851b          	sext.w	a0,a5
ffffffffc020147e:	dbe1                	beqz	a5,ffffffffc020144e <vprintfmt+0x200>
ffffffffc0201480:	fa0cd9e3          	bgez	s9,ffffffffc0201432 <vprintfmt+0x1e4>
ffffffffc0201484:	b7c5                	j	ffffffffc0201464 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0201486:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020148a:	4619                	li	a2,6
            err = va_arg(ap, int);
ffffffffc020148c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020148e:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0201492:	8fb9                	xor	a5,a5,a4
ffffffffc0201494:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201498:	02d64563          	blt	a2,a3,ffffffffc02014c2 <vprintfmt+0x274>
ffffffffc020149c:	00001797          	auipc	a5,0x1
ffffffffc02014a0:	19c78793          	addi	a5,a5,412 # ffffffffc0202638 <error_string>
ffffffffc02014a4:	00369713          	slli	a4,a3,0x3
ffffffffc02014a8:	97ba                	add	a5,a5,a4
ffffffffc02014aa:	639c                	ld	a5,0(a5)
ffffffffc02014ac:	cb99                	beqz	a5,ffffffffc02014c2 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc02014ae:	86be                	mv	a3,a5
ffffffffc02014b0:	00001617          	auipc	a2,0x1
ffffffffc02014b4:	f3060613          	addi	a2,a2,-208 # ffffffffc02023e0 <etext+0xd0e>
ffffffffc02014b8:	85ca                	mv	a1,s2
ffffffffc02014ba:	8526                	mv	a0,s1
ffffffffc02014bc:	0d8000ef          	jal	ffffffffc0201594 <printfmt>
ffffffffc02014c0:	b3c9                	j	ffffffffc0201282 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02014c2:	00001617          	auipc	a2,0x1
ffffffffc02014c6:	f0e60613          	addi	a2,a2,-242 # ffffffffc02023d0 <etext+0xcfe>
ffffffffc02014ca:	85ca                	mv	a1,s2
ffffffffc02014cc:	8526                	mv	a0,s1
ffffffffc02014ce:	0c6000ef          	jal	ffffffffc0201594 <printfmt>
ffffffffc02014d2:	bb45                	j	ffffffffc0201282 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02014d4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02014d6:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc02014da:	00f74363          	blt	a4,a5,ffffffffc02014e0 <vprintfmt+0x292>
    else if (lflag) {
ffffffffc02014de:	cf81                	beqz	a5,ffffffffc02014f6 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc02014e0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02014e4:	02044b63          	bltz	s0,ffffffffc020151a <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc02014e8:	8622                	mv	a2,s0
ffffffffc02014ea:	8a5e                	mv	s4,s7
ffffffffc02014ec:	46a9                	li	a3,10
ffffffffc02014ee:	b541                	j	ffffffffc020136e <vprintfmt+0x120>
            lflag ++;
ffffffffc02014f0:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014f2:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02014f4:	bb5d                	j	ffffffffc02012aa <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc02014f6:	000a2403          	lw	s0,0(s4)
ffffffffc02014fa:	b7ed                	j	ffffffffc02014e4 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc02014fc:	000a6603          	lwu	a2,0(s4)
ffffffffc0201500:	46a1                	li	a3,8
ffffffffc0201502:	8a2e                	mv	s4,a1
ffffffffc0201504:	b5ad                	j	ffffffffc020136e <vprintfmt+0x120>
ffffffffc0201506:	000a6603          	lwu	a2,0(s4)
ffffffffc020150a:	46a9                	li	a3,10
ffffffffc020150c:	8a2e                	mv	s4,a1
ffffffffc020150e:	b585                	j	ffffffffc020136e <vprintfmt+0x120>
ffffffffc0201510:	000a6603          	lwu	a2,0(s4)
ffffffffc0201514:	46c1                	li	a3,16
ffffffffc0201516:	8a2e                	mv	s4,a1
ffffffffc0201518:	bd99                	j	ffffffffc020136e <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc020151a:	85ca                	mv	a1,s2
ffffffffc020151c:	02d00513          	li	a0,45
ffffffffc0201520:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc0201522:	40800633          	neg	a2,s0
ffffffffc0201526:	8a5e                	mv	s4,s7
ffffffffc0201528:	46a9                	li	a3,10
ffffffffc020152a:	b591                	j	ffffffffc020136e <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc020152c:	e329                	bnez	a4,ffffffffc020156e <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020152e:	02800793          	li	a5,40
ffffffffc0201532:	853e                	mv	a0,a5
ffffffffc0201534:	00001d97          	auipc	s11,0x1
ffffffffc0201538:	e95d8d93          	addi	s11,s11,-363 # ffffffffc02023c9 <etext+0xcf7>
ffffffffc020153c:	b5f5                	j	ffffffffc0201428 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020153e:	85e6                	mv	a1,s9
ffffffffc0201540:	856e                	mv	a0,s11
ffffffffc0201542:	0ea000ef          	jal	ffffffffc020162c <strnlen>
ffffffffc0201546:	40ad0d3b          	subw	s10,s10,a0
ffffffffc020154a:	01a05863          	blez	s10,ffffffffc020155a <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc020154e:	85ca                	mv	a1,s2
ffffffffc0201550:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201552:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc0201554:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201556:	fe0d1ce3          	bnez	s10,ffffffffc020154e <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020155a:	000dc783          	lbu	a5,0(s11)
ffffffffc020155e:	0007851b          	sext.w	a0,a5
ffffffffc0201562:	ec0792e3          	bnez	a5,ffffffffc0201426 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201566:	6a22                	ld	s4,8(sp)
ffffffffc0201568:	bb29                	j	ffffffffc0201282 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020156a:	8462                	mv	s0,s8
ffffffffc020156c:	bbd9                	j	ffffffffc0201342 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020156e:	85e6                	mv	a1,s9
ffffffffc0201570:	00001517          	auipc	a0,0x1
ffffffffc0201574:	e5850513          	addi	a0,a0,-424 # ffffffffc02023c8 <etext+0xcf6>
ffffffffc0201578:	0b4000ef          	jal	ffffffffc020162c <strnlen>
ffffffffc020157c:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201580:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0201584:	00001d97          	auipc	s11,0x1
ffffffffc0201588:	e44d8d93          	addi	s11,s11,-444 # ffffffffc02023c8 <etext+0xcf6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020158c:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020158e:	fda040e3          	bgtz	s10,ffffffffc020154e <vprintfmt+0x300>
ffffffffc0201592:	bd51                	j	ffffffffc0201426 <vprintfmt+0x1d8>

ffffffffc0201594 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201594:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201596:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020159a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020159c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020159e:	ec06                	sd	ra,24(sp)
ffffffffc02015a0:	f83a                	sd	a4,48(sp)
ffffffffc02015a2:	fc3e                	sd	a5,56(sp)
ffffffffc02015a4:	e0c2                	sd	a6,64(sp)
ffffffffc02015a6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02015a8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02015aa:	ca5ff0ef          	jal	ffffffffc020124e <vprintfmt>
}
ffffffffc02015ae:	60e2                	ld	ra,24(sp)
ffffffffc02015b0:	6161                	addi	sp,sp,80
ffffffffc02015b2:	8082                	ret

ffffffffc02015b4 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
ffffffffc02015b4:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
ffffffffc02015b6:	15fd                	addi	a1,a1,-1
ffffffffc02015b8:	95aa                	add	a1,a1,a0
    va_start(ap, fmt);
ffffffffc02015ba:	03810313          	addi	t1,sp,56
snprintf(char *str, size_t size, const char *fmt, ...) {
ffffffffc02015be:	f406                	sd	ra,40(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
ffffffffc02015c0:	e82e                	sd	a1,16(sp)
ffffffffc02015c2:	e42a                	sd	a0,8(sp)
snprintf(char *str, size_t size, const char *fmt, ...) {
ffffffffc02015c4:	fc36                	sd	a3,56(sp)
ffffffffc02015c6:	e0ba                	sd	a4,64(sp)
ffffffffc02015c8:	e4be                	sd	a5,72(sp)
ffffffffc02015ca:	e8c2                	sd	a6,80(sp)
ffffffffc02015cc:	ecc6                	sd	a7,88(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
ffffffffc02015ce:	cc02                	sw	zero,24(sp)
    va_start(ap, fmt);
ffffffffc02015d0:	e01a                	sd	t1,0(sp)
    if (str == NULL || b.buf > b.ebuf) {
ffffffffc02015d2:	c115                	beqz	a0,ffffffffc02015f6 <snprintf+0x42>
ffffffffc02015d4:	02a5e163          	bltu	a1,a0,ffffffffc02015f6 <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
ffffffffc02015d8:	00000517          	auipc	a0,0x0
ffffffffc02015dc:	c5c50513          	addi	a0,a0,-932 # ffffffffc0201234 <sprintputch>
ffffffffc02015e0:	869a                	mv	a3,t1
ffffffffc02015e2:	002c                	addi	a1,sp,8
ffffffffc02015e4:	c6bff0ef          	jal	ffffffffc020124e <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
ffffffffc02015e8:	67a2                	ld	a5,8(sp)
ffffffffc02015ea:	00078023          	sb	zero,0(a5)
    return b.cnt;
ffffffffc02015ee:	4562                	lw	a0,24(sp)
}
ffffffffc02015f0:	70a2                	ld	ra,40(sp)
ffffffffc02015f2:	6125                	addi	sp,sp,96
ffffffffc02015f4:	8082                	ret
        return -E_INVAL;
ffffffffc02015f6:	5575                	li	a0,-3
ffffffffc02015f8:	bfe5                	j	ffffffffc02015f0 <snprintf+0x3c>

ffffffffc02015fa <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02015fa:	00005717          	auipc	a4,0x5
ffffffffc02015fe:	a1673703          	ld	a4,-1514(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201602:	4781                	li	a5,0
ffffffffc0201604:	88ba                	mv	a7,a4
ffffffffc0201606:	852a                	mv	a0,a0
ffffffffc0201608:	85be                	mv	a1,a5
ffffffffc020160a:	863e                	mv	a2,a5
ffffffffc020160c:	00000073          	ecall
ffffffffc0201610:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201612:	8082                	ret

ffffffffc0201614 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201614:	00054783          	lbu	a5,0(a0)
ffffffffc0201618:	cb81                	beqz	a5,ffffffffc0201628 <strlen+0x14>
    size_t cnt = 0;
ffffffffc020161a:	4781                	li	a5,0
        cnt ++;
ffffffffc020161c:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020161e:	00f50733          	add	a4,a0,a5
ffffffffc0201622:	00074703          	lbu	a4,0(a4)
ffffffffc0201626:	fb7d                	bnez	a4,ffffffffc020161c <strlen+0x8>
    }
    return cnt;
}
ffffffffc0201628:	853e                	mv	a0,a5
ffffffffc020162a:	8082                	ret

ffffffffc020162c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020162c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020162e:	e589                	bnez	a1,ffffffffc0201638 <strnlen+0xc>
ffffffffc0201630:	a811                	j	ffffffffc0201644 <strnlen+0x18>
        cnt ++;
ffffffffc0201632:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201634:	00f58863          	beq	a1,a5,ffffffffc0201644 <strnlen+0x18>
ffffffffc0201638:	00f50733          	add	a4,a0,a5
ffffffffc020163c:	00074703          	lbu	a4,0(a4)
ffffffffc0201640:	fb6d                	bnez	a4,ffffffffc0201632 <strnlen+0x6>
ffffffffc0201642:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201644:	852e                	mv	a0,a1
ffffffffc0201646:	8082                	ret

ffffffffc0201648 <strncpy>:
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
ffffffffc0201648:	ce09                	beqz	a2,ffffffffc0201662 <strncpy+0x1a>
ffffffffc020164a:	962a                	add	a2,a2,a0
    char *p = dst;
ffffffffc020164c:	872a                	mv	a4,a0
        if ((*p = *src) != '\0') {
ffffffffc020164e:	0005c783          	lbu	a5,0(a1)
            src ++;
        }
        p ++, len --;
ffffffffc0201652:	0705                	addi	a4,a4,1
        if ((*p = *src) != '\0') {
ffffffffc0201654:	fef70fa3          	sb	a5,-1(a4)
            src ++;
ffffffffc0201658:	00f037b3          	snez	a5,a5
ffffffffc020165c:	95be                	add	a1,a1,a5
    while (len > 0) {
ffffffffc020165e:	fee618e3          	bne	a2,a4,ffffffffc020164e <strncpy+0x6>
    }
    return dst;
}
ffffffffc0201662:	8082                	ret

ffffffffc0201664 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201664:	00054783          	lbu	a5,0(a0)
ffffffffc0201668:	e791                	bnez	a5,ffffffffc0201674 <strcmp+0x10>
ffffffffc020166a:	a01d                	j	ffffffffc0201690 <strcmp+0x2c>
ffffffffc020166c:	00054783          	lbu	a5,0(a0)
ffffffffc0201670:	cb99                	beqz	a5,ffffffffc0201686 <strcmp+0x22>
ffffffffc0201672:	0585                	addi	a1,a1,1
ffffffffc0201674:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc0201678:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020167a:	fef709e3          	beq	a4,a5,ffffffffc020166c <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020167e:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201682:	9d19                	subw	a0,a0,a4
ffffffffc0201684:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201686:	0015c703          	lbu	a4,1(a1)
ffffffffc020168a:	4501                	li	a0,0
}
ffffffffc020168c:	9d19                	subw	a0,a0,a4
ffffffffc020168e:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201690:	0005c703          	lbu	a4,0(a1)
ffffffffc0201694:	4501                	li	a0,0
ffffffffc0201696:	b7f5                	j	ffffffffc0201682 <strcmp+0x1e>

ffffffffc0201698 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201698:	ce01                	beqz	a2,ffffffffc02016b0 <strncmp+0x18>
ffffffffc020169a:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc020169e:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02016a0:	cb91                	beqz	a5,ffffffffc02016b4 <strncmp+0x1c>
ffffffffc02016a2:	0005c703          	lbu	a4,0(a1)
ffffffffc02016a6:	00f71763          	bne	a4,a5,ffffffffc02016b4 <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc02016aa:	0505                	addi	a0,a0,1
ffffffffc02016ac:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02016ae:	f675                	bnez	a2,ffffffffc020169a <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02016b0:	4501                	li	a0,0
ffffffffc02016b2:	8082                	ret
ffffffffc02016b4:	00054503          	lbu	a0,0(a0)
ffffffffc02016b8:	0005c783          	lbu	a5,0(a1)
ffffffffc02016bc:	9d1d                	subw	a0,a0,a5
}
ffffffffc02016be:	8082                	ret

ffffffffc02016c0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02016c0:	ca01                	beqz	a2,ffffffffc02016d0 <memset+0x10>
ffffffffc02016c2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02016c4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02016c6:	0785                	addi	a5,a5,1
ffffffffc02016c8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02016cc:	fef61de3          	bne	a2,a5,ffffffffc02016c6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02016d0:	8082                	ret
