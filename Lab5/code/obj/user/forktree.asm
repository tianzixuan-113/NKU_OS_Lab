
obj/__user_forktree.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0c2000ef          	jal	8000e2 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800026:	1101                	addi	sp,sp,-32
  800028:	ec06                	sd	ra,24(sp)
  80002a:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  80002c:	094000ef          	jal	8000c0 <sys_putc>
    (*cnt) ++;
  800030:	65a2                	ld	a1,8(sp)
}
  800032:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  800034:	419c                	lw	a5,0(a1)
  800036:	2785                	addiw	a5,a5,1
  800038:	c19c                	sw	a5,0(a1)
}
  80003a:	6105                	addi	sp,sp,32
  80003c:	8082                	ret

000000000080003e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  80003e:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800040:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800044:	f42e                	sd	a1,40(sp)
  800046:	f832                	sd	a2,48(sp)
  800048:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80004a:	862a                	mv	a2,a0
  80004c:	004c                	addi	a1,sp,4
  80004e:	00000517          	auipc	a0,0x0
  800052:	fd850513          	addi	a0,a0,-40 # 800026 <cputch>
  800056:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  800058:	ec06                	sd	ra,24(sp)
  80005a:	e0ba                	sd	a4,64(sp)
  80005c:	e4be                	sd	a5,72(sp)
  80005e:	e8c2                	sd	a6,80(sp)
  800060:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  800062:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  800064:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800066:	108000ef          	jal	80016e <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80006a:	60e2                	ld	ra,24(sp)
  80006c:	4512                	lw	a0,4(sp)
  80006e:	6125                	addi	sp,sp,96
  800070:	8082                	ret

