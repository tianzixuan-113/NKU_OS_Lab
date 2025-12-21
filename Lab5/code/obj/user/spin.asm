
obj/__user_spin.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	130000ef          	jal	800150 <umain>
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
  800038:	5dc50513          	addi	a0,a0,1500 # 800610 <main+0xcc>
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
  80005a:	5da50513          	addi	a0,a0,1498 # 800630 <main+0xec>
  80005e:	042000ef          	jal	8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0ce000ef          	jal	800132 <exit>

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
  80006e:	0be000ef          	jal	80012c <sys_putc>
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
  800094:	12e000ef          	jal	8001c2 <vprintfmt>
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
  8000c8:	0fa000ef          	jal	8001c2 <vprintfmt>
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

0000000000800116 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800116:	4509                	li	a0,2
  800118:	bf75                	j	8000d4 <syscall>

000000000080011a <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
  80011a:	862e                	mv	a2,a1
    return syscall(SYS_wait, pid, store);
  80011c:	85aa                	mv	a1,a0
  80011e:	450d                	li	a0,3
  800120:	bf55                	j	8000d4 <syscall>

0000000000800122 <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800122:	4529                	li	a0,10
  800124:	bf45                	j	8000d4 <syscall>

0000000000800126 <sys_kill>:
}

int
sys_kill(int64_t pid) {
  800126:	85aa                	mv	a1,a0
    return syscall(SYS_kill, pid);
  800128:	4531                	li	a0,12
  80012a:	b76d                	j	8000d4 <syscall>

000000000080012c <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  80012c:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  80012e:	4579                	li	a0,30
  800130:	b755                	j	8000d4 <syscall>

0000000000800132 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800132:	1141                	addi	sp,sp,-16
  800134:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800136:	fdbff0ef          	jal	800110 <sys_exit>
    cprintf("BUG: exit failed.\n");
  80013a:	00000517          	auipc	a0,0x0
  80013e:	4fe50513          	addi	a0,a0,1278 # 800638 <main+0xf4>
  800142:	f5fff0ef          	jal	8000a0 <cprintf>
    while (1);
  800146:	a001                	j	800146 <exit+0x14>

0000000000800148 <fork>:
}

int
fork(void) {
    return sys_fork();
  800148:	b7f9                	j	800116 <sys_fork>

000000000080014a <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  80014a:	bfc1                	j	80011a <sys_wait>

000000000080014c <yield>:
}

void
yield(void) {
    sys_yield();
  80014c:	bfd9                	j	800122 <sys_yield>

000000000080014e <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  80014e:	bfe1                	j	800126 <sys_kill>

0000000000800150 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800150:	1141                	addi	sp,sp,-16
  800152:	e406                	sd	ra,8(sp)
    int ret = main();
  800154:	3f0000ef          	jal	800544 <main>
    exit(ret);
  800158:	fdbff0ef          	jal	800132 <exit>

000000000080015c <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  80015c:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80015e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800162:	f022                	sd	s0,32(sp)
  800164:	ec26                	sd	s1,24(sp)
  800166:	e84a                	sd	s2,16(sp)
  800168:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80016a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016e:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800170:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800174:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800178:	84aa                	mv	s1,a0
  80017a:	892e                	mv	s2,a1
    if (num >= base) {
  80017c:	03067d63          	bgeu	a2,a6,8001b6 <printnum+0x5a>
  800180:	e44e                	sd	s3,8(sp)
  800182:	89be                	mv	s3,a5
        while (-- width > 0)
  800184:	4785                	li	a5,1
  800186:	00e7d763          	bge	a5,a4,800194 <printnum+0x38>
            putch(padc, putdat);
  80018a:	85ca                	mv	a1,s2
  80018c:	854e                	mv	a0,s3
        while (-- width > 0)
  80018e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800190:	9482                	jalr	s1
        while (-- width > 0)
  800192:	fc65                	bnez	s0,80018a <printnum+0x2e>
  800194:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800196:	00000797          	auipc	a5,0x0
  80019a:	4ba78793          	addi	a5,a5,1210 # 800650 <main+0x10c>
  80019e:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a2:	0007c503          	lbu	a0,0(a5)
}
  8001a6:	70a2                	ld	ra,40(sp)
  8001a8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001aa:	85ca                	mv	a1,s2
  8001ac:	87a6                	mv	a5,s1
}
  8001ae:	6942                	ld	s2,16(sp)
  8001b0:	64e2                	ld	s1,24(sp)
  8001b2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001b6:	03065633          	divu	a2,a2,a6
  8001ba:	8722                	mv	a4,s0
  8001bc:	fa1ff0ef          	jal	80015c <printnum>
  8001c0:	bfd9                	j	800196 <printnum+0x3a>

