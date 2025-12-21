
obj/__user_testbss.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	112000ef          	jal	800132 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800026:	715d                	addi	sp,sp,-80
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800028:	02810313          	addi	t1,sp,40
__panic(const char *file, int line, const char *fmt, ...) {
  80002c:	e822                	sd	s0,16(sp)
  80002e:	8432                	mv	s0,a2
    cprintf("user panic at %s:%d:\n    ", file, line);
  800030:	862e                	mv	a2,a1
  800032:	85aa                	mv	a1,a0
  800034:	00000517          	auipc	a0,0x0
  800038:	5a450513          	addi	a0,a0,1444 # 8005d8 <main+0xb2>
__panic(const char *file, int line, const char *fmt, ...) {
  80003c:	ec06                	sd	ra,24(sp)
  80003e:	f436                	sd	a3,40(sp)
  800040:	f83a                	sd	a4,48(sp)
  800042:	fc3e                	sd	a5,56(sp)
  800044:	e0c2                	sd	a6,64(sp)
  800046:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800048:	e41a                	sd	t1,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80004a:	056000ef          	jal	8000a0 <cprintf>
    vcprintf(fmt, ap);
  80004e:	65a2                	ld	a1,8(sp)
  800050:	8522                	mv	a0,s0
  800052:	02e000ef          	jal	800080 <vcprintf>
    cprintf("\n");
  800056:	00000517          	auipc	a0,0x0
  80005a:	5a250513          	addi	a0,a0,1442 # 8005f8 <main+0xd2>
  80005e:	042000ef          	jal	8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0b8000ef          	jal	80011c <exit>

0000000000800068 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800068:	1101                	addi	sp,sp,-32
  80006a:	ec06                	sd	ra,24(sp)
  80006c:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  80006e:	0a8000ef          	jal	800116 <sys_putc>
    (*cnt) ++;
  800072:	65a2                	ld	a1,8(sp)
}
  800074:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  800076:	419c                	lw	a5,0(a1)
  800078:	2785                	addiw	a5,a5,1
  80007a:	c19c                	sw	a5,0(a1)
}
  80007c:	6105                	addi	sp,sp,32
  80007e:	8082                	ret

0000000000800080 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800080:	1101                	addi	sp,sp,-32
  800082:	862a                	mv	a2,a0
  800084:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800086:	00000517          	auipc	a0,0x0
  80008a:	fe250513          	addi	a0,a0,-30 # 800068 <cputch>
  80008e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800090:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800092:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800094:	110000ef          	jal	8001a4 <vprintfmt>
    return cnt;
}
  800098:	60e2                	ld	ra,24(sp)
  80009a:	4532                	lw	a0,12(sp)
  80009c:	6105                	addi	sp,sp,32
  80009e:	8082                	ret

00000000008000a0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a0:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a2:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a6:	f42e                	sd	a1,40(sp)
  8000a8:	f832                	sd	a2,48(sp)
  8000aa:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ac:	862a                	mv	a2,a0
  8000ae:	004c                	addi	a1,sp,4
  8000b0:	00000517          	auipc	a0,0x0
  8000b4:	fb850513          	addi	a0,a0,-72 # 800068 <cputch>
  8000b8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000ba:	ec06                	sd	ra,24(sp)
  8000bc:	e0ba                	sd	a4,64(sp)
  8000be:	e4be                	sd	a5,72(sp)
  8000c0:	e8c2                	sd	a6,80(sp)
  8000c2:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  8000c4:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  8000c6:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000c8:	0dc000ef          	jal	8001a4 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000cc:	60e2                	ld	ra,24(sp)
  8000ce:	4512                	lw	a0,4(sp)
  8000d0:	6125                	addi	sp,sp,96
  8000d2:	8082                	ret

