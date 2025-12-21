
obj/__user_softint.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0b0000ef          	jal	8000d0 <umain>
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
  80002c:	088000ef          	jal	8000b4 <sys_putc>
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
  800066:	0dc000ef          	jal	800142 <vprintfmt>
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

00000000008000b4 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  8000b4:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  8000b6:	4579                	li	a0,30
  8000b8:	bf6d                	j	800072 <syscall>

00000000008000ba <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000ba:	1141                	addi	sp,sp,-16
  8000bc:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000be:	ff1ff0ef          	jal	8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c2:	00000517          	auipc	a0,0x0
  8000c6:	40e50513          	addi	a0,a0,1038 # 8004d0 <main+0xc>
  8000ca:	f75ff0ef          	jal	80003e <cprintf>
    while (1);
  8000ce:	a001                	j	8000ce <exit+0x14>

00000000008000d0 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d0:	1141                	addi	sp,sp,-16
  8000d2:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d4:	3f0000ef          	jal	8004c4 <main>
    exit(ret);
  8000d8:	fe3ff0ef          	jal	8000ba <exit>

00000000008000dc <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  8000dc:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000de:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e2:	f022                	sd	s0,32(sp)
  8000e4:	ec26                	sd	s1,24(sp)
  8000e6:	e84a                	sd	s2,16(sp)
  8000e8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000ea:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ee:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  8000f0:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  8000f4:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  8000f8:	84aa                	mv	s1,a0
  8000fa:	892e                	mv	s2,a1
    if (num >= base) {
  8000fc:	03067d63          	bgeu	a2,a6,800136 <printnum+0x5a>
  800100:	e44e                	sd	s3,8(sp)
  800102:	89be                	mv	s3,a5
        while (-- width > 0)
  800104:	4785                	li	a5,1
  800106:	00e7d763          	bge	a5,a4,800114 <printnum+0x38>
            putch(padc, putdat);
  80010a:	85ca                	mv	a1,s2
  80010c:	854e                	mv	a0,s3
        while (-- width > 0)
  80010e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800110:	9482                	jalr	s1
        while (-- width > 0)
  800112:	fc65                	bnez	s0,80010a <printnum+0x2e>
  800114:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800116:	00000797          	auipc	a5,0x0
  80011a:	3d278793          	addi	a5,a5,978 # 8004e8 <main+0x24>
  80011e:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800120:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800122:	0007c503          	lbu	a0,0(a5)
}
  800126:	70a2                	ld	ra,40(sp)
  800128:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80012a:	85ca                	mv	a1,s2
  80012c:	87a6                	mv	a5,s1
}
  80012e:	6942                	ld	s2,16(sp)
  800130:	64e2                	ld	s1,24(sp)
  800132:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800134:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800136:	03065633          	divu	a2,a2,a6
  80013a:	8722                	mv	a4,s0
  80013c:	fa1ff0ef          	jal	8000dc <printnum>
  800140:	bfd9                	j	800116 <printnum+0x3a>

