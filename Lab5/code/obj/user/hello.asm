
obj/__user_hello.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0b6000ef          	jal	8000d6 <umain>
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
  80002c:	08c000ef          	jal	8000b8 <sys_putc>
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
  800066:	0e2000ef          	jal	800148 <vprintfmt>
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

00000000008000b4 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b4:	4549                	li	a0,18
  8000b6:	bf75                	j	800072 <syscall>

00000000008000b8 <sys_putc>:
}

int
sys_putc(int64_t c) {
  8000b8:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000ba:	4579                	li	a0,30
  8000bc:	bf5d                	j	800072 <syscall>

00000000008000be <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000be:	1141                	addi	sp,sp,-16
  8000c0:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c2:	fedff0ef          	jal	8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c6:	00000517          	auipc	a0,0x0
  8000ca:	43a50513          	addi	a0,a0,1082 # 800500 <main+0x36>
  8000ce:	f71ff0ef          	jal	80003e <cprintf>
    while (1);
  8000d2:	a001                	j	8000d2 <exit+0x14>

00000000008000d4 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000d4:	b7c5                	j	8000b4 <sys_getpid>

00000000008000d6 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d6:	1141                	addi	sp,sp,-16
  8000d8:	e406                	sd	ra,8(sp)
    int ret = main();
  8000da:	3f0000ef          	jal	8004ca <main>
    exit(ret);
  8000de:	fe1ff0ef          	jal	8000be <exit>

00000000008000e2 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  8000e2:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000e4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e8:	f022                	sd	s0,32(sp)
  8000ea:	ec26                	sd	s1,24(sp)
  8000ec:	e84a                	sd	s2,16(sp)
  8000ee:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000f0:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f4:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  8000f6:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8000fa:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  8000fe:	84aa                	mv	s1,a0
  800100:	892e                	mv	s2,a1
    if (num >= base) {
  800102:	03067d63          	bgeu	a2,a6,80013c <printnum+0x5a>
  800106:	e44e                	sd	s3,8(sp)
  800108:	89be                	mv	s3,a5
        while (-- width > 0)
  80010a:	4785                	li	a5,1
  80010c:	00e7d763          	bge	a5,a4,80011a <printnum+0x38>
            putch(padc, putdat);
  800110:	85ca                	mv	a1,s2
  800112:	854e                	mv	a0,s3
        while (-- width > 0)
  800114:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800116:	9482                	jalr	s1
        while (-- width > 0)
  800118:	fc65                	bnez	s0,800110 <printnum+0x2e>
  80011a:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80011c:	00000797          	auipc	a5,0x0
  800120:	3fc78793          	addi	a5,a5,1020 # 800518 <main+0x4e>
  800124:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800126:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800128:	0007c503          	lbu	a0,0(a5)
}
  80012c:	70a2                	ld	ra,40(sp)
  80012e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800130:	85ca                	mv	a1,s2
  800132:	87a6                	mv	a5,s1
}
  800134:	6942                	ld	s2,16(sp)
  800136:	64e2                	ld	s1,24(sp)
  800138:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80013a:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  80013c:	03065633          	divu	a2,a2,a6
  800140:	8722                	mv	a4,s0
  800142:	fa1ff0ef          	jal	8000e2 <printnum>
  800146:	bfd9                	j	80011c <printnum+0x3a>

