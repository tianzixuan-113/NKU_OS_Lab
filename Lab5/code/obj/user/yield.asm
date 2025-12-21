
obj/__user_yield.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0bc000ef          	jal	8000dc <umain>
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
  80002c:	090000ef          	jal	8000bc <sys_putc>
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
  800066:	0e8000ef          	jal	80014e <vprintfmt>
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

00000000008000b4 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000b4:	4529                	li	a0,10
  8000b6:	bf75                	j	800072 <syscall>

00000000008000b8 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b8:	4549                	li	a0,18
  8000ba:	bf65                	j	800072 <syscall>

00000000008000bc <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000bc:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000be:	4579                	li	a0,30
  8000c0:	bf4d                	j	800072 <syscall>

00000000008000c2 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c2:	1141                	addi	sp,sp,-16
  8000c4:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c6:	fe9ff0ef          	jal	8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000ca:	00000517          	auipc	a0,0x0
  8000ce:	46e50513          	addi	a0,a0,1134 # 800538 <main+0x68>
  8000d2:	f6dff0ef          	jal	80003e <cprintf>
    while (1);
  8000d6:	a001                	j	8000d6 <exit+0x14>

00000000008000d8 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000d8:	bff1                	j	8000b4 <sys_yield>

00000000008000da <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000da:	bff9                	j	8000b8 <sys_getpid>

00000000008000dc <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000dc:	1141                	addi	sp,sp,-16
  8000de:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e0:	3f0000ef          	jal	8004d0 <main>
    exit(ret);
  8000e4:	fdfff0ef          	jal	8000c2 <exit>

00000000008000e8 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  8000e8:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000ea:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ee:	f022                	sd	s0,32(sp)
  8000f0:	ec26                	sd	s1,24(sp)
  8000f2:	e84a                	sd	s2,16(sp)
  8000f4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000f6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000fa:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  8000fc:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800100:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800104:	84aa                	mv	s1,a0
  800106:	892e                	mv	s2,a1
    if (num >= base) {
  800108:	03067d63          	bgeu	a2,a6,800142 <printnum+0x5a>
  80010c:	e44e                	sd	s3,8(sp)
  80010e:	89be                	mv	s3,a5
        while (-- width > 0)
  800110:	4785                	li	a5,1
  800112:	00e7d763          	bge	a5,a4,800120 <printnum+0x38>
            putch(padc, putdat);
  800116:	85ca                	mv	a1,s2
  800118:	854e                	mv	a0,s3
        while (-- width > 0)
  80011a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80011c:	9482                	jalr	s1
        while (-- width > 0)
  80011e:	fc65                	bnez	s0,800116 <printnum+0x2e>
  800120:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800122:	00000797          	auipc	a5,0x0
  800126:	42e78793          	addi	a5,a5,1070 # 800550 <main+0x80>
  80012a:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80012c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80012e:	0007c503          	lbu	a0,0(a5)
}
  800132:	70a2                	ld	ra,40(sp)
  800134:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800136:	85ca                	mv	a1,s2
  800138:	87a6                	mv	a5,s1
}
  80013a:	6942                	ld	s2,16(sp)
  80013c:	64e2                	ld	s1,24(sp)
  80013e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800140:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800142:	03065633          	divu	a2,a2,a6
  800146:	8722                	mv	a4,s0
  800148:	fa1ff0ef          	jal	8000e8 <printnum>
  80014c:	bfd9                	j	800122 <printnum+0x3a>