0000000000800142 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800142:	7119                	addi	sp,sp,-128
  800144:	f4a6                	sd	s1,104(sp)
  800146:	f0ca                	sd	s2,96(sp)
  800148:	ecce                	sd	s3,88(sp)
  80014a:	e8d2                	sd	s4,80(sp)
  80014c:	e4d6                	sd	s5,72(sp)
  80014e:	e0da                	sd	s6,64(sp)
  800150:	f862                	sd	s8,48(sp)
  800152:	fc86                	sd	ra,120(sp)
  800154:	f8a2                	sd	s0,112(sp)
  800156:	fc5e                	sd	s7,56(sp)
  800158:	f466                	sd	s9,40(sp)
  80015a:	f06a                	sd	s10,32(sp)
  80015c:	ec6e                	sd	s11,24(sp)
  80015e:	84aa                	mv	s1,a0
  800160:	8c32                	mv	s8,a2
  800162:	8a36                	mv	s4,a3
  800164:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800166:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80016a:	05500b13          	li	s6,85
  80016e:	00000a97          	auipc	s5,0x0
  800172:	47aa8a93          	addi	s5,s5,1146 # 8005e8 <main+0x124>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800176:	000c4503          	lbu	a0,0(s8)
  80017a:	001c0413          	addi	s0,s8,1
  80017e:	01350a63          	beq	a0,s3,800192 <vprintfmt+0x50>
            if (ch == '\0') {
  800182:	cd0d                	beqz	a0,8001bc <vprintfmt+0x7a>
            putch(ch, putdat);
  800184:	85ca                	mv	a1,s2
  800186:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800188:	00044503          	lbu	a0,0(s0)
  80018c:	0405                	addi	s0,s0,1
  80018e:	ff351ae3          	bne	a0,s3,800182 <vprintfmt+0x40>
        width = precision = -1;
  800192:	5cfd                	li	s9,-1
  800194:	8d66                	mv	s10,s9
        char padc = ' ';
  800196:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80019a:	4b81                	li	s7,0
  80019c:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  80019e:	00044683          	lbu	a3,0(s0)
  8001a2:	00140c13          	addi	s8,s0,1
  8001a6:	fdd6859b          	addiw	a1,a3,-35
  8001aa:	0ff5f593          	zext.b	a1,a1
  8001ae:	02bb6663          	bltu	s6,a1,8001da <vprintfmt+0x98>
  8001b2:	058a                	slli	a1,a1,0x2
  8001b4:	95d6                	add	a1,a1,s5
  8001b6:	4198                	lw	a4,0(a1)
  8001b8:	9756                	add	a4,a4,s5
  8001ba:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001bc:	70e6                	ld	ra,120(sp)
  8001be:	7446                	ld	s0,112(sp)
  8001c0:	74a6                	ld	s1,104(sp)
  8001c2:	7906                	ld	s2,96(sp)
  8001c4:	69e6                	ld	s3,88(sp)
  8001c6:	6a46                	ld	s4,80(sp)
  8001c8:	6aa6                	ld	s5,72(sp)
  8001ca:	6b06                	ld	s6,64(sp)
  8001cc:	7be2                	ld	s7,56(sp)
  8001ce:	7c42                	ld	s8,48(sp)
  8001d0:	7ca2                	ld	s9,40(sp)
  8001d2:	7d02                	ld	s10,32(sp)
  8001d4:	6de2                	ld	s11,24(sp)
  8001d6:	6109                	addi	sp,sp,128
  8001d8:	8082                	ret
            putch('%', putdat);
  8001da:	85ca                	mv	a1,s2
  8001dc:	02500513          	li	a0,37
  8001e0:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  8001e2:	fff44783          	lbu	a5,-1(s0)
  8001e6:	02500713          	li	a4,37
  8001ea:	8c22                	mv	s8,s0
  8001ec:	f8e785e3          	beq	a5,a4,800176 <vprintfmt+0x34>
  8001f0:	ffec4783          	lbu	a5,-2(s8)
  8001f4:	1c7d                	addi	s8,s8,-1
  8001f6:	fee79de3          	bne	a5,a4,8001f0 <vprintfmt+0xae>
  8001fa:	bfb5                	j	800176 <vprintfmt+0x34>
                ch = *fmt;
  8001fc:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800200:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800202:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800206:	fd06071b          	addiw	a4,a2,-48
  80020a:	24e56a63          	bltu	a0,a4,80045e <vprintfmt+0x31c>
                ch = *fmt;
  80020e:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800210:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800212:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800216:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  80021a:	0197073b          	addw	a4,a4,s9
  80021e:	0017171b          	slliw	a4,a4,0x1
  800222:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  800224:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  800228:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80022a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80022e:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  800232:	feb570e3          	bgeu	a0,a1,800212 <vprintfmt+0xd0>
            if (width < 0)
  800236:	f60d54e3          	bgez	s10,80019e <vprintfmt+0x5c>
                width = precision, precision = -1;
  80023a:	8d66                	mv	s10,s9
  80023c:	5cfd                	li	s9,-1
  80023e:	b785                	j	80019e <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  800240:	8db6                	mv	s11,a3
  800242:	8462                	mv	s0,s8
  800244:	bfa9                	j	80019e <vprintfmt+0x5c>
  800246:	8462                	mv	s0,s8
            altflag = 1;
  800248:	4b85                	li	s7,1
            goto reswitch;
  80024a:	bf91                	j	80019e <vprintfmt+0x5c>
    if (lflag >= 2) {
  80024c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80024e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800252:	00f74463          	blt	a4,a5,80025a <vprintfmt+0x118>
    else if (lflag) {
  800256:	1a078763          	beqz	a5,800404 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  80025a:	000a3603          	ld	a2,0(s4)
  80025e:	46c1                	li	a3,16
  800260:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  800262:	000d879b          	sext.w	a5,s11
  800266:	876a                	mv	a4,s10
  800268:	85ca                	mv	a1,s2
  80026a:	8526                	mv	a0,s1
  80026c:	e71ff0ef          	jal	8000dc <printnum>
            break;
  800270:	b719                	j	800176 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  800272:	000a2503          	lw	a0,0(s4)
  800276:	85ca                	mv	a1,s2
  800278:	0a21                	addi	s4,s4,8
  80027a:	9482                	jalr	s1
            break;
  80027c:	bded                	j	800176 <vprintfmt+0x34>
    if (lflag >= 2) {
  80027e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800280:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800284:	00f74463          	blt	a4,a5,80028c <vprintfmt+0x14a>
    else if (lflag) {
  800288:	16078963          	beqz	a5,8003fa <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  80028c:	000a3603          	ld	a2,0(s4)
  800290:	46a9                	li	a3,10
  800292:	8a2e                	mv	s4,a1
  800294:	b7f9                	j	800262 <vprintfmt+0x120>
            putch('0', putdat);
  800296:	85ca                	mv	a1,s2
  800298:	03000513          	li	a0,48
  80029c:	9482                	jalr	s1
            putch('x', putdat);
  80029e:	85ca                	mv	a1,s2
  8002a0:	07800513          	li	a0,120
  8002a4:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002a6:	000a3603          	ld	a2,0(s4)
            goto number;
  8002aa:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8002ac:	0a21                	addi	s4,s4,8
            goto number;
  8002ae:	bf55                	j	800262 <vprintfmt+0x120>
            putch(ch, putdat);
  8002b0:	85ca                	mv	a1,s2
  8002b2:	02500513          	li	a0,37
  8002b6:	9482                	jalr	s1
            break;
  8002b8:	bd7d                	j	800176 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  8002ba:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  8002be:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  8002c0:	0a21                	addi	s4,s4,8
            goto process_precision;
  8002c2:	bf95                	j	800236 <vprintfmt+0xf4>
    if (lflag >= 2) {
  8002c4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002c6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ca:	00f74463          	blt	a4,a5,8002d2 <vprintfmt+0x190>
    else if (lflag) {
  8002ce:	12078163          	beqz	a5,8003f0 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  8002d2:	000a3603          	ld	a2,0(s4)
  8002d6:	46a1                	li	a3,8
  8002d8:	8a2e                	mv	s4,a1
  8002da:	b761                	j	800262 <vprintfmt+0x120>
            if (width < 0)
  8002dc:	876a                	mv	a4,s10
  8002de:	000d5363          	bgez	s10,8002e4 <vprintfmt+0x1a2>
  8002e2:	4701                	li	a4,0
  8002e4:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  8002e8:	8462                	mv	s0,s8
            goto reswitch;
  8002ea:	bd55                	j	80019e <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  8002ec:	000d841b          	sext.w	s0,s11
  8002f0:	fd340793          	addi	a5,s0,-45
  8002f4:	00f037b3          	snez	a5,a5
  8002f8:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  8002fc:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800300:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800302:	008a0793          	addi	a5,s4,8
  800306:	e43e                	sd	a5,8(sp)
  800308:	100d8c63          	beqz	s11,800420 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80030c:	12071363          	bnez	a4,800432 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800310:	000dc783          	lbu	a5,0(s11)
  800314:	0007851b          	sext.w	a0,a5
  800318:	c78d                	beqz	a5,800342 <vprintfmt+0x200>
  80031a:	0d85                	addi	s11,s11,1
  80031c:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  80031e:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800322:	000cc563          	bltz	s9,80032c <vprintfmt+0x1ea>
  800326:	3cfd                	addiw	s9,s9,-1
  800328:	008c8d63          	beq	s9,s0,800342 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  80032c:	020b9663          	bnez	s7,800358 <vprintfmt+0x216>
                    putch(ch, putdat);
  800330:	85ca                	mv	a1,s2
  800332:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800334:	000dc783          	lbu	a5,0(s11)
  800338:	0d85                	addi	s11,s11,1
  80033a:	3d7d                	addiw	s10,s10,-1
  80033c:	0007851b          	sext.w	a0,a5
  800340:	f3ed                	bnez	a5,800322 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  800342:	01a05963          	blez	s10,800354 <vprintfmt+0x212>
                putch(' ', putdat);
  800346:	85ca                	mv	a1,s2
  800348:	02000513          	li	a0,32
            for (; width > 0; width --) {
  80034c:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  80034e:	9482                	jalr	s1
            for (; width > 0; width --) {
  800350:	fe0d1be3          	bnez	s10,800346 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  800354:	6a22                	ld	s4,8(sp)
  800356:	b505                	j	800176 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  800358:	3781                	addiw	a5,a5,-32
  80035a:	fcfa7be3          	bgeu	s4,a5,800330 <vprintfmt+0x1ee>
                    putch('?', putdat);
  80035e:	03f00513          	li	a0,63
  800362:	85ca                	mv	a1,s2
  800364:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800366:	000dc783          	lbu	a5,0(s11)
  80036a:	0d85                	addi	s11,s11,1
  80036c:	3d7d                	addiw	s10,s10,-1
  80036e:	0007851b          	sext.w	a0,a5
  800372:	dbe1                	beqz	a5,800342 <vprintfmt+0x200>
  800374:	fa0cd9e3          	bgez	s9,800326 <vprintfmt+0x1e4>
  800378:	b7c5                	j	800358 <vprintfmt+0x216>
            if (err < 0) {
  80037a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80037e:	4661                	li	a2,24
            err = va_arg(ap, int);
  800380:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800382:	41f7d71b          	sraiw	a4,a5,0x1f
  800386:	8fb9                	xor	a5,a5,a4
  800388:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80038c:	02d64563          	blt	a2,a3,8003b6 <vprintfmt+0x274>
  800390:	00000797          	auipc	a5,0x0
  800394:	3b078793          	addi	a5,a5,944 # 800740 <error_string>
  800398:	00369713          	slli	a4,a3,0x3
  80039c:	97ba                	add	a5,a5,a4
  80039e:	639c                	ld	a5,0(a5)
  8003a0:	cb99                	beqz	a5,8003b6 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  8003a2:	86be                	mv	a3,a5
  8003a4:	00000617          	auipc	a2,0x0
  8003a8:	17c60613          	addi	a2,a2,380 # 800520 <main+0x5c>
  8003ac:	85ca                	mv	a1,s2
  8003ae:	8526                	mv	a0,s1
  8003b0:	0d8000ef          	jal	800488 <printfmt>
  8003b4:	b3c9                	j	800176 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  8003b6:	00000617          	auipc	a2,0x0
  8003ba:	15a60613          	addi	a2,a2,346 # 800510 <main+0x4c>
  8003be:	85ca                	mv	a1,s2
  8003c0:	8526                	mv	a0,s1
  8003c2:	0c6000ef          	jal	800488 <printfmt>
  8003c6:	bb45                	j	800176 <vprintfmt+0x34>
    if (lflag >= 2) {
  8003c8:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8003ca:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  8003ce:	00f74363          	blt	a4,a5,8003d4 <vprintfmt+0x292>
    else if (lflag) {
  8003d2:	cf81                	beqz	a5,8003ea <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  8003d4:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  8003d8:	02044b63          	bltz	s0,80040e <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  8003dc:	8622                	mv	a2,s0
  8003de:	8a5e                	mv	s4,s7
  8003e0:	46a9                	li	a3,10
  8003e2:	b541                	j	800262 <vprintfmt+0x120>
            lflag ++;
  8003e4:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003e6:	8462                	mv	s0,s8
            goto reswitch;
  8003e8:	bb5d                	j	80019e <vprintfmt+0x5c>
        return va_arg(*ap, int);
  8003ea:	000a2403          	lw	s0,0(s4)
  8003ee:	b7ed                	j	8003d8 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  8003f0:	000a6603          	lwu	a2,0(s4)
  8003f4:	46a1                	li	a3,8
  8003f6:	8a2e                	mv	s4,a1
  8003f8:	b5ad                	j	800262 <vprintfmt+0x120>
  8003fa:	000a6603          	lwu	a2,0(s4)
  8003fe:	46a9                	li	a3,10
  800400:	8a2e                	mv	s4,a1
  800402:	b585                	j	800262 <vprintfmt+0x120>
  800404:	000a6603          	lwu	a2,0(s4)
  800408:	46c1                	li	a3,16
  80040a:	8a2e                	mv	s4,a1
  80040c:	bd99                	j	800262 <vprintfmt+0x120>
                putch('-', putdat);
  80040e:	85ca                	mv	a1,s2
  800410:	02d00513          	li	a0,45
  800414:	9482                	jalr	s1
                num = -(long long)num;
  800416:	40800633          	neg	a2,s0
  80041a:	8a5e                	mv	s4,s7
  80041c:	46a9                	li	a3,10
  80041e:	b591                	j	800262 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800420:	e329                	bnez	a4,800462 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800422:	02800793          	li	a5,40
  800426:	853e                	mv	a0,a5
  800428:	00000d97          	auipc	s11,0x0
  80042c:	0d9d8d93          	addi	s11,s11,217 # 800501 <main+0x3d>
  800430:	b5f5                	j	80031c <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800432:	85e6                	mv	a1,s9
  800434:	856e                	mv	a0,s11
  800436:	072000ef          	jal	8004a8 <strnlen>
  80043a:	40ad0d3b          	subw	s10,s10,a0
  80043e:	01a05863          	blez	s10,80044e <vprintfmt+0x30c>
                    putch(padc, putdat);
  800442:	85ca                	mv	a1,s2
  800444:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  800446:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  800448:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  80044a:	fe0d1ce3          	bnez	s10,800442 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80044e:	000dc783          	lbu	a5,0(s11)
  800452:	0007851b          	sext.w	a0,a5
  800456:	ec0792e3          	bnez	a5,80031a <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  80045a:	6a22                	ld	s4,8(sp)
  80045c:	bb29                	j	800176 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  80045e:	8462                	mv	s0,s8
  800460:	bbd9                	j	800236 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800462:	85e6                	mv	a1,s9
  800464:	00000517          	auipc	a0,0x0
  800468:	09c50513          	addi	a0,a0,156 # 800500 <main+0x3c>
  80046c:	03c000ef          	jal	8004a8 <strnlen>
  800470:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800474:	02800793          	li	a5,40
                p = "(null)";
  800478:	00000d97          	auipc	s11,0x0
  80047c:	088d8d93          	addi	s11,s11,136 # 800500 <main+0x3c>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800480:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800482:	fda040e3          	bgtz	s10,800442 <vprintfmt+0x300>
  800486:	bd51                	j	80031a <vprintfmt+0x1d8>

0000000000800488 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800488:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80048a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80048e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800490:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800492:	ec06                	sd	ra,24(sp)
  800494:	f83a                	sd	a4,48(sp)
  800496:	fc3e                	sd	a5,56(sp)
  800498:	e0c2                	sd	a6,64(sp)
  80049a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80049c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80049e:	ca5ff0ef          	jal	800142 <vprintfmt>
}
  8004a2:	60e2                	ld	ra,24(sp)
  8004a4:	6161                	addi	sp,sp,80
  8004a6:	8082                	ret

00000000008004a8 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  8004a8:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  8004aa:	e589                	bnez	a1,8004b4 <strnlen+0xc>
  8004ac:	a811                	j	8004c0 <strnlen+0x18>
        cnt ++;
  8004ae:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004b0:	00f58863          	beq	a1,a5,8004c0 <strnlen+0x18>
  8004b4:	00f50733          	add	a4,a0,a5
  8004b8:	00074703          	lbu	a4,0(a4)
  8004bc:	fb6d                	bnez	a4,8004ae <strnlen+0x6>
  8004be:	85be                	mv	a1,a5
    }
    return cnt;
}
  8004c0:	852e                	mv	a0,a1
  8004c2:	8082                	ret

00000000008004c4 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004c4:	1141                	addi	sp,sp,-16
	// Never mind
    // asm volatile("int $14");
    exit(0);
  8004c6:	4501                	li	a0,0
main(void) {
  8004c8:	e406                	sd	ra,8(sp)
    exit(0);
  8004ca:	bf1ff0ef          	jal	8000ba <exit>