0000000000800072 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800072:	7175                	addi	sp,sp,-144
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800074:	08010313          	addi	t1,sp,128
syscall(int64_t num, ...) {
  800078:	e42a                	sd	a0,8(sp)
  80007a:	ecae                	sd	a1,88(sp)
        a[i] = va_arg(ap, uint64_t);
  80007c:	f42e                	sd	a1,40(sp)
syscall(int64_t num, ...) {
  80007e:	f0b2                	sd	a2,96(sp)
        a[i] = va_arg(ap, uint64_t);
  800080:	f832                	sd	a2,48(sp)
syscall(int64_t num, ...) {
  800082:	f4b6                	sd	a3,104(sp)
        a[i] = va_arg(ap, uint64_t);
  800084:	fc36                	sd	a3,56(sp)
syscall(int64_t num, ...) {
  800086:	f8ba                	sd	a4,112(sp)
        a[i] = va_arg(ap, uint64_t);
  800088:	e0ba                	sd	a4,64(sp)
syscall(int64_t num, ...) {
  80008a:	fcbe                	sd	a5,120(sp)
        a[i] = va_arg(ap, uint64_t);
  80008c:	e4be                	sd	a5,72(sp)
syscall(int64_t num, ...) {
  80008e:	e142                	sd	a6,128(sp)
  800090:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  800092:	f01a                	sd	t1,32(sp)
    }
    va_end(ap);

    asm volatile (
  800094:	6522                	ld	a0,8(sp)
  800096:	75a2                	ld	a1,40(sp)
  800098:	7642                	ld	a2,48(sp)
  80009a:	76e2                	ld	a3,56(sp)
  80009c:	6706                	ld	a4,64(sp)
  80009e:	67a6                	ld	a5,72(sp)
  8000a0:	00000073          	ecall
  8000a4:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  8000a8:	4572                	lw	a0,28(sp)
  8000aa:	6149                	addi	sp,sp,144
  8000ac:	8082                	ret

00000000008000ae <sys_exit>:

int
sys_exit(int64_t error_code) {
  8000ae:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  8000b0:	4505                	li	a0,1
  8000b2:	b7c1                	j	800072 <syscall>

00000000008000b4 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000b4:	4509                	li	a0,2
  8000b6:	bf75                	j	800072 <syscall>

00000000008000b8 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000b8:	4529                	li	a0,10
  8000ba:	bf65                	j	800072 <syscall>

00000000008000bc <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000bc:	4549                	li	a0,18
  8000be:	bf55                	j	800072 <syscall>

00000000008000c0 <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000c0:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000c2:	4579                	li	a0,30
  8000c4:	b77d                	j	800072 <syscall>

00000000008000c6 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c6:	1141                	addi	sp,sp,-16
  8000c8:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000ca:	fe5ff0ef          	jal	8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000ce:	00000517          	auipc	a0,0x0
  8000d2:	54a50513          	addi	a0,a0,1354 # 800618 <main+0x1e>
  8000d6:	f69ff0ef          	jal	80003e <cprintf>
    while (1);
  8000da:	a001                	j	8000da <exit+0x14>

00000000008000dc <fork>:
}

int
fork(void) {
    return sys_fork();
  8000dc:	bfe1                	j	8000b4 <sys_fork>

00000000008000de <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000de:	bfe9                	j	8000b8 <sys_yield>

00000000008000e0 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000e0:	bff1                	j	8000bc <sys_getpid>

00000000008000e2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e2:	1141                	addi	sp,sp,-16
  8000e4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e6:	514000ef          	jal	8005fa <main>
    exit(ret);
  8000ea:	fddff0ef          	jal	8000c6 <exit>

00000000008000ee <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  8000ee:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000f0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f4:	f022                	sd	s0,32(sp)
  8000f6:	ec26                	sd	s1,24(sp)
  8000f8:	e84a                	sd	s2,16(sp)
  8000fa:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000fc:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800100:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800102:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800106:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80010a:	84aa                	mv	s1,a0
  80010c:	892e                	mv	s2,a1
    if (num >= base) {
  80010e:	03067d63          	bgeu	a2,a6,800148 <printnum+0x5a>
  800112:	e44e                	sd	s3,8(sp)
  800114:	89be                	mv	s3,a5
        while (-- width > 0)
  800116:	4785                	li	a5,1
  800118:	00e7d763          	bge	a5,a4,800126 <printnum+0x38>
            putch(padc, putdat);
  80011c:	85ca                	mv	a1,s2
  80011e:	854e                	mv	a0,s3
        while (-- width > 0)
  800120:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800122:	9482                	jalr	s1
        while (-- width > 0)
  800124:	fc65                	bnez	s0,80011c <printnum+0x2e>
  800126:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800128:	00000797          	auipc	a5,0x0
  80012c:	50878793          	addi	a5,a5,1288 # 800630 <main+0x36>
  800130:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800132:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800134:	0007c503          	lbu	a0,0(a5)
}
  800138:	70a2                	ld	ra,40(sp)
  80013a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013c:	85ca                	mv	a1,s2
  80013e:	87a6                	mv	a5,s1
}
  800140:	6942                	ld	s2,16(sp)
  800142:	64e2                	ld	s1,24(sp)
  800144:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800146:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800148:	03065633          	divu	a2,a2,a6
  80014c:	8722                	mv	a4,s0
  80014e:	fa1ff0ef          	jal	8000ee <printnum>
  800152:	bfd9                	j	800128 <printnum+0x3a>

0000000000800154 <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  800154:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800156:	6198                	ld	a4,0(a1)
  800158:	6594                	ld	a3,8(a1)
    b->cnt ++;
  80015a:	2785                	addiw	a5,a5,1
  80015c:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  80015e:	00d77763          	bgeu	a4,a3,80016c <sprintputch+0x18>
        *b->buf ++ = ch;
  800162:	00170793          	addi	a5,a4,1
  800166:	e19c                	sd	a5,0(a1)
  800168:	00a70023          	sb	a0,0(a4)
    }
}
  80016c:	8082                	ret

000000000080016e <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80016e:	7119                	addi	sp,sp,-128
  800170:	f4a6                	sd	s1,104(sp)
  800172:	f0ca                	sd	s2,96(sp)
  800174:	ecce                	sd	s3,88(sp)
  800176:	e8d2                	sd	s4,80(sp)
  800178:	e4d6                	sd	s5,72(sp)
  80017a:	e0da                	sd	s6,64(sp)
  80017c:	f862                	sd	s8,48(sp)
  80017e:	fc86                	sd	ra,120(sp)
  800180:	f8a2                	sd	s0,112(sp)
  800182:	fc5e                	sd	s7,56(sp)
  800184:	f466                	sd	s9,40(sp)
  800186:	f06a                	sd	s10,32(sp)
  800188:	ec6e                	sd	s11,24(sp)
  80018a:	84aa                	mv	s1,a0
  80018c:	8c32                	mv	s8,a2
  80018e:	8a36                	mv	s4,a3
  800190:	892e                	mv	s2,a1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800192:	02500993          	li	s3,37
        switch (ch = *(unsigned char *)fmt ++) {
  800196:	05500b13          	li	s6,85
  80019a:	00000a97          	auipc	s5,0x0
  80019e:	5aea8a93          	addi	s5,s5,1454 # 800748 <main+0x14e>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a2:	000c4503          	lbu	a0,0(s8)
  8001a6:	001c0413          	addi	s0,s8,1
  8001aa:	01350a63          	beq	a0,s3,8001be <vprintfmt+0x50>
            if (ch == '\0') {
  8001ae:	cd0d                	beqz	a0,8001e8 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001b0:	85ca                	mv	a1,s2
  8001b2:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001b4:	00044503          	lbu	a0,0(s0)
  8001b8:	0405                	addi	s0,s0,1
  8001ba:	ff351ae3          	bne	a0,s3,8001ae <vprintfmt+0x40>
        width = precision = -1;
  8001be:	5cfd                	li	s9,-1
  8001c0:	8d66                	mv	s10,s9
        char padc = ' ';
  8001c2:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001c6:	4b81                	li	s7,0
  8001c8:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001ca:	00044683          	lbu	a3,0(s0)
  8001ce:	00140c13          	addi	s8,s0,1
  8001d2:	fdd6859b          	addiw	a1,a3,-35
  8001d6:	0ff5f593          	zext.b	a1,a1
  8001da:	02bb6663          	bltu	s6,a1,800206 <vprintfmt+0x98>
  8001de:	058a                	slli	a1,a1,0x2
  8001e0:	95d6                	add	a1,a1,s5
  8001e2:	4198                	lw	a4,0(a1)
  8001e4:	9756                	add	a4,a4,s5
  8001e6:	8702                	jr	a4
}
  8001e8:	70e6                	ld	ra,120(sp)
  8001ea:	7446                	ld	s0,112(sp)
  8001ec:	74a6                	ld	s1,104(sp)
  8001ee:	7906                	ld	s2,96(sp)
  8001f0:	69e6                	ld	s3,88(sp)
  8001f2:	6a46                	ld	s4,80(sp)
  8001f4:	6aa6                	ld	s5,72(sp)
  8001f6:	6b06                	ld	s6,64(sp)
  8001f8:	7be2                	ld	s7,56(sp)
  8001fa:	7c42                	ld	s8,48(sp)
  8001fc:	7ca2                	ld	s9,40(sp)
  8001fe:	7d02                	ld	s10,32(sp)
  800200:	6de2                	ld	s11,24(sp)
  800202:	6109                	addi	sp,sp,128
  800204:	8082                	ret
            putch('%', putdat);
  800206:	85ca                	mv	a1,s2
  800208:	02500513          	li	a0,37
  80020c:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  80020e:	fff44783          	lbu	a5,-1(s0)
  800212:	02500713          	li	a4,37
  800216:	8c22                	mv	s8,s0
  800218:	f8e785e3          	beq	a5,a4,8001a2 <vprintfmt+0x34>
  80021c:	ffec4783          	lbu	a5,-2(s8)
  800220:	1c7d                	addi	s8,s8,-1
  800222:	fee79de3          	bne	a5,a4,80021c <vprintfmt+0xae>
  800226:	bfb5                	j	8001a2 <vprintfmt+0x34>
                ch = *fmt;
  800228:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  80022c:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80022e:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800232:	fd06071b          	addiw	a4,a2,-48
  800236:	24e56a63          	bltu	a0,a4,80048a <vprintfmt+0x31c>
                ch = *fmt;
  80023a:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80023c:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  80023e:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800242:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800246:	0197073b          	addw	a4,a4,s9
  80024a:	0017171b          	slliw	a4,a4,0x1
  80024e:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  800250:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800254:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800256:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80025a:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  80025e:	feb570e3          	bgeu	a0,a1,80023e <vprintfmt+0xd0>
            if (width < 0)
  800262:	f60d54e3          	bgez	s10,8001ca <vprintfmt+0x5c>
                width = precision, precision = -1;
  800266:	8d66                	mv	s10,s9
  800268:	5cfd                	li	s9,-1
  80026a:	b785                	j	8001ca <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  80026c:	8db6                	mv	s11,a3
  80026e:	8462                	mv	s0,s8
  800270:	bfa9                	j	8001ca <vprintfmt+0x5c>
  800272:	8462                	mv	s0,s8
            altflag = 1;
  800274:	4b85                	li	s7,1
            goto reswitch;
  800276:	bf91                	j	8001ca <vprintfmt+0x5c>
    if (lflag >= 2) {
  800278:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80027a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80027e:	00f74463          	blt	a4,a5,800286 <vprintfmt+0x118>
    else if (lflag) {
  800282:	1a078763          	beqz	a5,800430 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  800286:	000a3603          	ld	a2,0(s4)
  80028a:	46c1                	li	a3,16
  80028c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  80028e:	000d879b          	sext.w	a5,s11
  800292:	876a                	mv	a4,s10
  800294:	85ca                	mv	a1,s2
  800296:	8526                	mv	a0,s1
  800298:	e57ff0ef          	jal	8000ee <printnum>
            break;
  80029c:	b719                	j	8001a2 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  80029e:	000a2503          	lw	a0,0(s4)
  8002a2:	85ca                	mv	a1,s2
  8002a4:	0a21                	addi	s4,s4,8
  8002a6:	9482                	jalr	s1
            break;
  8002a8:	bded                	j	8001a2 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002aa:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ac:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002b0:	00f74463          	blt	a4,a5,8002b8 <vprintfmt+0x14a>
    else if (lflag) {
  8002b4:	16078963          	beqz	a5,800426 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002b8:	000a3603          	ld	a2,0(s4)
  8002bc:	46a9                	li	a3,10
  8002be:	8a2e                	mv	s4,a1
  8002c0:	b7f9                	j	80028e <vprintfmt+0x120>
            putch('0', putdat);
  8002c2:	85ca                	mv	a1,s2
  8002c4:	03000513          	li	a0,48
  8002c8:	9482                	jalr	s1
            putch('x', putdat);
  8002ca:	85ca                	mv	a1,s2
  8002cc:	07800513          	li	a0,120
  8002d0:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002d2:	000a3603          	ld	a2,0(s4)
            goto number;
  8002d6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002d8:	0a21                	addi	s4,s4,8
            goto number;
  8002da:	bf55                	j	80028e <vprintfmt+0x120>
            putch(ch, putdat);
  8002dc:	85ca                	mv	a1,s2
  8002de:	02500513          	li	a0,37
  8002e2:	9482                	jalr	s1
            break;
  8002e4:	bd7d                	j	8001a2 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002e6:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ea:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002ec:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002ee:	bf95                	j	800262 <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002f0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002f2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002f6:	00f74463          	blt	a4,a5,8002fe <vprintfmt+0x190>
    else if (lflag) {
  8002fa:	12078163          	beqz	a5,80041c <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  8002fe:	000a3603          	ld	a2,0(s4)
  800302:	46a1                	li	a3,8
  800304:	8a2e                	mv	s4,a1
  800306:	b761                	j	80028e <vprintfmt+0x120>
            if (width < 0)
  800308:	876a                	mv	a4,s10
  80030a:	000d5363          	bgez	s10,800310 <vprintfmt+0x1a2>
  80030e:	4701                	li	a4,0
  800310:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800314:	8462                	mv	s0,s8
            goto reswitch;
  800316:	bd55                	j	8001ca <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800318:	000d841b          	sext.w	s0,s11
  80031c:	fd340793          	addi	a5,s0,-45
  800320:	00f037b3          	snez	a5,a5
  800324:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800328:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  80032c:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80032e:	008a0793          	addi	a5,s4,8
  800332:	e43e                	sd	a5,8(sp)
  800334:	100d8c63          	beqz	s11,80044c <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800338:	12071363          	bnez	a4,80045e <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80033c:	000dc783          	lbu	a5,0(s11)
  800340:	0007851b          	sext.w	a0,a5
  800344:	c78d                	beqz	a5,80036e <vprintfmt+0x200>
  800346:	0d85                	addi	s11,s11,1
  800348:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  80034a:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80034e:	000cc563          	bltz	s9,800358 <vprintfmt+0x1ea>
  800352:	3cfd                	addiw	s9,s9,-1
  800354:	008c8d63          	beq	s9,s0,80036e <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  800358:	020b9663          	bnez	s7,800384 <vprintfmt+0x216>
                    putch(ch, putdat);
  80035c:	85ca                	mv	a1,s2
  80035e:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800360:	000dc783          	lbu	a5,0(s11)
  800364:	0d85                	addi	s11,s11,1
  800366:	3d7d                	addiw	s10,s10,-1
  800368:	0007851b          	sext.w	a0,a5
  80036c:	f3ed                	bnez	a5,80034e <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  80036e:	01a05963          	blez	s10,800380 <vprintfmt+0x212>
                putch(' ', putdat);
  800372:	85ca                	mv	a1,s2
  800374:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800378:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  80037a:	9482                	jalr	s1
            for (; width > 0; width --) {
  80037c:	fe0d1be3          	bnez	s10,800372 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  800380:	6a22                	ld	s4,8(sp)
  800382:	b505                	j	8001a2 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  800384:	3781                	addiw	a5,a5,-32
  800386:	fcfa7be3          	bgeu	s4,a5,80035c <vprintfmt+0x1ee>
                    putch('?', putdat);
  80038a:	03f00513          	li	a0,63
  80038e:	85ca                	mv	a1,s2
  800390:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800392:	000dc783          	lbu	a5,0(s11)
  800396:	0d85                	addi	s11,s11,1
  800398:	3d7d                	addiw	s10,s10,-1
  80039a:	0007851b          	sext.w	a0,a5
  80039e:	dbe1                	beqz	a5,80036e <vprintfmt+0x200>
  8003a0:	fa0cd9e3          	bgez	s9,800352 <vprintfmt+0x1e4>
  8003a4:	b7c5                	j	800384 <vprintfmt+0x216>
            if (err < 0) {
  8003a6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003aa:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003ac:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003ae:	41f7d71b          	sraiw	a4,a5,0x1f
  8003b2:	8fb9                	xor	a5,a5,a4
  8003b4:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003b8:	02d64563          	blt	a2,a3,8003e2 <vprintfmt+0x274>
  8003bc:	00000797          	auipc	a5,0x0
  8003c0:	4e478793          	addi	a5,a5,1252 # 8008a0 <error_string>
  8003c4:	00369713          	slli	a4,a3,0x3
  8003c8:	97ba                	add	a5,a5,a4
  8003ca:	639c                	ld	a5,0(a5)
  8003cc:	cb99                	beqz	a5,8003e2 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  8003ce:	86be                	mv	a3,a5
  8003d0:	00000617          	auipc	a2,0x0
  8003d4:	29060613          	addi	a2,a2,656 # 800660 <main+0x66>
  8003d8:	85ca                	mv	a1,s2
  8003da:	8526                	mv	a0,s1
  8003dc:	0d8000ef          	jal	8004b4 <printfmt>
  8003e0:	b3c9                	j	8001a2 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003e2:	00000617          	auipc	a2,0x0
  8003e6:	26e60613          	addi	a2,a2,622 # 800650 <main+0x56>
  8003ea:	85ca                	mv	a1,s2
  8003ec:	8526                	mv	a0,s1
  8003ee:	0c6000ef          	jal	8004b4 <printfmt>
  8003f2:	bb45                	j	8001a2 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003f6:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003fa:	00f74363          	blt	a4,a5,800400 <vprintfmt+0x292>
    else if (lflag) {
  8003fe:	cf81                	beqz	a5,800416 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800400:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800404:	02044b63          	bltz	s0,80043a <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800408:	8622                	mv	a2,s0
  80040a:	8a5e                	mv	s4,s7
  80040c:	46a9                	li	a3,10
  80040e:	b541                	j	80028e <vprintfmt+0x120>
            lflag ++;
  800410:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800412:	8462                	mv	s0,s8
            goto reswitch;
  800414:	bb5d                	j	8001ca <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800416:	000a2403          	lw	s0,0(s4)
  80041a:	b7ed                	j	800404 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  80041c:	000a6603          	lwu	a2,0(s4)
  800420:	46a1                	li	a3,8
  800422:	8a2e                	mv	s4,a1
  800424:	b5ad                	j	80028e <vprintfmt+0x120>
  800426:	000a6603          	lwu	a2,0(s4)
  80042a:	46a9                	li	a3,10
  80042c:	8a2e                	mv	s4,a1
  80042e:	b585                	j	80028e <vprintfmt+0x120>
  800430:	000a6603          	lwu	a2,0(s4)
  800434:	46c1                	li	a3,16
  800436:	8a2e                	mv	s4,a1
  800438:	bd99                	j	80028e <vprintfmt+0x120>
                putch('-', putdat);
  80043a:	85ca                	mv	a1,s2
  80043c:	02d00513          	li	a0,45
  800440:	9482                	jalr	s1
                num = -(long long)num;
  800442:	40800633          	neg	a2,s0
  800446:	8a5e                	mv	s4,s7
  800448:	46a9                	li	a3,10
  80044a:	b591                	j	80028e <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  80044c:	e329                	bnez	a4,80048e <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80044e:	02800793          	li	a5,40
  800452:	853e                	mv	a0,a5
  800454:	00000d97          	auipc	s11,0x0
  800458:	1f5d8d93          	addi	s11,s11,501 # 800649 <main+0x4f>
  80045c:	b5f5                	j	800348 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80045e:	85e6                	mv	a1,s9
  800460:	856e                	mv	a0,s11
  800462:	0d0000ef          	jal	800532 <strnlen>
  800466:	40ad0d3b          	subw	s10,s10,a0
  80046a:	01a05863          	blez	s10,80047a <vprintfmt+0x30c>
                    putch(padc, putdat);
  80046e:	85ca                	mv	a1,s2
  800470:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  800472:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  800474:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  800476:	fe0d1ce3          	bnez	s10,80046e <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80047a:	000dc783          	lbu	a5,0(s11)
  80047e:	0007851b          	sext.w	a0,a5
  800482:	ec0792e3          	bnez	a5,800346 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  800486:	6a22                	ld	s4,8(sp)
  800488:	bb29                	j	8001a2 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  80048a:	8462                	mv	s0,s8
  80048c:	bbd9                	j	800262 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80048e:	85e6                	mv	a1,s9
  800490:	00000517          	auipc	a0,0x0
  800494:	1b850513          	addi	a0,a0,440 # 800648 <main+0x4e>
  800498:	09a000ef          	jal	800532 <strnlen>
  80049c:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a0:	02800793          	li	a5,40
                p = "(null)";
  8004a4:	00000d97          	auipc	s11,0x0
  8004a8:	1a4d8d93          	addi	s11,s11,420 # 800648 <main+0x4e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ac:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ae:	fda040e3          	bgtz	s10,80046e <vprintfmt+0x300>
  8004b2:	bd51                	j	800346 <vprintfmt+0x1d8>

00000000008004b4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004b6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ba:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004bc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004be:	ec06                	sd	ra,24(sp)
  8004c0:	f83a                	sd	a4,48(sp)
  8004c2:	fc3e                	sd	a5,56(sp)
  8004c4:	e0c2                	sd	a6,64(sp)
  8004c6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004c8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ca:	ca5ff0ef          	jal	80016e <vprintfmt>
}
  8004ce:	60e2                	ld	ra,24(sp)
  8004d0:	6161                	addi	sp,sp,80
  8004d2:	8082                	ret

00000000008004d4 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  8004d4:	711d                	addi	sp,sp,-96
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  8004d6:	15fd                	addi	a1,a1,-1
  8004d8:	95aa                	add	a1,a1,a0
    va_start(ap, fmt);
  8004da:	03810313          	addi	t1,sp,56
snprintf(char *str, size_t size, const char *fmt, ...) {
  8004de:	f406                	sd	ra,40(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  8004e0:	e82e                	sd	a1,16(sp)
  8004e2:	e42a                	sd	a0,8(sp)
snprintf(char *str, size_t size, const char *fmt, ...) {
  8004e4:	fc36                	sd	a3,56(sp)
  8004e6:	e0ba                	sd	a4,64(sp)
  8004e8:	e4be                	sd	a5,72(sp)
  8004ea:	e8c2                	sd	a6,80(sp)
  8004ec:	ecc6                	sd	a7,88(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  8004ee:	cc02                	sw	zero,24(sp)
    va_start(ap, fmt);
  8004f0:	e01a                	sd	t1,0(sp)
    if (str == NULL || b.buf > b.ebuf) {
  8004f2:	c115                	beqz	a0,800516 <snprintf+0x42>
  8004f4:	02a5e163          	bltu	a1,a0,800516 <snprintf+0x42>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  8004f8:	00000517          	auipc	a0,0x0
  8004fc:	c5c50513          	addi	a0,a0,-932 # 800154 <sprintputch>
  800500:	869a                	mv	a3,t1
  800502:	002c                	addi	a1,sp,8
  800504:	c6bff0ef          	jal	80016e <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800508:	67a2                	ld	a5,8(sp)
  80050a:	00078023          	sb	zero,0(a5)
    return b.cnt;
  80050e:	4562                	lw	a0,24(sp)
}
  800510:	70a2                	ld	ra,40(sp)
  800512:	6125                	addi	sp,sp,96
  800514:	8082                	ret
        return -E_INVAL;
  800516:	5575                	li	a0,-3
  800518:	bfe5                	j	800510 <snprintf+0x3c>

000000000080051a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  80051a:	00054783          	lbu	a5,0(a0)
  80051e:	cb81                	beqz	a5,80052e <strlen+0x14>
    size_t cnt = 0;
  800520:	4781                	li	a5,0
        cnt ++;
  800522:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
  800524:	00f50733          	add	a4,a0,a5
  800528:	00074703          	lbu	a4,0(a4)
  80052c:	fb7d                	bnez	a4,800522 <strlen+0x8>
    }
    return cnt;
}
  80052e:	853e                	mv	a0,a5
  800530:	8082                	ret

0000000000800532 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800532:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800534:	e589                	bnez	a1,80053e <strnlen+0xc>
  800536:	a811                	j	80054a <strnlen+0x18>
        cnt ++;
  800538:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80053a:	00f58863          	beq	a1,a5,80054a <strnlen+0x18>
  80053e:	00f50733          	add	a4,a0,a5
  800542:	00074703          	lbu	a4,0(a4)
  800546:	fb6d                	bnez	a4,800538 <strnlen+0x6>
  800548:	85be                	mv	a1,a5
    }
    return cnt;
}
  80054a:	852e                	mv	a0,a1
  80054c:	8082                	ret

000000000080054e <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  80054e:	1101                	addi	sp,sp,-32
  800550:	ec06                	sd	ra,24(sp)
  800552:	e822                	sd	s0,16(sp)
  800554:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  800556:	b8bff0ef          	jal	8000e0 <getpid>
  80055a:	85aa                	mv	a1,a0
  80055c:	8622                	mv	a2,s0
  80055e:	00000517          	auipc	a0,0x0
  800562:	1ca50513          	addi	a0,a0,458 # 800728 <main+0x12e>
  800566:	ad9ff0ef          	jal	80003e <cprintf>
    if (strlen(cur) >= DEPTH)
  80056a:	8522                	mv	a0,s0
  80056c:	fafff0ef          	jal	80051a <strlen>
  800570:	478d                	li	a5,3
  800572:	00a7f963          	bgeu	a5,a0,800584 <forktree+0x36>

    forkchild(cur, '0');
    forkchild(cur, '1');
  800576:	8522                	mv	a0,s0
}
  800578:	6442                	ld	s0,16(sp)
  80057a:	60e2                	ld	ra,24(sp)
    forkchild(cur, '1');
  80057c:	03100593          	li	a1,49
}
  800580:	6105                	addi	sp,sp,32
    forkchild(cur, '1');
  800582:	a03d                	j	8005b0 <forkchild>
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  800584:	03000713          	li	a4,48
  800588:	86a2                	mv	a3,s0
  80058a:	00000617          	auipc	a2,0x0
  80058e:	1b660613          	addi	a2,a2,438 # 800740 <main+0x146>
  800592:	4595                	li	a1,5
  800594:	0028                	addi	a0,sp,8
  800596:	f3fff0ef          	jal	8004d4 <snprintf>
    if (fork() == 0) {
  80059a:	b43ff0ef          	jal	8000dc <fork>
  80059e:	fd61                	bnez	a0,800576 <forktree+0x28>
        forktree(nxt);
  8005a0:	0028                	addi	a0,sp,8
  8005a2:	fadff0ef          	jal	80054e <forktree>
        yield();
  8005a6:	b39ff0ef          	jal	8000de <yield>
        exit(0);
  8005aa:	4501                	li	a0,0
  8005ac:	b1bff0ef          	jal	8000c6 <exit>

00000000008005b0 <forkchild>:
forkchild(const char *cur, char branch) {
  8005b0:	7179                	addi	sp,sp,-48
  8005b2:	f022                	sd	s0,32(sp)
  8005b4:	ec26                	sd	s1,24(sp)
  8005b6:	f406                	sd	ra,40(sp)
  8005b8:	84ae                	mv	s1,a1
  8005ba:	842a                	mv	s0,a0
    if (strlen(cur) >= DEPTH)
  8005bc:	f5fff0ef          	jal	80051a <strlen>
  8005c0:	478d                	li	a5,3
  8005c2:	00a7f763          	bgeu	a5,a0,8005d0 <forkchild+0x20>
}
  8005c6:	70a2                	ld	ra,40(sp)
  8005c8:	7402                	ld	s0,32(sp)
  8005ca:	64e2                	ld	s1,24(sp)
  8005cc:	6145                	addi	sp,sp,48
  8005ce:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005d0:	8726                	mv	a4,s1
  8005d2:	86a2                	mv	a3,s0
  8005d4:	00000617          	auipc	a2,0x0
  8005d8:	16c60613          	addi	a2,a2,364 # 800740 <main+0x146>
  8005dc:	4595                	li	a1,5
  8005de:	0028                	addi	a0,sp,8
  8005e0:	ef5ff0ef          	jal	8004d4 <snprintf>
    if (fork() == 0) {
  8005e4:	af9ff0ef          	jal	8000dc <fork>
  8005e8:	fd79                	bnez	a0,8005c6 <forkchild+0x16>
        forktree(nxt);
  8005ea:	0028                	addi	a0,sp,8
  8005ec:	f63ff0ef          	jal	80054e <forktree>
        yield();
  8005f0:	aefff0ef          	jal	8000de <yield>
        exit(0);
  8005f4:	4501                	li	a0,0
  8005f6:	ad1ff0ef          	jal	8000c6 <exit>

00000000008005fa <main>:

int
main(void) {
  8005fa:	1141                	addi	sp,sp,-16
    forktree("");
  8005fc:	00000517          	auipc	a0,0x0
  800600:	13c50513          	addi	a0,a0,316 # 800738 <main+0x13e>
main(void) {
  800604:	e406                	sd	ra,8(sp)
    forktree("");
  800606:	f49ff0ef          	jal	80054e <forktree>
    return 0;
}
  80060a:	60a2                	ld	ra,8(sp)
  80060c:	4501                	li	a0,0
  80060e:	0141                	addi	sp,sp,16
  800610:	8082                	ret