000000000080014e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80014e:	7119                	addi	sp,sp,-128
  800150:	f4a6                	sd	s1,104(sp)
  800152:	f0ca                	sd	s2,96(sp)
  800154:	ecce                	sd	s3,88(sp)
  800156:	e8d2                	sd	s4,80(sp)
  800158:	e4d6                	sd	s5,72(sp)
  80015a:	e0da                	sd	s6,64(sp)
  80015c:	f862                	sd	s8,48(sp)
  80015e:	fc86                	sd	ra,120(sp)
  800160:	f8a2                	sd	s0,112(sp)
  800162:	fc5e                	sd	s7,56(sp)
  800164:	f466                	sd	s9,40(sp)
  800166:	f06a                	sd	s10,32(sp)
  800168:	ec6e                	sd	s11,24(sp)
  80016a:	84aa                	mv	s1,a0
  80016c:	8c32                	mv	s8,a2
  80016e:	8a36                	mv	s4,a3
  800170:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800172:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800176:	05500b13          	li	s6,85
  80017a:	00000a97          	auipc	s5,0x0
  80017e:	54ea8a93          	addi	s5,s5,1358 # 8006c8 <main+0x1f8>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800182:	000c4503          	lbu	a0,0(s8)
  800186:	001c0413          	addi	s0,s8,1
  80018a:	01350a63          	beq	a0,s3,80019e <vprintfmt+0x50>
            if (ch == '\0') {
  80018e:	cd0d                	beqz	a0,8001c8 <vprintfmt+0x7a>
            putch(ch, putdat);
  800190:	85ca                	mv	a1,s2
  800192:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800194:	00044503          	lbu	a0,0(s0)
  800198:	0405                	addi	s0,s0,1
  80019a:	ff351ae3          	bne	a0,s3,80018e <vprintfmt+0x40>
        width = precision = -1;
  80019e:	5cfd                	li	s9,-1
  8001a0:	8d66                	mv	s10,s9
        char padc = ' ';
  8001a2:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001a6:	4b81                	li	s7,0
  8001a8:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001aa:	00044683          	lbu	a3,0(s0)
  8001ae:	00140c13          	addi	s8,s0,1
  8001b2:	fdd6859b          	addiw	a1,a3,-35
  8001b6:	0ff5f593          	zext.b	a1,a1
  8001ba:	02bb6663          	bltu	s6,a1,8001e6 <vprintfmt+0x98>
  8001be:	058a                	slli	a1,a1,0x2
  8001c0:	95d6                	add	a1,a1,s5
  8001c2:	4198                	lw	a4,0(a1)
  8001c4:	9756                	add	a4,a4,s5
  8001c6:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001c8:	70e6                	ld	ra,120(sp)
  8001ca:	7446                	ld	s0,112(sp)
  8001cc:	74a6                	ld	s1,104(sp)
  8001ce:	7906                	ld	s2,96(sp)
  8001d0:	69e6                	ld	s3,88(sp)
  8001d2:	6a46                	ld	s4,80(sp)
  8001d4:	6aa6                	ld	s5,72(sp)
  8001d6:	6b06                	ld	s6,64(sp)
  8001d8:	7be2                	ld	s7,56(sp)
  8001da:	7c42                	ld	s8,48(sp)
  8001dc:	7ca2                	ld	s9,40(sp)
  8001de:	7d02                	ld	s10,32(sp)
  8001e0:	6de2                	ld	s11,24(sp)
  8001e2:	6109                	addi	sp,sp,128
  8001e4:	8082                	ret
            putch('%', putdat);
  8001e6:	85ca                	mv	a1,s2
  8001e8:	02500513          	li	a0,37
  8001ec:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  8001ee:	fff44783          	lbu	a5,-1(s0)
  8001f2:	02500713          	li	a4,37
  8001f6:	8c22                	mv	s8,s0
  8001f8:	f8e785e3          	beq	a5,a4,800182 <vprintfmt+0x34>
  8001fc:	ffec4783          	lbu	a5,-2(s8)
  800200:	1c7d                	addi	s8,s8,-1
  800202:	fee79de3          	bne	a5,a4,8001fc <vprintfmt+0xae>
  800206:	bfb5                	j	800182 <vprintfmt+0x34>
                ch = *fmt;
  800208:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  80020c:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80020e:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800212:	fd06071b          	addiw	a4,a2,-48
  800216:	24e56a63          	bltu	a0,a4,80046a <vprintfmt+0x31c>
                ch = *fmt;
  80021a:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80021c:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  80021e:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800222:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800226:	0197073b          	addw	a4,a4,s9
  80022a:	0017171b          	slliw	a4,a4,0x1
  80022e:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  800230:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800234:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800236:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80023a:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  80023e:	feb570e3          	bgeu	a0,a1,80021e <vprintfmt+0xd0>
            if (width < 0)
  800242:	f60d54e3          	bgez	s10,8001aa <vprintfmt+0x5c>
                width = precision, precision = -1;
  800246:	8d66                	mv	s10,s9
  800248:	5cfd                	li	s9,-1
  80024a:	b785                	j	8001aa <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  80024c:	8db6                	mv	s11,a3
  80024e:	8462                	mv	s0,s8
  800250:	bfa9                	j	8001aa <vprintfmt+0x5c>
  800252:	8462                	mv	s0,s8
            altflag = 1;
  800254:	4b85                	li	s7,1
            goto reswitch;
  800256:	bf91                	j	8001aa <vprintfmt+0x5c>
    if (lflag >= 2) {
  800258:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80025a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80025e:	00f74463          	blt	a4,a5,800266 <vprintfmt+0x118>
    else if (lflag) {
  800262:	1a078763          	beqz	a5,800410 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  800266:	000a3603          	ld	a2,0(s4)
  80026a:	46c1                	li	a3,16
  80026c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  80026e:	000d879b          	sext.w	a5,s11
  800272:	876a                	mv	a4,s10
  800274:	85ca                	mv	a1,s2
  800276:	8526                	mv	a0,s1
  800278:	e71ff0ef          	jal	8000e8 <printnum>
            break;
  80027c:	b719                	j	800182 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  80027e:	000a2503          	lw	a0,0(s4)
  800282:	85ca                	mv	a1,s2
  800284:	0a21                	addi	s4,s4,8
  800286:	9482                	jalr	s1
            break;
  800288:	bded                	j	800182 <vprintfmt+0x34>
    if (lflag >= 2) {
  80028a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80028c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800290:	00f74463          	blt	a4,a5,800298 <vprintfmt+0x14a>
    else if (lflag) {
  800294:	16078963          	beqz	a5,800406 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800298:	000a3603          	ld	a2,0(s4)
  80029c:	46a9                	li	a3,10
  80029e:	8a2e                	mv	s4,a1
  8002a0:	b7f9                	j	80026e <vprintfmt+0x120>
            putch('0', putdat);
  8002a2:	85ca                	mv	a1,s2
  8002a4:	03000513          	li	a0,48
  8002a8:	9482                	jalr	s1
            putch('x', putdat);
  8002aa:	85ca                	mv	a1,s2
  8002ac:	07800513          	li	a0,120
  8002b0:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002b2:	000a3603          	ld	a2,0(s4)
            goto number;
  8002b6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002b8:	0a21                	addi	s4,s4,8
            goto number;
  8002ba:	bf55                	j	80026e <vprintfmt+0x120>
            putch(ch, putdat);
  8002bc:	85ca                	mv	a1,s2
  8002be:	02500513          	li	a0,37
  8002c2:	9482                	jalr	s1
            break;
  8002c4:	bd7d                	j	800182 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002c6:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ca:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002cc:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002ce:	bf95                	j	800242 <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002d0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002d2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002d6:	00f74463          	blt	a4,a5,8002de <vprintfmt+0x190>
    else if (lflag) {
  8002da:	12078163          	beqz	a5,8003fc <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  8002de:	000a3603          	ld	a2,0(s4)
  8002e2:	46a1                	li	a3,8
  8002e4:	8a2e                	mv	s4,a1
  8002e6:	b761                	j	80026e <vprintfmt+0x120>
            if (width < 0)
  8002e8:	876a                	mv	a4,s10
  8002ea:	000d5363          	bgez	s10,8002f0 <vprintfmt+0x1a2>
  8002ee:	4701                	li	a4,0
  8002f0:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  8002f4:	8462                	mv	s0,s8
            goto reswitch;
  8002f6:	bd55                	j	8001aa <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  8002f8:	000d841b          	sext.w	s0,s11
  8002fc:	fd340793          	addi	a5,s0,-45
  800300:	00f037b3          	snez	a5,a5
  800304:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800308:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  80030c:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80030e:	008a0793          	addi	a5,s4,8
  800312:	e43e                	sd	a5,8(sp)
  800314:	100d8c63          	beqz	s11,80042c <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800318:	12071363          	bnez	a4,80043e <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80031c:	000dc783          	lbu	a5,0(s11)
  800320:	0007851b          	sext.w	a0,a5
  800324:	c78d                	beqz	a5,80034e <vprintfmt+0x200>
  800326:	0d85                	addi	s11,s11,1
  800328:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  80032a:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80032e:	000cc563          	bltz	s9,800338 <vprintfmt+0x1ea>
  800332:	3cfd                	addiw	s9,s9,-1
  800334:	008c8d63          	beq	s9,s0,80034e <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  800338:	020b9663          	bnez	s7,800364 <vprintfmt+0x216>
                    putch(ch, putdat);
  80033c:	85ca                	mv	a1,s2
  80033e:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800340:	000dc783          	lbu	a5,0(s11)
  800344:	0d85                	addi	s11,s11,1
  800346:	3d7d                	addiw	s10,s10,-1
  800348:	0007851b          	sext.w	a0,a5
  80034c:	f3ed                	bnez	a5,80032e <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  80034e:	01a05963          	blez	s10,800360 <vprintfmt+0x212>
                putch(' ', putdat);
  800352:	85ca                	mv	a1,s2
  800354:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800358:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  80035a:	9482                	jalr	s1
            for (; width > 0; width --) {
  80035c:	fe0d1be3          	bnez	s10,800352 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  800360:	6a22                	ld	s4,8(sp)
  800362:	b505                	j	800182 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  800364:	3781                	addiw	a5,a5,-32
  800366:	fcfa7be3          	bgeu	s4,a5,80033c <vprintfmt+0x1ee>
                    putch('?', putdat);
  80036a:	03f00513          	li	a0,63
  80036e:	85ca                	mv	a1,s2
  800370:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800372:	000dc783          	lbu	a5,0(s11)
  800376:	0d85                	addi	s11,s11,1
  800378:	3d7d                	addiw	s10,s10,-1
  80037a:	0007851b          	sext.w	a0,a5
  80037e:	dbe1                	beqz	a5,80034e <vprintfmt+0x200>
  800380:	fa0cd9e3          	bgez	s9,800332 <vprintfmt+0x1e4>
  800384:	b7c5                	j	800364 <vprintfmt+0x216>
            if (err < 0) {
  800386:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80038a:	4661                	li	a2,24
            err = va_arg(ap, int);
  80038c:	0a21                	addi	s4,s4,8
            if (err < 0) {
  80038e:	41f7d71b          	sraiw	a4,a5,0x1f
  800392:	8fb9                	xor	a5,a5,a4
  800394:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800398:	02d64563          	blt	a2,a3,8003c2 <vprintfmt+0x274>
  80039c:	00000797          	auipc	a5,0x0
  8003a0:	48478793          	addi	a5,a5,1156 # 800820 <error_string>
  8003a4:	00369713          	slli	a4,a3,0x3
  8003a8:	97ba                	add	a5,a5,a4
  8003aa:	639c                	ld	a5,0(a5)
  8003ac:	cb99                	beqz	a5,8003c2 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  8003ae:	86be                	mv	a3,a5
  8003b0:	00000617          	auipc	a2,0x0
  8003b4:	1d860613          	addi	a2,a2,472 # 800588 <main+0xb8>
  8003b8:	85ca                	mv	a1,s2
  8003ba:	8526                	mv	a0,s1
  8003bc:	0d8000ef          	jal	800494 <printfmt>
  8003c0:	b3c9                	j	800182 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003c2:	00000617          	auipc	a2,0x0
  8003c6:	1b660613          	addi	a2,a2,438 # 800578 <main+0xa8>
  8003ca:	85ca                	mv	a1,s2
  8003cc:	8526                	mv	a0,s1
  8003ce:	0c6000ef          	jal	800494 <printfmt>
  8003d2:	bb45                	j	800182 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003d4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003d6:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003da:	00f74363          	blt	a4,a5,8003e0 <vprintfmt+0x292>
    else if (lflag) {
  8003de:	cf81                	beqz	a5,8003f6 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  8003e0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003e4:	02044b63          	bltz	s0,80041a <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  8003e8:	8622                	mv	a2,s0
  8003ea:	8a5e                	mv	s4,s7
  8003ec:	46a9                	li	a3,10
  8003ee:	b541                	j	80026e <vprintfmt+0x120>
            lflag ++;
  8003f0:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003f2:	8462                	mv	s0,s8
            goto reswitch;
  8003f4:	bb5d                	j	8001aa <vprintfmt+0x5c>
        return va_arg(*ap, int);
  8003f6:	000a2403          	lw	s0,0(s4)
  8003fa:	b7ed                	j	8003e4 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  8003fc:	000a6603          	lwu	a2,0(s4)
  800400:	46a1                	li	a3,8
  800402:	8a2e                	mv	s4,a1
  800404:	b5ad                	j	80026e <vprintfmt+0x120>
  800406:	000a6603          	lwu	a2,0(s4)
  80040a:	46a9                	li	a3,10
  80040c:	8a2e                	mv	s4,a1
  80040e:	b585                	j	80026e <vprintfmt+0x120>
  800410:	000a6603          	lwu	a2,0(s4)
  800414:	46c1                	li	a3,16
  800416:	8a2e                	mv	s4,a1
  800418:	bd99                	j	80026e <vprintfmt+0x120>
                putch('-', putdat);
  80041a:	85ca                	mv	a1,s2
  80041c:	02d00513          	li	a0,45
  800420:	9482                	jalr	s1
                num = -(long long)num;
  800422:	40800633          	neg	a2,s0
  800426:	8a5e                	mv	s4,s7
  800428:	46a9                	li	a3,10
  80042a:	b591                	j	80026e <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  80042c:	e329                	bnez	a4,80046e <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80042e:	02800793          	li	a5,40
  800432:	853e                	mv	a0,a5
  800434:	00000d97          	auipc	s11,0x0
  800438:	135d8d93          	addi	s11,s11,309 # 800569 <main+0x99>
  80043c:	b5f5                	j	800328 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80043e:	85e6                	mv	a1,s9
  800440:	856e                	mv	a0,s11
  800442:	072000ef          	jal	8004b4 <strnlen>
  800446:	40ad0d3b          	subw	s10,s10,a0
  80044a:	01a05863          	blez	s10,80045a <vprintfmt+0x30c>
                    putch(padc, putdat);
  80044e:	85ca                	mv	a1,s2
  800450:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  800452:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  800454:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  800456:	fe0d1ce3          	bnez	s10,80044e <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80045a:	000dc783          	lbu	a5,0(s11)
  80045e:	0007851b          	sext.w	a0,a5
  800462:	ec0792e3          	bnez	a5,800326 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  800466:	6a22                	ld	s4,8(sp)
  800468:	bb29                	j	800182 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  80046a:	8462                	mv	s0,s8
  80046c:	bbd9                	j	800242 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80046e:	85e6                	mv	a1,s9
  800470:	00000517          	auipc	a0,0x0
  800474:	0f850513          	addi	a0,a0,248 # 800568 <main+0x98>
  800478:	03c000ef          	jal	8004b4 <strnlen>
  80047c:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800480:	02800793          	li	a5,40
                p = "(null)";
  800484:	00000d97          	auipc	s11,0x0
  800488:	0e4d8d93          	addi	s11,s11,228 # 800568 <main+0x98>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80048c:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  80048e:	fda040e3          	bgtz	s10,80044e <vprintfmt+0x300>
  800492:	bd51                	j	800326 <vprintfmt+0x1d8>

0000000000800494 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800494:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800496:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80049a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80049c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80049e:	ec06                	sd	ra,24(sp)
  8004a0:	f83a                	sd	a4,48(sp)
  8004a2:	fc3e                	sd	a5,56(sp)
  8004a4:	e0c2                	sd	a6,64(sp)
  8004a6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004a8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004aa:	ca5ff0ef          	jal	80014e <vprintfmt>
}
  8004ae:	60e2                	ld	ra,24(sp)
  8004b0:	6161                	addi	sp,sp,80
  8004b2:	8082                	ret

00000000008004b4 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004b4:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004b6:	e589                	bnez	a1,8004c0 <strnlen+0xc>
  8004b8:	a811                	j	8004cc <strnlen+0x18>
        cnt ++;
  8004ba:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004bc:	00f58863          	beq	a1,a5,8004cc <strnlen+0x18>
  8004c0:	00f50733          	add	a4,a0,a5
  8004c4:	00074703          	lbu	a4,0(a4)
  8004c8:	fb6d                	bnez	a4,8004ba <strnlen+0x6>
  8004ca:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004cc:	852e                	mv	a0,a1
  8004ce:	8082                	ret

00000000008004d0 <main>:
#include <ulib.h>
#include <stdio.h>

int
main(void) {
  8004d0:	1101                	addi	sp,sp,-32
  8004d2:	ec06                	sd	ra,24(sp)
  8004d4:	e822                	sd	s0,16(sp)
  8004d6:	e426                	sd	s1,8(sp)
    int i;
    cprintf("Hello, I am process %d.\n", getpid());
  8004d8:	c03ff0ef          	jal	8000da <getpid>
  8004dc:	85aa                	mv	a1,a0
  8004de:	00000517          	auipc	a0,0x0
  8004e2:	17250513          	addi	a0,a0,370 # 800650 <main+0x180>
  8004e6:	b59ff0ef          	jal	80003e <cprintf>
    for (i = 0; i < 5; i ++) {
  8004ea:	4401                	li	s0,0
  8004ec:	4495                	li	s1,5
        yield();
  8004ee:	bebff0ef          	jal	8000d8 <yield>
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  8004f2:	be9ff0ef          	jal	8000da <getpid>
  8004f6:	85aa                	mv	a1,a0
  8004f8:	8622                	mv	a2,s0
  8004fa:	00000517          	auipc	a0,0x0
  8004fe:	17650513          	addi	a0,a0,374 # 800670 <main+0x1a0>
    for (i = 0; i < 5; i ++) {
  800502:	2405                	addiw	s0,s0,1
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800504:	b3bff0ef          	jal	80003e <cprintf>
    for (i = 0; i < 5; i ++) {
  800508:	fe9413e3          	bne	s0,s1,8004ee <main+0x1e>
    }
    cprintf("All done in process %d.\n", getpid());
  80050c:	bcfff0ef          	jal	8000da <getpid>
  800510:	85aa                	mv	a1,a0
  800512:	00000517          	auipc	a0,0x0
  800516:	18650513          	addi	a0,a0,390 # 800698 <main+0x1c8>
  80051a:	b25ff0ef          	jal	80003e <cprintf>
    cprintf("yield pass.\n");
  80051e:	00000517          	auipc	a0,0x0
  800522:	19a50513          	addi	a0,a0,410 # 8006b8 <main+0x1e8>
  800526:	b19ff0ef          	jal	80003e <cprintf>
    return 0;
}
  80052a:	60e2                	ld	ra,24(sp)
  80052c:	6442                	ld	s0,16(sp)
  80052e:	64a2                	ld	s1,8(sp)
  800530:	4501                	li	a0,0
  800532:	6105                	addi	sp,sp,32
  800534:	8082                	ret