00000000008000d4 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  8000d4:	7175                	addi	sp,sp,-144
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  8000d6:	08010313          	addi	t1,sp,128
syscall(int64_t num, ...) {
  8000da:	e42a                	sd	a0,8(sp)
  8000dc:	ecae                	sd	a1,88(sp)
        a[i] = va_arg(ap, uint64_t);
  8000de:	f42e                	sd	a1,40(sp)
syscall(int64_t num, ...) {
  8000e0:	f0b2                	sd	a2,96(sp)
        a[i] = va_arg(ap, uint64_t);
  8000e2:	f832                	sd	a2,48(sp)
syscall(int64_t num, ...) {
  8000e4:	f4b6                	sd	a3,104(sp)
        a[i] = va_arg(ap, uint64_t);
  8000e6:	fc36                	sd	a3,56(sp)
syscall(int64_t num, ...) {
  8000e8:	f8ba                	sd	a4,112(sp)
        a[i] = va_arg(ap, uint64_t);
  8000ea:	e0ba                	sd	a4,64(sp)
syscall(int64_t num, ...) {
  8000ec:	fcbe                	sd	a5,120(sp)
        a[i] = va_arg(ap, uint64_t);
  8000ee:	e4be                	sd	a5,72(sp)
syscall(int64_t num, ...) {
  8000f0:	e142                	sd	a6,128(sp)
  8000f2:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  8000f4:	f01a                	sd	t1,32(sp)
    }
    va_end(ap);

    asm volatile (
  8000f6:	6522                	ld	a0,8(sp)
  8000f8:	75a2                	ld	a1,40(sp)
  8000fa:	7642                	ld	a2,48(sp)
  8000fc:	76e2                	ld	a3,56(sp)
  8000fe:	6706                	ld	a4,64(sp)
  800100:	67a6                	ld	a5,72(sp)
  800102:	00000073          	ecall
  800106:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  80010a:	4572                	lw	a0,28(sp)
  80010c:	6149                	addi	sp,sp,144
  80010e:	8082                	ret

0000000000800110 <sys_exit>:

int
sys_exit(int64_t error_code) {
  800110:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  800112:	4505                	li	a0,1
  800114:	b7c1                	j	8000d4 <syscall>

0000000000800116 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800116:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800118:	4579                	li	a0,30
  80011a:	bf6d                	j	8000d4 <syscall>

000000000080011c <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80011c:	1141                	addi	sp,sp,-16
  80011e:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800120:	ff1ff0ef          	jal	800110 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800124:	00000517          	auipc	a0,0x0
  800128:	4dc50513          	addi	a0,a0,1244 # 800600 <main+0xda>
  80012c:	f75ff0ef          	jal	8000a0 <cprintf>
    while (1);
  800130:	a001                	j	800130 <exit+0x14>

0000000000800132 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800132:	1141                	addi	sp,sp,-16
  800134:	e406                	sd	ra,8(sp)
    int ret = main();
  800136:	3f0000ef          	jal	800526 <main>
    exit(ret);
  80013a:	fe3ff0ef          	jal	80011c <exit>

000000000080013e <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  80013e:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800140:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800144:	f022                	sd	s0,32(sp)
  800146:	ec26                	sd	s1,24(sp)
  800148:	e84a                	sd	s2,16(sp)
  80014a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80014c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800150:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800152:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800156:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80015a:	84aa                	mv	s1,a0
  80015c:	892e                	mv	s2,a1
    if (num >= base) {
  80015e:	03067d63          	bgeu	a2,a6,800198 <printnum+0x5a>
  800162:	e44e                	sd	s3,8(sp)
  800164:	89be                	mv	s3,a5
        while (-- width > 0)
  800166:	4785                	li	a5,1
  800168:	00e7d763          	bge	a5,a4,800176 <printnum+0x38>
            putch(padc, putdat);
  80016c:	85ca                	mv	a1,s2
  80016e:	854e                	mv	a0,s3
        while (-- width > 0)
  800170:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800172:	9482                	jalr	s1
        while (-- width > 0)
  800174:	fc65                	bnez	s0,80016c <printnum+0x2e>
  800176:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800178:	00000797          	auipc	a5,0x0
  80017c:	4a078793          	addi	a5,a5,1184 # 800618 <main+0xf2>
  800180:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800182:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800184:	0007c503          	lbu	a0,0(a5)
}
  800188:	70a2                	ld	ra,40(sp)
  80018a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80018c:	85ca                	mv	a1,s2
  80018e:	87a6                	mv	a5,s1
}
  800190:	6942                	ld	s2,16(sp)
  800192:	64e2                	ld	s1,24(sp)
  800194:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800196:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  800198:	03065633          	divu	a2,a2,a6
  80019c:	8722                	mv	a4,s0
  80019e:	fa1ff0ef          	jal	80013e <printnum>
  8001a2:	bfd9                	j	800178 <printnum+0x3a>

00000000008001a4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001a4:	7119                	addi	sp,sp,-128
  8001a6:	f4a6                	sd	s1,104(sp)
  8001a8:	f0ca                	sd	s2,96(sp)
  8001aa:	ecce                	sd	s3,88(sp)
  8001ac:	e8d2                	sd	s4,80(sp)
  8001ae:	e4d6                	sd	s5,72(sp)
  8001b0:	e0da                	sd	s6,64(sp)
  8001b2:	f862                	sd	s8,48(sp)
  8001b4:	fc86                	sd	ra,120(sp)
  8001b6:	f8a2                	sd	s0,112(sp)
  8001b8:	fc5e                	sd	s7,56(sp)
  8001ba:	f466                	sd	s9,40(sp)
  8001bc:	f06a                	sd	s10,32(sp)
  8001be:	ec6e                	sd	s11,24(sp)
  8001c0:	84aa                	mv	s1,a0
  8001c2:	8c32                	mv	s8,a2
  8001c4:	8a36                	mv	s4,a3
  8001c6:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c8:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001cc:	05500b13          	li	s6,85
  8001d0:	00000a97          	auipc	s5,0x0
  8001d4:	604a8a93          	addi	s5,s5,1540 # 8007d4 <main+0x2ae>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001d8:	000c4503          	lbu	a0,0(s8)
  8001dc:	001c0413          	addi	s0,s8,1
  8001e0:	01350a63          	beq	a0,s3,8001f4 <vprintfmt+0x50>
            if (ch == '\0') {
  8001e4:	cd0d                	beqz	a0,80021e <vprintfmt+0x7a>
            putch(ch, putdat);
  8001e6:	85ca                	mv	a1,s2
  8001e8:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ea:	00044503          	lbu	a0,0(s0)
  8001ee:	0405                	addi	s0,s0,1
  8001f0:	ff351ae3          	bne	a0,s3,8001e4 <vprintfmt+0x40>
        width = precision = -1;
  8001f4:	5cfd                	li	s9,-1
  8001f6:	8d66                	mv	s10,s9
        char padc = ' ';
  8001f8:	02000d93          	li	s11,32
        lflag = altflag = 0;
  8001fc:	4b81                	li	s7,0
  8001fe:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800200:	00044683          	lbu	a3,0(s0)
  800204:	00140c13          	addi	s8,s0,1
  800208:	fdd6859b          	addiw	a1,a3,-35
  80020c:	0ff5f593          	zext.b	a1,a1
  800210:	02bb6663          	bltu	s6,a1,80023c <vprintfmt+0x98>
  800214:	058a                	slli	a1,a1,0x2
  800216:	95d6                	add	a1,a1,s5
  800218:	4198                	lw	a4,0(a1)
  80021a:	9756                	add	a4,a4,s5
  80021c:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80021e:	70e6                	ld	ra,120(sp)
  800220:	7446                	ld	s0,112(sp)
  800222:	74a6                	ld	s1,104(sp)
  800224:	7906                	ld	s2,96(sp)
  800226:	69e6                	ld	s3,88(sp)
  800228:	6a46                	ld	s4,80(sp)
  80022a:	6aa6                	ld	s5,72(sp)
  80022c:	6b06                	ld	s6,64(sp)
  80022e:	7be2                	ld	s7,56(sp)
  800230:	7c42                	ld	s8,48(sp)
  800232:	7ca2                	ld	s9,40(sp)
  800234:	7d02                	ld	s10,32(sp)
  800236:	6de2                	ld	s11,24(sp)
  800238:	6109                	addi	sp,sp,128
  80023a:	8082                	ret
            putch('%', putdat);
  80023c:	85ca                	mv	a1,s2
  80023e:	02500513          	li	a0,37
  800242:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800244:	fff44783          	lbu	a5,-1(s0)
  800248:	02500713          	li	a4,37
  80024c:	8c22                	mv	s8,s0
  80024e:	f8e785e3          	beq	a5,a4,8001d8 <vprintfmt+0x34>
  800252:	ffec4783          	lbu	a5,-2(s8)
  800256:	1c7d                	addi	s8,s8,-1
  800258:	fee79de3          	bne	a5,a4,800252 <vprintfmt+0xae>
  80025c:	bfb5                	j	8001d8 <vprintfmt+0x34>
                ch = *fmt;
  80025e:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800262:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800264:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800268:	fd06071b          	addiw	a4,a2,-48
  80026c:	24e56a63          	bltu	a0,a4,8004c0 <vprintfmt+0x31c>
                ch = *fmt;
  800270:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800272:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800274:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800278:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  80027c:	0197073b          	addw	a4,a4,s9
  800280:	0017171b          	slliw	a4,a4,0x1
  800284:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  800286:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  80028a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80028c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800290:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  800294:	feb570e3          	bgeu	a0,a1,800274 <vprintfmt+0xd0>
            if (width < 0)
  800298:	f60d54e3          	bgez	s10,800200 <vprintfmt+0x5c>
                width = precision, precision = -1;
  80029c:	8d66                	mv	s10,s9
  80029e:	5cfd                	li	s9,-1
  8002a0:	b785                	j	800200 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002a2:	8db6                	mv	s11,a3
  8002a4:	8462                	mv	s0,s8
  8002a6:	bfa9                	j	800200 <vprintfmt+0x5c>
  8002a8:	8462                	mv	s0,s8
            altflag = 1;
  8002aa:	4b85                	li	s7,1
            goto reswitch;
  8002ac:	bf91                	j	800200 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002ae:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002b0:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002b4:	00f74463          	blt	a4,a5,8002bc <vprintfmt+0x118>
    else if (lflag) {
  8002b8:	1a078763          	beqz	a5,800466 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002bc:	000a3603          	ld	a2,0(s4)
  8002c0:	46c1                	li	a3,16
  8002c2:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002c4:	000d879b          	sext.w	a5,s11
  8002c8:	876a                	mv	a4,s10
  8002ca:	85ca                	mv	a1,s2
  8002cc:	8526                	mv	a0,s1
  8002ce:	e71ff0ef          	jal	80013e <printnum>
            break;
  8002d2:	b719                	j	8001d8 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002d4:	000a2503          	lw	a0,0(s4)
  8002d8:	85ca                	mv	a1,s2
  8002da:	0a21                	addi	s4,s4,8
  8002dc:	9482                	jalr	s1
            break;
  8002de:	bded                	j	8001d8 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002e0:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002e2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002e6:	00f74463          	blt	a4,a5,8002ee <vprintfmt+0x14a>
    else if (lflag) {
  8002ea:	16078963          	beqz	a5,80045c <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  8002ee:	000a3603          	ld	a2,0(s4)
  8002f2:	46a9                	li	a3,10
  8002f4:	8a2e                	mv	s4,a1
  8002f6:	b7f9                	j	8002c4 <vprintfmt+0x120>
            putch('0', putdat);
  8002f8:	85ca                	mv	a1,s2
  8002fa:	03000513          	li	a0,48
  8002fe:	9482                	jalr	s1
            putch('x', putdat);
  800300:	85ca                	mv	a1,s2
  800302:	07800513          	li	a0,120
  800306:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800308:	000a3603          	ld	a2,0(s4)
            goto number;
  80030c:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80030e:	0a21                	addi	s4,s4,8
            goto number;
  800310:	bf55                	j	8002c4 <vprintfmt+0x120>
            putch(ch, putdat);
  800312:	85ca                	mv	a1,s2
  800314:	02500513          	li	a0,37
  800318:	9482                	jalr	s1
            break;
  80031a:	bd7d                	j	8001d8 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80031c:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800320:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800322:	0a21                	addi	s4,s4,8
            goto process_precision;
  800324:	bf95                	j	800298 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800326:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800328:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80032c:	00f74463          	blt	a4,a5,800334 <vprintfmt+0x190>
    else if (lflag) {
  800330:	12078163          	beqz	a5,800452 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800334:	000a3603          	ld	a2,0(s4)
  800338:	46a1                	li	a3,8
  80033a:	8a2e                	mv	s4,a1
  80033c:	b761                	j	8002c4 <vprintfmt+0x120>
            if (width < 0)
  80033e:	876a                	mv	a4,s10
  800340:	000d5363          	bgez	s10,800346 <vprintfmt+0x1a2>
  800344:	4701                	li	a4,0
  800346:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  80034a:	8462                	mv	s0,s8
            goto reswitch;
  80034c:	bd55                	j	800200 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  80034e:	000d841b          	sext.w	s0,s11
  800352:	fd340793          	addi	a5,s0,-45
  800356:	00f037b3          	snez	a5,a5
  80035a:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  80035e:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800362:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800364:	008a0793          	addi	a5,s4,8
  800368:	e43e                	sd	a5,8(sp)
  80036a:	100d8c63          	beqz	s11,800482 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80036e:	12071363          	bnez	a4,800494 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800372:	000dc783          	lbu	a5,0(s11)
  800376:	0007851b          	sext.w	a0,a5
  80037a:	c78d                	beqz	a5,8003a4 <vprintfmt+0x200>
  80037c:	0d85                	addi	s11,s11,1
  80037e:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800380:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800384:	000cc563          	bltz	s9,80038e <vprintfmt+0x1ea>
  800388:	3cfd                	addiw	s9,s9,-1
  80038a:	008c8d63          	beq	s9,s0,8003a4 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  80038e:	020b9663          	bnez	s7,8003ba <vprintfmt+0x216>
                    putch(ch, putdat);
  800392:	85ca                	mv	a1,s2
  800394:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800396:	000dc783          	lbu	a5,0(s11)
  80039a:	0d85                	addi	s11,s11,1
  80039c:	3d7d                	addiw	s10,s10,-1
  80039e:	0007851b          	sext.w	a0,a5
  8003a2:	f3ed                	bnez	a5,800384 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003a4:	01a05963          	blez	s10,8003b6 <vprintfmt+0x212>
                putch(' ', putdat);
  8003a8:	85ca                	mv	a1,s2
  8003aa:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003ae:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003b0:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003b2:	fe0d1be3          	bnez	s10,8003a8 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003b6:	6a22                	ld	s4,8(sp)
  8003b8:	b505                	j	8001d8 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ba:	3781                	addiw	a5,a5,-32
  8003bc:	fcfa7be3          	bgeu	s4,a5,800392 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003c0:	03f00513          	li	a0,63
  8003c4:	85ca                	mv	a1,s2
  8003c6:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003c8:	000dc783          	lbu	a5,0(s11)
  8003cc:	0d85                	addi	s11,s11,1
  8003ce:	3d7d                	addiw	s10,s10,-1
  8003d0:	0007851b          	sext.w	a0,a5
  8003d4:	dbe1                	beqz	a5,8003a4 <vprintfmt+0x200>
  8003d6:	fa0cd9e3          	bgez	s9,800388 <vprintfmt+0x1e4>
  8003da:	b7c5                	j	8003ba <vprintfmt+0x216>
            if (err < 0) {
  8003dc:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003e0:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003e2:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003e4:	41f7d71b          	sraiw	a4,a5,0x1f
  8003e8:	8fb9                	xor	a5,a5,a4
  8003ea:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003ee:	02d64563          	blt	a2,a3,800418 <vprintfmt+0x274>
  8003f2:	00000797          	auipc	a5,0x0
  8003f6:	53e78793          	addi	a5,a5,1342 # 800930 <error_string>
  8003fa:	00369713          	slli	a4,a3,0x3
  8003fe:	97ba                	add	a5,a5,a4
  800400:	639c                	ld	a5,0(a5)
  800402:	cb99                	beqz	a5,800418 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800404:	86be                	mv	a3,a5
  800406:	00000617          	auipc	a2,0x0
  80040a:	24260613          	addi	a2,a2,578 # 800648 <main+0x122>
  80040e:	85ca                	mv	a1,s2
  800410:	8526                	mv	a0,s1
  800412:	0d8000ef          	jal	8004ea <printfmt>
  800416:	b3c9                	j	8001d8 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800418:	00000617          	auipc	a2,0x0
  80041c:	22060613          	addi	a2,a2,544 # 800638 <main+0x112>
  800420:	85ca                	mv	a1,s2
  800422:	8526                	mv	a0,s1
  800424:	0c6000ef          	jal	8004ea <printfmt>
  800428:	bb45                	j	8001d8 <vprintfmt+0x34>
    if (lflag >= 2) {
  80042a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80042c:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800430:	00f74363          	blt	a4,a5,800436 <vprintfmt+0x292>
    else if (lflag) {
  800434:	cf81                	beqz	a5,80044c <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800436:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80043a:	02044b63          	bltz	s0,800470 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  80043e:	8622                	mv	a2,s0
  800440:	8a5e                	mv	s4,s7
  800442:	46a9                	li	a3,10
  800444:	b541                	j	8002c4 <vprintfmt+0x120>
            lflag ++;
  800446:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800448:	8462                	mv	s0,s8
            goto reswitch;
  80044a:	bb5d                	j	800200 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80044c:	000a2403          	lw	s0,0(s4)
  800450:	b7ed                	j	80043a <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800452:	000a6603          	lwu	a2,0(s4)
  800456:	46a1                	li	a3,8
  800458:	8a2e                	mv	s4,a1
  80045a:	b5ad                	j	8002c4 <vprintfmt+0x120>
  80045c:	000a6603          	lwu	a2,0(s4)
  800460:	46a9                	li	a3,10
  800462:	8a2e                	mv	s4,a1
  800464:	b585                	j	8002c4 <vprintfmt+0x120>
  800466:	000a6603          	lwu	a2,0(s4)
  80046a:	46c1                	li	a3,16
  80046c:	8a2e                	mv	s4,a1
  80046e:	bd99                	j	8002c4 <vprintfmt+0x120>
                putch('-', putdat);
  800470:	85ca                	mv	a1,s2
  800472:	02d00513          	li	a0,45
  800476:	9482                	jalr	s1
                num = -(long long)num;
  800478:	40800633          	neg	a2,s0
  80047c:	8a5e                	mv	s4,s7
  80047e:	46a9                	li	a3,10
  800480:	b591                	j	8002c4 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800482:	e329                	bnez	a4,8004c4 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800484:	02800793          	li	a5,40
  800488:	853e                	mv	a0,a5
  80048a:	00000d97          	auipc	s11,0x0
  80048e:	1a7d8d93          	addi	s11,s11,423 # 800631 <main+0x10b>
  800492:	b5f5                	j	80037e <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800494:	85e6                	mv	a1,s9
  800496:	856e                	mv	a0,s11
  800498:	072000ef          	jal	80050a <strnlen>
  80049c:	40ad0d3b          	subw	s10,s10,a0
  8004a0:	01a05863          	blez	s10,8004b0 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004a4:	85ca                	mv	a1,s2
  8004a6:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a8:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004aa:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ac:	fe0d1ce3          	bnez	s10,8004a4 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b0:	000dc783          	lbu	a5,0(s11)
  8004b4:	0007851b          	sext.w	a0,a5
  8004b8:	ec0792e3          	bnez	a5,80037c <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004bc:	6a22                	ld	s4,8(sp)
  8004be:	bb29                	j	8001d8 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004c0:	8462                	mv	s0,s8
  8004c2:	bbd9                	j	800298 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c4:	85e6                	mv	a1,s9
  8004c6:	00000517          	auipc	a0,0x0
  8004ca:	16a50513          	addi	a0,a0,362 # 800630 <main+0x10a>
  8004ce:	03c000ef          	jal	80050a <strnlen>
  8004d2:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d6:	02800793          	li	a5,40
                p = "(null)";
  8004da:	00000d97          	auipc	s11,0x0
  8004de:	156d8d93          	addi	s11,s11,342 # 800630 <main+0x10a>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004e2:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e4:	fda040e3          	bgtz	s10,8004a4 <vprintfmt+0x300>
  8004e8:	bd51                	j	80037c <vprintfmt+0x1d8>

00000000008004ea <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ea:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004ec:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f0:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004f2:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004f4:	ec06                	sd	ra,24(sp)
  8004f6:	f83a                	sd	a4,48(sp)
  8004f8:	fc3e                	sd	a5,56(sp)
  8004fa:	e0c2                	sd	a6,64(sp)
  8004fc:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004fe:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800500:	ca5ff0ef          	jal	8001a4 <vprintfmt>
}
  800504:	60e2                	ld	ra,24(sp)
  800506:	6161                	addi	sp,sp,80
  800508:	8082                	ret

000000000080050a <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80050a:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80050c:	e589                	bnez	a1,800516 <strnlen+0xc>
  80050e:	a811                	j	800522 <strnlen+0x18>
        cnt ++;
  800510:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800512:	00f58863          	beq	a1,a5,800522 <strnlen+0x18>
  800516:	00f50733          	add	a4,a0,a5
  80051a:	00074703          	lbu	a4,0(a4)
  80051e:	fb6d                	bnez	a4,800510 <strnlen+0x6>
  800520:	85be                	mv	a1,a5
    }
    return cnt;
}
  800522:	852e                	mv	a0,a1
  800524:	8082                	ret

0000000000800526 <main>:
#define ARRAYSIZE (1024*1024)

uint32_t bigarray[ARRAYSIZE];

int
main(void) {
  800526:	1141                	addi	sp,sp,-16
    cprintf("Making sure bss works right...\n");
  800528:	00000517          	auipc	a0,0x0
  80052c:	1e850513          	addi	a0,a0,488 # 800710 <main+0x1ea>
main(void) {
  800530:	e406                	sd	ra,8(sp)
    cprintf("Making sure bss works right...\n");
  800532:	b6fff0ef          	jal	8000a0 <cprintf>
    int i;
    for (i = 0; i < ARRAYSIZE; i ++) {
  800536:	00001597          	auipc	a1,0x1
  80053a:	aca58593          	addi	a1,a1,-1334 # 801000 <bigarray>
    cprintf("Making sure bss works right...\n");
  80053e:	87ae                	mv	a5,a1
    for (i = 0; i < ARRAYSIZE; i ++) {
  800540:	4681                	li	a3,0
  800542:	00100637          	lui	a2,0x100
  800546:	a029                	j	800550 <main+0x2a>
  800548:	2685                	addiw	a3,a3,1
  80054a:	0791                	addi	a5,a5,4
  80054c:	00c68f63          	beq	a3,a2,80056a <main+0x44>
        if (bigarray[i] != 0) {
  800550:	4398                	lw	a4,0(a5)
  800552:	db7d                	beqz	a4,800548 <main+0x22>
            panic("bigarray[%d] isn't cleared!\n", i);
  800554:	00000617          	auipc	a2,0x0
  800558:	1dc60613          	addi	a2,a2,476 # 800730 <main+0x20a>
  80055c:	45b9                	li	a1,14
  80055e:	00000517          	auipc	a0,0x0
  800562:	1f250513          	addi	a0,a0,498 # 800750 <main+0x22a>
  800566:	ac1ff0ef          	jal	800026 <__panic>
  80056a:	00001717          	auipc	a4,0x1
  80056e:	a9670713          	addi	a4,a4,-1386 # 801000 <bigarray>
        }
    }
    for (i = 0; i < ARRAYSIZE; i ++) {
  800572:	4781                	li	a5,0
  800574:	001006b7          	lui	a3,0x100
        bigarray[i] = i;
  800578:	c31c                	sw	a5,0(a4)
    for (i = 0; i < ARRAYSIZE; i ++) {
  80057a:	2785                	addiw	a5,a5,1
  80057c:	0711                	addi	a4,a4,4
  80057e:	fed79de3          	bne	a5,a3,800578 <main+0x52>
    }
    for (i = 0; i < ARRAYSIZE; i ++) {
  800582:	4681                	li	a3,0
  800584:	00100737          	lui	a4,0x100
  800588:	a029                	j	800592 <main+0x6c>
  80058a:	2685                	addiw	a3,a3,1 # 100001 <_start-0x70001f>
  80058c:	0591                	addi	a1,a1,4
  80058e:	02e68063          	beq	a3,a4,8005ae <main+0x88>
        if (bigarray[i] != i) {
  800592:	419c                	lw	a5,0(a1)
  800594:	fed78be3          	beq	a5,a3,80058a <main+0x64>
            panic("bigarray[%d] didn't hold its value!\n", i);
  800598:	00000617          	auipc	a2,0x0
  80059c:	1c860613          	addi	a2,a2,456 # 800760 <main+0x23a>
  8005a0:	45d9                	li	a1,22
  8005a2:	00000517          	auipc	a0,0x0
  8005a6:	1ae50513          	addi	a0,a0,430 # 800750 <main+0x22a>
  8005aa:	a7dff0ef          	jal	800026 <__panic>
        }
    }

    cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8005ae:	00000517          	auipc	a0,0x0
  8005b2:	1da50513          	addi	a0,a0,474 # 800788 <main+0x262>
  8005b6:	aebff0ef          	jal	8000a0 <cprintf>
    cprintf("testbss may pass.\n");
  8005ba:	00000517          	auipc	a0,0x0
  8005be:	20650513          	addi	a0,a0,518 # 8007c0 <main+0x29a>
  8005c2:	adfff0ef          	jal	8000a0 <cprintf>

    bigarray[ARRAYSIZE + 1024] = 0;
    // asm volatile ("int $0x14");
    exit(0);
  8005c6:	4501                	li	a0,0
    bigarray[ARRAYSIZE + 1024] = 0;
  8005c8:	00402797          	auipc	a5,0x402
  8005cc:	a207ac23          	sw	zero,-1480(a5) # c02000 <bigarray+0x401000>
    exit(0);
  8005d0:	b4dff0ef          	jal	80011c <exit>