0000000000800148 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800148:	7119                	addi	sp,sp,-128
  80014a:	f4a6                	sd	s1,104(sp)
  80014c:	f0ca                	sd	s2,96(sp)
  80014e:	ecce                	sd	s3,88(sp)
  800150:	e8d2                	sd	s4,80(sp)
  800152:	e4d6                	sd	s5,72(sp)
  800154:	e0da                	sd	s6,64(sp)
  800156:	f862                	sd	s8,48(sp)
  800158:	fc86                	sd	ra,120(sp)
  80015a:	f8a2                	sd	s0,112(sp)
  80015c:	fc5e                	sd	s7,56(sp)
  80015e:	f466                	sd	s9,40(sp)
  800160:	f06a                	sd	s10,32(sp)
  800162:	ec6e                	sd	s11,24(sp)
  800164:	84aa                	mv	s1,a0
  800166:	8c32                	mv	s8,a2
  800168:	8a36                	mv	s4,a3
  80016a:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80016c:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800170:	05500b13          	li	s6,85
  800174:	00000a97          	auipc	s5,0x0
  800178:	4dca8a93          	addi	s5,s5,1244 # 800650 <main+0x186>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80017c:	000c4503          	lbu	a0,0(s8)
  800180:	001c0413          	addi	s0,s8,1
  800184:	01350a63          	beq	a0,s3,800198 <vprintfmt+0x50>
            if (ch == '\0') {
  800188:	cd0d                	beqz	a0,8001c2 <vprintfmt+0x7a>
            putch(ch, putdat);
  80018a:	85ca                	mv	a1,s2
  80018c:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80018e:	00044503          	lbu	a0,0(s0)
  800192:	0405                	addi	s0,s0,1
  800194:	ff351ae3          	bne	a0,s3,800188 <vprintfmt+0x40>
        width = precision = -1;
  800198:	5cfd                	li	s9,-1
  80019a:	8d66                	mv	s10,s9
        char padc = ' ';
  80019c:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001a0:	4b81                	li	s7,0
  8001a2:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  8001a4:	00044683          	lbu	a3,0(s0)
  8001a8:	00140c13          	addi	s8,s0,1
  8001ac:	fdd6859b          	addiw	a1,a3,-35
  8001b0:	0ff5f593          	zext.b	a1,a1
  8001b4:	02bb6663          	bltu	s6,a1,8001e0 <vprintfmt+0x98>
  8001b8:	058a                	slli	a1,a1,0x2
  8001ba:	95d6                	add	a1,a1,s5
  8001bc:	4198                	lw	a4,0(a1)
  8001be:	9756                	add	a4,a4,s5
  8001c0:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001c2:	70e6                	ld	ra,120(sp)
  8001c4:	7446                	ld	s0,112(sp)
  8001c6:	74a6                	ld	s1,104(sp)
  8001c8:	7906                	ld	s2,96(sp)
  8001ca:	69e6                	ld	s3,88(sp)
  8001cc:	6a46                	ld	s4,80(sp)
  8001ce:	6aa6                	ld	s5,72(sp)
  8001d0:	6b06                	ld	s6,64(sp)
  8001d2:	7be2                	ld	s7,56(sp)
  8001d4:	7c42                	ld	s8,48(sp)
  8001d6:	7ca2                	ld	s9,40(sp)
  8001d8:	7d02                	ld	s10,32(sp)
  8001da:	6de2                	ld	s11,24(sp)
  8001dc:	6109                	addi	sp,sp,128
  8001de:	8082                	ret
            putch('%', putdat);
  8001e0:	85ca                	mv	a1,s2
  8001e2:	02500513          	li	a0,37
  8001e6:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  8001e8:	fff44783          	lbu	a5,-1(s0)
  8001ec:	02500713          	li	a4,37
  8001f0:	8c22                	mv	s8,s0
  8001f2:	f8e785e3          	beq	a5,a4,80017c <vprintfmt+0x34>
  8001f6:	ffec4783          	lbu	a5,-2(s8)
  8001fa:	1c7d                	addi	s8,s8,-1
  8001fc:	fee79de3          	bne	a5,a4,8001f6 <vprintfmt+0xae>
  800200:	bfb5                	j	80017c <vprintfmt+0x34>
                ch = *fmt;
  800202:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800206:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800208:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80020c:	fd06071b          	addiw	a4,a2,-48
  800210:	24e56a63          	bltu	a0,a4,800464 <vprintfmt+0x31c>
                ch = *fmt;
  800214:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800216:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800218:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  80021c:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800220:	0197073b          	addw	a4,a4,s9
  800224:	0017171b          	slliw	a4,a4,0x1
  800228:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  80022a:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  80022e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800230:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800234:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  800238:	feb570e3          	bgeu	a0,a1,800218 <vprintfmt+0xd0>
            if (width < 0)
  80023c:	f60d54e3          	bgez	s10,8001a4 <vprintfmt+0x5c>
                width = precision, precision = -1;
  800240:	8d66                	mv	s10,s9
  800242:	5cfd                	li	s9,-1
  800244:	b785                	j	8001a4 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800246:	8db6                	mv	s11,a3
  800248:	8462                	mv	s0,s8
  80024a:	bfa9                	j	8001a4 <vprintfmt+0x5c>
  80024c:	8462                	mv	s0,s8
            altflag = 1;
  80024e:	4b85                	li	s7,1
            goto reswitch;
  800250:	bf91                	j	8001a4 <vprintfmt+0x5c>
    if (lflag >= 2) {
  800252:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800254:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800258:	00f74463          	blt	a4,a5,800260 <vprintfmt+0x118>
    else if (lflag) {
  80025c:	1a078763          	beqz	a5,80040a <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  800260:	000a3603          	ld	a2,0(s4)
  800264:	46c1                	li	a3,16
  800266:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800268:	000d879b          	sext.w	a5,s11
  80026c:	876a                	mv	a4,s10
  80026e:	85ca                	mv	a1,s2
  800270:	8526                	mv	a0,s1
  800272:	e71ff0ef          	jal	8000e2 <printnum>
            break;
  800276:	b719                	j	80017c <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800278:	000a2503          	lw	a0,0(s4)
  80027c:	85ca                	mv	a1,s2
  80027e:	0a21                	addi	s4,s4,8
  800280:	9482                	jalr	s1
            break;
  800282:	bded                	j	80017c <vprintfmt+0x34>
    if (lflag >= 2) {
  800284:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800286:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80028a:	00f74463          	blt	a4,a5,800292 <vprintfmt+0x14a>
    else if (lflag) {
  80028e:	16078963          	beqz	a5,800400 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800292:	000a3603          	ld	a2,0(s4)
  800296:	46a9                	li	a3,10
  800298:	8a2e                	mv	s4,a1
  80029a:	b7f9                	j	800268 <vprintfmt+0x120>
            putch('0', putdat);
  80029c:	85ca                	mv	a1,s2
  80029e:	03000513          	li	a0,48
  8002a2:	9482                	jalr	s1
            putch('x', putdat);
  8002a4:	85ca                	mv	a1,s2
  8002a6:	07800513          	li	a0,120
  8002aa:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002ac:	000a3603          	ld	a2,0(s4)
            goto number;
  8002b0:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002b2:	0a21                	addi	s4,s4,8
            goto number;
  8002b4:	bf55                	j	800268 <vprintfmt+0x120>
            putch(ch, putdat);
  8002b6:	85ca                	mv	a1,s2
  8002b8:	02500513          	li	a0,37
  8002bc:	9482                	jalr	s1
            break;
  8002be:	bd7d                	j	80017c <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002c0:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002c4:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002c6:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002c8:	bf95                	j	80023c <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002ca:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002cc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002d0:	00f74463          	blt	a4,a5,8002d8 <vprintfmt+0x190>
    else if (lflag) {
  8002d4:	12078163          	beqz	a5,8003f6 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  8002d8:	000a3603          	ld	a2,0(s4)
  8002dc:	46a1                	li	a3,8
  8002de:	8a2e                	mv	s4,a1
  8002e0:	b761                	j	800268 <vprintfmt+0x120>
            if (width < 0)
  8002e2:	876a                	mv	a4,s10
  8002e4:	000d5363          	bgez	s10,8002ea <vprintfmt+0x1a2>
  8002e8:	4701                	li	a4,0
  8002ea:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  8002ee:	8462                	mv	s0,s8
            goto reswitch;
  8002f0:	bd55                	j	8001a4 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  8002f2:	000d841b          	sext.w	s0,s11
  8002f6:	fd340793          	addi	a5,s0,-45
  8002fa:	00f037b3          	snez	a5,a5
  8002fe:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800302:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800306:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800308:	008a0793          	addi	a5,s4,8
  80030c:	e43e                	sd	a5,8(sp)
  80030e:	100d8c63          	beqz	s11,800426 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800312:	12071363          	bnez	a4,800438 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800316:	000dc783          	lbu	a5,0(s11)
  80031a:	0007851b          	sext.w	a0,a5
  80031e:	c78d                	beqz	a5,800348 <vprintfmt+0x200>
  800320:	0d85                	addi	s11,s11,1
  800322:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800324:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800328:	000cc563          	bltz	s9,800332 <vprintfmt+0x1ea>
  80032c:	3cfd                	addiw	s9,s9,-1
  80032e:	008c8d63          	beq	s9,s0,800348 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  800332:	020b9663          	bnez	s7,80035e <vprintfmt+0x216>
                    putch(ch, putdat);
  800336:	85ca                	mv	a1,s2
  800338:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80033a:	000dc783          	lbu	a5,0(s11)
  80033e:	0d85                	addi	s11,s11,1
  800340:	3d7d                	addiw	s10,s10,-1
  800342:	0007851b          	sext.w	a0,a5
  800346:	f3ed                	bnez	a5,800328 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  800348:	01a05963          	blez	s10,80035a <vprintfmt+0x212>
                putch(' ', putdat);
  80034c:	85ca                	mv	a1,s2
  80034e:	02000513          	li	a0,32
            for (; width > 0; width --) {
  800352:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  800354:	9482                	jalr	s1
            for (; width > 0; width --) {
  800356:	fe0d1be3          	bnez	s10,80034c <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  80035a:	6a22                	ld	s4,8(sp)
  80035c:	b505                	j	80017c <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  80035e:	3781                	addiw	a5,a5,-32
  800360:	fcfa7be3          	bgeu	s4,a5,800336 <vprintfmt+0x1ee>
                    putch('?', putdat);
  800364:	03f00513          	li	a0,63
  800368:	85ca                	mv	a1,s2
  80036a:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80036c:	000dc783          	lbu	a5,0(s11)
  800370:	0d85                	addi	s11,s11,1
  800372:	3d7d                	addiw	s10,s10,-1
  800374:	0007851b          	sext.w	a0,a5
  800378:	dbe1                	beqz	a5,800348 <vprintfmt+0x200>
  80037a:	fa0cd9e3          	bgez	s9,80032c <vprintfmt+0x1e4>
  80037e:	b7c5                	j	80035e <vprintfmt+0x216>
            if (err < 0) {
  800380:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800384:	4661                	li	a2,24
            err = va_arg(ap, int);
  800386:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800388:	41f7d71b          	sraiw	a4,a5,0x1f
  80038c:	8fb9                	xor	a5,a5,a4
  80038e:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800392:	02d64563          	blt	a2,a3,8003bc <vprintfmt+0x274>
  800396:	00000797          	auipc	a5,0x0
  80039a:	41278793          	addi	a5,a5,1042 # 8007a8 <error_string>
  80039e:	00369713          	slli	a4,a3,0x3
  8003a2:	97ba                	add	a5,a5,a4
  8003a4:	639c                	ld	a5,0(a5)
  8003a6:	cb99                	beqz	a5,8003bc <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  8003a8:	86be                	mv	a3,a5
  8003aa:	00000617          	auipc	a2,0x0
  8003ae:	1a660613          	addi	a2,a2,422 # 800550 <main+0x86>
  8003b2:	85ca                	mv	a1,s2
  8003b4:	8526                	mv	a0,s1
  8003b6:	0d8000ef          	jal	80048e <printfmt>
  8003ba:	b3c9                	j	80017c <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003bc:	00000617          	auipc	a2,0x0
  8003c0:	18460613          	addi	a2,a2,388 # 800540 <main+0x76>
  8003c4:	85ca                	mv	a1,s2
  8003c6:	8526                	mv	a0,s1
  8003c8:	0c6000ef          	jal	80048e <printfmt>
  8003cc:	bb45                	j	80017c <vprintfmt+0x34>
    if (lflag >= 2) {
  8003ce:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003d0:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003d4:	00f74363          	blt	a4,a5,8003da <vprintfmt+0x292>
    else if (lflag) {
  8003d8:	cf81                	beqz	a5,8003f0 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  8003da:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003de:	02044b63          	bltz	s0,800414 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  8003e2:	8622                	mv	a2,s0
  8003e4:	8a5e                	mv	s4,s7
  8003e6:	46a9                	li	a3,10
  8003e8:	b541                	j	800268 <vprintfmt+0x120>
            lflag ++;
  8003ea:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003ec:	8462                	mv	s0,s8
            goto reswitch;
  8003ee:	bb5d                	j	8001a4 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  8003f0:	000a2403          	lw	s0,0(s4)
  8003f4:	b7ed                	j	8003de <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  8003f6:	000a6603          	lwu	a2,0(s4)
  8003fa:	46a1                	li	a3,8
  8003fc:	8a2e                	mv	s4,a1
  8003fe:	b5ad                	j	800268 <vprintfmt+0x120>
  800400:	000a6603          	lwu	a2,0(s4)
  800404:	46a9                	li	a3,10
  800406:	8a2e                	mv	s4,a1
  800408:	b585                	j	800268 <vprintfmt+0x120>
  80040a:	000a6603          	lwu	a2,0(s4)
  80040e:	46c1                	li	a3,16
  800410:	8a2e                	mv	s4,a1
  800412:	bd99                	j	800268 <vprintfmt+0x120>
                putch('-', putdat);
  800414:	85ca                	mv	a1,s2
  800416:	02d00513          	li	a0,45
  80041a:	9482                	jalr	s1
                num = -(long long)num;
  80041c:	40800633          	neg	a2,s0
  800420:	8a5e                	mv	s4,s7
  800422:	46a9                	li	a3,10
  800424:	b591                	j	800268 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800426:	e329                	bnez	a4,800468 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800428:	02800793          	li	a5,40
  80042c:	853e                	mv	a0,a5
  80042e:	00000d97          	auipc	s11,0x0
  800432:	103d8d93          	addi	s11,s11,259 # 800531 <main+0x67>
  800436:	b5f5                	j	800322 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800438:	85e6                	mv	a1,s9
  80043a:	856e                	mv	a0,s11
  80043c:	072000ef          	jal	8004ae <strnlen>
  800440:	40ad0d3b          	subw	s10,s10,a0
  800444:	01a05863          	blez	s10,800454 <vprintfmt+0x30c>
                    putch(padc, putdat);
  800448:	85ca                	mv	a1,s2
  80044a:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  80044c:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  80044e:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  800450:	fe0d1ce3          	bnez	s10,800448 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800454:	000dc783          	lbu	a5,0(s11)
  800458:	0007851b          	sext.w	a0,a5
  80045c:	ec0792e3          	bnez	a5,800320 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  800460:	6a22                	ld	s4,8(sp)
  800462:	bb29                	j	80017c <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  800464:	8462                	mv	s0,s8
  800466:	bbd9                	j	80023c <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800468:	85e6                	mv	a1,s9
  80046a:	00000517          	auipc	a0,0x0
  80046e:	0c650513          	addi	a0,a0,198 # 800530 <main+0x66>
  800472:	03c000ef          	jal	8004ae <strnlen>
  800476:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80047a:	02800793          	li	a5,40
                p = "(null)";
  80047e:	00000d97          	auipc	s11,0x0
  800482:	0b2d8d93          	addi	s11,s11,178 # 800530 <main+0x66>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800486:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800488:	fda040e3          	bgtz	s10,800448 <vprintfmt+0x300>
  80048c:	bd51                	j	800320 <vprintfmt+0x1d8>

000000000080048e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80048e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800490:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800494:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800496:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800498:	ec06                	sd	ra,24(sp)
  80049a:	f83a                	sd	a4,48(sp)
  80049c:	fc3e                	sd	a5,56(sp)
  80049e:	e0c2                	sd	a6,64(sp)
  8004a0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004a2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004a4:	ca5ff0ef          	jal	800148 <vprintfmt>
}
  8004a8:	60e2                	ld	ra,24(sp)
  8004aa:	6161                	addi	sp,sp,80
  8004ac:	8082                	ret

00000000008004ae <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004ae:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004b0:	e589                	bnez	a1,8004ba <strnlen+0xc>
  8004b2:	a811                	j	8004c6 <strnlen+0x18>
        cnt ++;
  8004b4:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004b6:	00f58863          	beq	a1,a5,8004c6 <strnlen+0x18>
  8004ba:	00f50733          	add	a4,a0,a5
  8004be:	00074703          	lbu	a4,0(a4)
  8004c2:	fb6d                	bnez	a4,8004b4 <strnlen+0x6>
  8004c4:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004c6:	852e                	mv	a0,a1
  8004c8:	8082                	ret

00000000008004ca <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004ca:	1141                	addi	sp,sp,-16
    cprintf("Hello world!!.\n");
  8004cc:	00000517          	auipc	a0,0x0
  8004d0:	14c50513          	addi	a0,a0,332 # 800618 <main+0x14e>
main(void) {
  8004d4:	e406                	sd	ra,8(sp)
    cprintf("Hello world!!.\n");
  8004d6:	b69ff0ef          	jal	80003e <cprintf>
    cprintf("I am process %d.\n", getpid());
  8004da:	bfbff0ef          	jal	8000d4 <getpid>
  8004de:	85aa                	mv	a1,a0
  8004e0:	00000517          	auipc	a0,0x0
  8004e4:	14850513          	addi	a0,a0,328 # 800628 <main+0x15e>
  8004e8:	b57ff0ef          	jal	80003e <cprintf>
    cprintf("hello pass.\n");
  8004ec:	00000517          	auipc	a0,0x0
  8004f0:	15450513          	addi	a0,a0,340 # 800640 <main+0x176>
  8004f4:	b4bff0ef          	jal	80003e <cprintf>
    return 0;
}
  8004f8:	60a2                	ld	ra,8(sp)
  8004fa:	4501                	li	a0,0
  8004fc:	0141                	addi	sp,sp,16
  8004fe:	8082                	ret