00000000008001c2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c2:	7119                	addi	sp,sp,-128
  8001c4:	f4a6                	sd	s1,104(sp)
  8001c6:	f0ca                	sd	s2,96(sp)
  8001c8:	ecce                	sd	s3,88(sp)
  8001ca:	e8d2                	sd	s4,80(sp)
  8001cc:	e4d6                	sd	s5,72(sp)
  8001ce:	e0da                	sd	s6,64(sp)
  8001d0:	f862                	sd	s8,48(sp)
  8001d2:	fc86                	sd	ra,120(sp)
  8001d4:	f8a2                	sd	s0,112(sp)
  8001d6:	fc5e                	sd	s7,56(sp)
  8001d8:	f466                	sd	s9,40(sp)
  8001da:	f06a                	sd	s10,32(sp)
  8001dc:	ec6e                	sd	s11,24(sp)
  8001de:	84aa                	mv	s1,a0
  8001e0:	8c32                	mv	s8,a2
  8001e2:	8a36                	mv	s4,a3
  8001e4:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e6:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001ea:	05500b13          	li	s6,85
  8001ee:	00000a97          	auipc	s5,0x0
  8001f2:	692a8a93          	addi	s5,s5,1682 # 800880 <main+0x33c>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f6:	000c4503          	lbu	a0,0(s8)
  8001fa:	001c0413          	addi	s0,s8,1
  8001fe:	01350a63          	beq	a0,s3,800212 <vprintfmt+0x50>
            if (ch == '\0') {
  800202:	cd0d                	beqz	a0,80023c <vprintfmt+0x7a>
            putch(ch, putdat);
  800204:	85ca                	mv	a1,s2
  800206:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800208:	00044503          	lbu	a0,0(s0)
  80020c:	0405                	addi	s0,s0,1
  80020e:	ff351ae3          	bne	a0,s3,800202 <vprintfmt+0x40>
        width = precision = -1;
  800212:	5cfd                	li	s9,-1
  800214:	8d66                	mv	s10,s9
        char padc = ' ';
  800216:	02000d93          	li	s11,32
        lflag = altflag = 0;
  80021a:	4b81                	li	s7,0
  80021c:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  80021e:	00044683          	lbu	a3,0(s0)
  800222:	00140c13          	addi	s8,s0,1
  800226:	fdd6859b          	addiw	a1,a3,-35
  80022a:	0ff5f593          	zext.b	a1,a1
  80022e:	02bb6663          	bltu	s6,a1,80025a <vprintfmt+0x98>
  800232:	058a                	slli	a1,a1,0x2
  800234:	95d6                	add	a1,a1,s5
  800236:	4198                	lw	a4,0(a1)
  800238:	9756                	add	a4,a4,s5
  80023a:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80023c:	70e6                	ld	ra,120(sp)
  80023e:	7446                	ld	s0,112(sp)
  800240:	74a6                	ld	s1,104(sp)
  800242:	7906                	ld	s2,96(sp)
  800244:	69e6                	ld	s3,88(sp)
  800246:	6a46                	ld	s4,80(sp)
  800248:	6aa6                	ld	s5,72(sp)
  80024a:	6b06                	ld	s6,64(sp)
  80024c:	7be2                	ld	s7,56(sp)
  80024e:	7c42                	ld	s8,48(sp)
  800250:	7ca2                	ld	s9,40(sp)
  800252:	7d02                	ld	s10,32(sp)
  800254:	6de2                	ld	s11,24(sp)
  800256:	6109                	addi	sp,sp,128
  800258:	8082                	ret
            putch('%', putdat);
  80025a:	85ca                	mv	a1,s2
  80025c:	02500513          	li	a0,37
  800260:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800262:	fff44783          	lbu	a5,-1(s0)
  800266:	02500713          	li	a4,37
  80026a:	8c22                	mv	s8,s0
  80026c:	f8e785e3          	beq	a5,a4,8001f6 <vprintfmt+0x34>
  800270:	ffec4783          	lbu	a5,-2(s8)
  800274:	1c7d                	addi	s8,s8,-1
  800276:	fee79de3          	bne	a5,a4,800270 <vprintfmt+0xae>
  80027a:	bfb5                	j	8001f6 <vprintfmt+0x34>
                ch = *fmt;
  80027c:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800280:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800282:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800286:	fd06071b          	addiw	a4,a2,-48
  80028a:	24e56a63          	bltu	a0,a4,8004de <vprintfmt+0x31c>
                ch = *fmt;
  80028e:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800290:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800292:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800296:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  80029a:	0197073b          	addw	a4,a4,s9
  80029e:	0017171b          	slliw	a4,a4,0x1
  8002a2:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002a4:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002a8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002aa:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002ae:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002b2:	feb570e3          	bgeu	a0,a1,800292 <vprintfmt+0xd0>
            if (width < 0)
  8002b6:	f60d54e3          	bgez	s10,80021e <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002ba:	8d66                	mv	s10,s9
  8002bc:	5cfd                	li	s9,-1
  8002be:	b785                	j	80021e <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002c0:	8db6                	mv	s11,a3
  8002c2:	8462                	mv	s0,s8
  8002c4:	bfa9                	j	80021e <vprintfmt+0x5c>
  8002c6:	8462                	mv	s0,s8
            altflag = 1;
  8002c8:	4b85                	li	s7,1
            goto reswitch;
  8002ca:	bf91                	j	80021e <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002cc:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002ce:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002d2:	00f74463          	blt	a4,a5,8002da <vprintfmt+0x118>
    else if (lflag) {
  8002d6:	1a078763          	beqz	a5,800484 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002da:	000a3603          	ld	a2,0(s4)
  8002de:	46c1                	li	a3,16
  8002e0:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002e2:	000d879b          	sext.w	a5,s11
  8002e6:	876a                	mv	a4,s10
  8002e8:	85ca                	mv	a1,s2
  8002ea:	8526                	mv	a0,s1
  8002ec:	e71ff0ef          	jal	80015c <printnum>
            break;
  8002f0:	b719                	j	8001f6 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002f2:	000a2503          	lw	a0,0(s4)
  8002f6:	85ca                	mv	a1,s2
  8002f8:	0a21                	addi	s4,s4,8
  8002fa:	9482                	jalr	s1
            break;
  8002fc:	bded                	j	8001f6 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002fe:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800300:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800304:	00f74463          	blt	a4,a5,80030c <vprintfmt+0x14a>
    else if (lflag) {
  800308:	16078963          	beqz	a5,80047a <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  80030c:	000a3603          	ld	a2,0(s4)
  800310:	46a9                	li	a3,10
  800312:	8a2e                	mv	s4,a1
  800314:	b7f9                	j	8002e2 <vprintfmt+0x120>
            putch('0', putdat);
  800316:	85ca                	mv	a1,s2
  800318:	03000513          	li	a0,48
  80031c:	9482                	jalr	s1
            putch('x', putdat);
  80031e:	85ca                	mv	a1,s2
  800320:	07800513          	li	a0,120
  800324:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800326:	000a3603          	ld	a2,0(s4)
            goto number;
  80032a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80032c:	0a21                	addi	s4,s4,8
            goto number;
  80032e:	bf55                	j	8002e2 <vprintfmt+0x120>
            putch(ch, putdat);
  800330:	85ca                	mv	a1,s2
  800332:	02500513          	li	a0,37
  800336:	9482                	jalr	s1
            break;
  800338:	bd7d                	j	8001f6 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  80033a:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  80033e:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800340:	0a21                	addi	s4,s4,8
            goto process_precision;
  800342:	bf95                	j	8002b6 <vprintfmt+0xf4>
    if (lflag >= 2) {
  800344:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800346:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80034a:	00f74463          	blt	a4,a5,800352 <vprintfmt+0x190>
    else if (lflag) {
  80034e:	12078163          	beqz	a5,800470 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800352:	000a3603          	ld	a2,0(s4)
  800356:	46a1                	li	a3,8
  800358:	8a2e                	mv	s4,a1
  80035a:	b761                	j	8002e2 <vprintfmt+0x120>
            if (width < 0)
  80035c:	876a                	mv	a4,s10
  80035e:	000d5363          	bgez	s10,800364 <vprintfmt+0x1a2>
  800362:	4701                	li	a4,0
  800364:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800368:	8462                	mv	s0,s8
            goto reswitch;
  80036a:	bd55                	j	80021e <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  80036c:	000d841b          	sext.w	s0,s11
  800370:	fd340793          	addi	a5,s0,-45
  800374:	00f037b3          	snez	a5,a5
  800378:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  80037c:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800380:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800382:	008a0793          	addi	a5,s4,8
  800386:	e43e                	sd	a5,8(sp)
  800388:	100d8c63          	beqz	s11,8004a0 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  80038c:	12071363          	bnez	a4,8004b2 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800390:	000dc783          	lbu	a5,0(s11)
  800394:	0007851b          	sext.w	a0,a5
  800398:	c78d                	beqz	a5,8003c2 <vprintfmt+0x200>
  80039a:	0d85                	addi	s11,s11,1
  80039c:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  80039e:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a2:	000cc563          	bltz	s9,8003ac <vprintfmt+0x1ea>
  8003a6:	3cfd                	addiw	s9,s9,-1
  8003a8:	008c8d63          	beq	s9,s0,8003c2 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ac:	020b9663          	bnez	s7,8003d8 <vprintfmt+0x216>
                    putch(ch, putdat);
  8003b0:	85ca                	mv	a1,s2
  8003b2:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003b4:	000dc783          	lbu	a5,0(s11)
  8003b8:	0d85                	addi	s11,s11,1
  8003ba:	3d7d                	addiw	s10,s10,-1
  8003bc:	0007851b          	sext.w	a0,a5
  8003c0:	f3ed                	bnez	a5,8003a2 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003c2:	01a05963          	blez	s10,8003d4 <vprintfmt+0x212>
                putch(' ', putdat);
  8003c6:	85ca                	mv	a1,s2
  8003c8:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003cc:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003ce:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003d0:	fe0d1be3          	bnez	s10,8003c6 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003d4:	6a22                	ld	s4,8(sp)
  8003d6:	b505                	j	8001f6 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003d8:	3781                	addiw	a5,a5,-32
  8003da:	fcfa7be3          	bgeu	s4,a5,8003b0 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003de:	03f00513          	li	a0,63
  8003e2:	85ca                	mv	a1,s2
  8003e4:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e6:	000dc783          	lbu	a5,0(s11)
  8003ea:	0d85                	addi	s11,s11,1
  8003ec:	3d7d                	addiw	s10,s10,-1
  8003ee:	0007851b          	sext.w	a0,a5
  8003f2:	dbe1                	beqz	a5,8003c2 <vprintfmt+0x200>
  8003f4:	fa0cd9e3          	bgez	s9,8003a6 <vprintfmt+0x1e4>
  8003f8:	b7c5                	j	8003d8 <vprintfmt+0x216>
            if (err < 0) {
  8003fa:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003fe:	4661                	li	a2,24
            err = va_arg(ap, int);
  800400:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800402:	41f7d71b          	sraiw	a4,a5,0x1f
  800406:	8fb9                	xor	a5,a5,a4
  800408:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80040c:	02d64563          	blt	a2,a3,800436 <vprintfmt+0x274>
  800410:	00000797          	auipc	a5,0x0
  800414:	5c878793          	addi	a5,a5,1480 # 8009d8 <error_string>
  800418:	00369713          	slli	a4,a3,0x3
  80041c:	97ba                	add	a5,a5,a4
  80041e:	639c                	ld	a5,0(a5)
  800420:	cb99                	beqz	a5,800436 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800422:	86be                	mv	a3,a5
  800424:	00000617          	auipc	a2,0x0
  800428:	25c60613          	addi	a2,a2,604 # 800680 <main+0x13c>
  80042c:	85ca                	mv	a1,s2
  80042e:	8526                	mv	a0,s1
  800430:	0d8000ef          	jal	800508 <printfmt>
  800434:	b3c9                	j	8001f6 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800436:	00000617          	auipc	a2,0x0
  80043a:	23a60613          	addi	a2,a2,570 # 800670 <main+0x12c>
  80043e:	85ca                	mv	a1,s2
  800440:	8526                	mv	a0,s1
  800442:	0c6000ef          	jal	800508 <printfmt>
  800446:	bb45                	j	8001f6 <vprintfmt+0x34>
    if (lflag >= 2) {
  800448:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80044a:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  80044e:	00f74363          	blt	a4,a5,800454 <vprintfmt+0x292>
    else if (lflag) {
  800452:	cf81                	beqz	a5,80046a <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  800454:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800458:	02044b63          	bltz	s0,80048e <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  80045c:	8622                	mv	a2,s0
  80045e:	8a5e                	mv	s4,s7
  800460:	46a9                	li	a3,10
  800462:	b541                	j	8002e2 <vprintfmt+0x120>
            lflag ++;
  800464:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800466:	8462                	mv	s0,s8
            goto reswitch;
  800468:	bb5d                	j	80021e <vprintfmt+0x5c>
        return va_arg(*ap, int);
  80046a:	000a2403          	lw	s0,0(s4)
  80046e:	b7ed                	j	800458 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800470:	000a6603          	lwu	a2,0(s4)
  800474:	46a1                	li	a3,8
  800476:	8a2e                	mv	s4,a1
  800478:	b5ad                	j	8002e2 <vprintfmt+0x120>
  80047a:	000a6603          	lwu	a2,0(s4)
  80047e:	46a9                	li	a3,10
  800480:	8a2e                	mv	s4,a1
  800482:	b585                	j	8002e2 <vprintfmt+0x120>
  800484:	000a6603          	lwu	a2,0(s4)
  800488:	46c1                	li	a3,16
  80048a:	8a2e                	mv	s4,a1
  80048c:	bd99                	j	8002e2 <vprintfmt+0x120>
                putch('-', putdat);
  80048e:	85ca                	mv	a1,s2
  800490:	02d00513          	li	a0,45
  800494:	9482                	jalr	s1
                num = -(long long)num;
  800496:	40800633          	neg	a2,s0
  80049a:	8a5e                	mv	s4,s7
  80049c:	46a9                	li	a3,10
  80049e:	b591                	j	8002e2 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004a0:	e329                	bnez	a4,8004e2 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a2:	02800793          	li	a5,40
  8004a6:	853e                	mv	a0,a5
  8004a8:	00000d97          	auipc	s11,0x0
  8004ac:	1c1d8d93          	addi	s11,s11,449 # 800669 <main+0x125>
  8004b0:	b5f5                	j	80039c <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b2:	85e6                	mv	a1,s9
  8004b4:	856e                	mv	a0,s11
  8004b6:	072000ef          	jal	800528 <strnlen>
  8004ba:	40ad0d3b          	subw	s10,s10,a0
  8004be:	01a05863          	blez	s10,8004ce <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004c2:	85ca                	mv	a1,s2
  8004c4:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c6:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004c8:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ca:	fe0d1ce3          	bnez	s10,8004c2 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ce:	000dc783          	lbu	a5,0(s11)
  8004d2:	0007851b          	sext.w	a0,a5
  8004d6:	ec0792e3          	bnez	a5,80039a <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004da:	6a22                	ld	s4,8(sp)
  8004dc:	bb29                	j	8001f6 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004de:	8462                	mv	s0,s8
  8004e0:	bbd9                	j	8002b6 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e2:	85e6                	mv	a1,s9
  8004e4:	00000517          	auipc	a0,0x0
  8004e8:	18450513          	addi	a0,a0,388 # 800668 <main+0x124>
  8004ec:	03c000ef          	jal	800528 <strnlen>
  8004f0:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004f4:	02800793          	li	a5,40
                p = "(null)";
  8004f8:	00000d97          	auipc	s11,0x0
  8004fc:	170d8d93          	addi	s11,s11,368 # 800668 <main+0x124>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800500:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800502:	fda040e3          	bgtz	s10,8004c2 <vprintfmt+0x300>
  800506:	bd51                	j	80039a <vprintfmt+0x1d8>

0000000000800508 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800508:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80050a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800510:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800512:	ec06                	sd	ra,24(sp)
  800514:	f83a                	sd	a4,48(sp)
  800516:	fc3e                	sd	a5,56(sp)
  800518:	e0c2                	sd	a6,64(sp)
  80051a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80051c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80051e:	ca5ff0ef          	jal	8001c2 <vprintfmt>
}
  800522:	60e2                	ld	ra,24(sp)
  800524:	6161                	addi	sp,sp,80
  800526:	8082                	ret

0000000000800528 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800528:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  80052a:	e589                	bnez	a1,800534 <strnlen+0xc>
  80052c:	a811                	j	800540 <strnlen+0x18>
        cnt ++;
  80052e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800530:	00f58863          	beq	a1,a5,800540 <strnlen+0x18>
  800534:	00f50733          	add	a4,a0,a5
  800538:	00074703          	lbu	a4,0(a4)
  80053c:	fb6d                	bnez	a4,80052e <strnlen+0x6>
  80053e:	85be                	mv	a1,a5
    }
    return cnt;
}
  800540:	852e                	mv	a0,a1
  800542:	8082                	ret

0000000000800544 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800544:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  800546:	00000517          	auipc	a0,0x0
  80054a:	20250513          	addi	a0,a0,514 # 800748 <main+0x204>
main(void) {
  80054e:	e406                	sd	ra,8(sp)
  800550:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  800552:	b4fff0ef          	jal	8000a0 <cprintf>
    if ((pid = fork()) == 0) {
  800556:	bf3ff0ef          	jal	800148 <fork>
  80055a:	e901                	bnez	a0,80056a <main+0x26>
        cprintf("I am the child. spinning ...\n");
  80055c:	00000517          	auipc	a0,0x0
  800560:	21450513          	addi	a0,a0,532 # 800770 <main+0x22c>
  800564:	b3dff0ef          	jal	8000a0 <cprintf>
        while (1);
  800568:	a001                	j	800568 <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  80056a:	842a                	mv	s0,a0
  80056c:	00000517          	auipc	a0,0x0
  800570:	22450513          	addi	a0,a0,548 # 800790 <main+0x24c>
  800574:	b2dff0ef          	jal	8000a0 <cprintf>

    yield();
  800578:	bd5ff0ef          	jal	80014c <yield>
    yield();
  80057c:	bd1ff0ef          	jal	80014c <yield>
    yield();
  800580:	bcdff0ef          	jal	80014c <yield>

    cprintf("I am the parent.  Killing the child...\n");
  800584:	00000517          	auipc	a0,0x0
  800588:	23450513          	addi	a0,a0,564 # 8007b8 <main+0x274>
  80058c:	b15ff0ef          	jal	8000a0 <cprintf>

    assert((ret = kill(pid)) == 0);
  800590:	8522                	mv	a0,s0
  800592:	bbdff0ef          	jal	80014e <kill>
  800596:	ed31                	bnez	a0,8005f2 <main+0xae>
    cprintf("kill returns %d\n", ret);
  800598:	4581                	li	a1,0
  80059a:	00000517          	auipc	a0,0x0
  80059e:	28650513          	addi	a0,a0,646 # 800820 <main+0x2dc>
  8005a2:	affff0ef          	jal	8000a0 <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8005a6:	8522                	mv	a0,s0
  8005a8:	4581                	li	a1,0
  8005aa:	ba1ff0ef          	jal	80014a <waitpid>
  8005ae:	e11d                	bnez	a0,8005d4 <main+0x90>
    cprintf("wait returns %d\n", ret);
  8005b0:	4581                	li	a1,0
  8005b2:	00000517          	auipc	a0,0x0
  8005b6:	2a650513          	addi	a0,a0,678 # 800858 <main+0x314>
  8005ba:	ae7ff0ef          	jal	8000a0 <cprintf>

    cprintf("spin may pass.\n");
  8005be:	00000517          	auipc	a0,0x0
  8005c2:	2b250513          	addi	a0,a0,690 # 800870 <main+0x32c>
  8005c6:	adbff0ef          	jal	8000a0 <cprintf>
    return 0;
}
  8005ca:	60a2                	ld	ra,8(sp)
  8005cc:	6402                	ld	s0,0(sp)
  8005ce:	4501                	li	a0,0
  8005d0:	0141                	addi	sp,sp,16
  8005d2:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  8005d4:	00000697          	auipc	a3,0x0
  8005d8:	26468693          	addi	a3,a3,612 # 800838 <main+0x2f4>
  8005dc:	00000617          	auipc	a2,0x0
  8005e0:	21c60613          	addi	a2,a2,540 # 8007f8 <main+0x2b4>
  8005e4:	45dd                	li	a1,23
  8005e6:	00000517          	auipc	a0,0x0
  8005ea:	22a50513          	addi	a0,a0,554 # 800810 <main+0x2cc>
  8005ee:	a39ff0ef          	jal	800026 <__panic>
    assert((ret = kill(pid)) == 0);
  8005f2:	00000697          	auipc	a3,0x0
  8005f6:	1ee68693          	addi	a3,a3,494 # 8007e0 <main+0x29c>
  8005fa:	00000617          	auipc	a2,0x0
  8005fe:	1fe60613          	addi	a2,a2,510 # 8007f8 <main+0x2b4>
  800602:	45d1                	li	a1,20
  800604:	00000517          	auipc	a0,0x0
  800608:	20c50513          	addi	a0,a0,524 # 800810 <main+0x2cc>
  80060c:	a1bff0ef          	jal	800026 <__panic>
