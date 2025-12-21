
obj/__user_badarg.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	128000ef          	jal	800148 <umain>
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
  800038:	5f450513          	addi	a0,a0,1524 # 800628 <main+0xec>
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
  80005a:	5f250513          	addi	a0,a0,1522 # 800648 <main+0x10c>
  80005e:	042000ef          	jal	8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0c8000ef          	jal	80012c <exit>

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
  80006e:	0b8000ef          	jal	800126 <sys_putc>
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
  800094:	126000ef          	jal	8001ba <vprintfmt>
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
  8000c8:	0f2000ef          	jal	8001ba <vprintfmt>
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

0000000000800126 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800126:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800128:	4579                	li	a0,30
  80012a:	b76d                	j	8000d4 <syscall>

000000000080012c <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80012c:	1141                	addi	sp,sp,-16
  80012e:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800130:	fe1ff0ef          	jal	800110 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800134:	00000517          	auipc	a0,0x0
  800138:	51c50513          	addi	a0,a0,1308 # 800650 <main+0x114>
  80013c:	f65ff0ef          	jal	8000a0 <cprintf>
    while (1);
  800140:	a001                	j	800140 <exit+0x14>

0000000000800142 <fork>:
}

int
fork(void) {
    return sys_fork();
  800142:	bfd1                	j	800116 <sys_fork>

0000000000800144 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800144:	bfd9                	j	80011a <sys_wait>

0000000000800146 <yield>:
}

void
yield(void) {
    sys_yield();
  800146:	bff1                	j	800122 <sys_yield>

0000000000800148 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800148:	1141                	addi	sp,sp,-16
  80014a:	e406                	sd	ra,8(sp)
    int ret = main();
  80014c:	3f0000ef          	jal	80053c <main>
    exit(ret);
  800150:	fddff0ef          	jal	80012c <exit>

0000000000800154 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800154:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800156:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015a:	f022                	sd	s0,32(sp)
  80015c:	ec26                	sd	s1,24(sp)
  80015e:	e84a                	sd	s2,16(sp)
  800160:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800162:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800166:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800168:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80016c:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800170:	84aa                	mv	s1,a0
  800172:	892e                	mv	s2,a1
    if (num >= base) {
  800174:	03067d63          	bgeu	a2,a6,8001ae <printnum+0x5a>
  800178:	e44e                	sd	s3,8(sp)
  80017a:	89be                	mv	s3,a5
        while (-- width > 0)
  80017c:	4785                	li	a5,1
  80017e:	00e7d763          	bge	a5,a4,80018c <printnum+0x38>
            putch(padc, putdat);
  800182:	85ca                	mv	a1,s2
  800184:	854e                	mv	a0,s3
        while (-- width > 0)
  800186:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800188:	9482                	jalr	s1
        while (-- width > 0)
  80018a:	fc65                	bnez	s0,800182 <printnum+0x2e>
  80018c:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80018e:	00000797          	auipc	a5,0x0
  800192:	4da78793          	addi	a5,a5,1242 # 800668 <main+0x12c>
  800196:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800198:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80019a:	0007c503          	lbu	a0,0(a5)
}
  80019e:	70a2                	ld	ra,40(sp)
  8001a0:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a2:	85ca                	mv	a1,s2
  8001a4:	87a6                	mv	a5,s1
}
  8001a6:	6942                	ld	s2,16(sp)
  8001a8:	64e2                	ld	s1,24(sp)
  8001aa:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001ac:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ae:	03065633          	divu	a2,a2,a6
  8001b2:	8722                	mv	a4,s0
  8001b4:	fa1ff0ef          	jal	800154 <printnum>
  8001b8:	bfd9                	j	80018e <printnum+0x3a>

00000000008001ba <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001ba:	7119                	addi	sp,sp,-128
  8001bc:	f4a6                	sd	s1,104(sp)
  8001be:	f0ca                	sd	s2,96(sp)
  8001c0:	ecce                	sd	s3,88(sp)
  8001c2:	e8d2                	sd	s4,80(sp)
  8001c4:	e4d6                	sd	s5,72(sp)
  8001c6:	e0da                	sd	s6,64(sp)
  8001c8:	f862                	sd	s8,48(sp)
  8001ca:	fc86                	sd	ra,120(sp)
  8001cc:	f8a2                	sd	s0,112(sp)
  8001ce:	fc5e                	sd	s7,56(sp)
  8001d0:	f466                	sd	s9,40(sp)
  8001d2:	f06a                	sd	s10,32(sp)
  8001d4:	ec6e                	sd	s11,24(sp)
  8001d6:	84aa                	mv	s1,a0
  8001d8:	8c32                	mv	s8,a2
  8001da:	8a36                	mv	s4,a3
  8001dc:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001de:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001e2:	05500b13          	li	s6,85
  8001e6:	00000a97          	auipc	s5,0x0
  8001ea:	642a8a93          	addi	s5,s5,1602 # 800828 <main+0x2ec>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ee:	000c4503          	lbu	a0,0(s8)
  8001f2:	001c0413          	addi	s0,s8,1
  8001f6:	01350a63          	beq	a0,s3,80020a <vprintfmt+0x50>
            if (ch == '\0') {
  8001fa:	cd0d                	beqz	a0,800234 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001fc:	85ca                	mv	a1,s2
  8001fe:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800200:	00044503          	lbu	a0,0(s0)
  800204:	0405                	addi	s0,s0,1
  800206:	ff351ae3          	bne	a0,s3,8001fa <vprintfmt+0x40>
        width = precision = -1;
  80020a:	5cfd                	li	s9,-1
  80020c:	8d66                	mv	s10,s9
        char padc = ' ';
  80020e:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800212:	4b81                	li	s7,0
  800214:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800216:	00044683          	lbu	a3,0(s0)
  80021a:	00140c13          	addi	s8,s0,1
  80021e:	fdd6859b          	addiw	a1,a3,-35
  800222:	0ff5f593          	zext.b	a1,a1
  800226:	02bb6663          	bltu	s6,a1,800252 <vprintfmt+0x98>
  80022a:	058a                	slli	a1,a1,0x2
  80022c:	95d6                	add	a1,a1,s5
  80022e:	4198                	lw	a4,0(a1)
  800230:	9756                	add	a4,a4,s5
  800232:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800234:	70e6                	ld	ra,120(sp)
  800236:	7446                	ld	s0,112(sp)
  800238:	74a6                	ld	s1,104(sp)
  80023a:	7906                	ld	s2,96(sp)
  80023c:	69e6                	ld	s3,88(sp)
  80023e:	6a46                	ld	s4,80(sp)
  800240:	6aa6                	ld	s5,72(sp)
  800242:	6b06                	ld	s6,64(sp)
  800244:	7be2                	ld	s7,56(sp)
  800246:	7c42                	ld	s8,48(sp)
  800248:	7ca2                	ld	s9,40(sp)
  80024a:	7d02                	ld	s10,32(sp)
  80024c:	6de2                	ld	s11,24(sp)
  80024e:	6109                	addi	sp,sp,128
  800250:	8082                	ret
            putch('%', putdat);
  800252:	85ca                	mv	a1,s2
  800254:	02500513          	li	a0,37
  800258:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  80025a:	fff44783          	lbu	a5,-1(s0)
  80025e:	02500713          	li	a4,37
  800262:	8c22                	mv	s8,s0
  800264:	f8e785e3          	beq	a5,a4,8001ee <vprintfmt+0x34>
  800268:	ffec4783          	lbu	a5,-2(s8)
  80026c:	1c7d                	addi	s8,s8,-1
  80026e:	fee79de3          	bne	a5,a4,800268 <vprintfmt+0xae>
  800272:	bfb5                	j	8001ee <vprintfmt+0x34>
                ch = *fmt;
  800274:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800278:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80027a:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80027e:	fd06071b          	addiw	a4,a2,-48
  800282:	24e56a63          	bltu	a0,a4,8004d6 <vprintfmt+0x31c>
                ch = *fmt;
  800286:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800288:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  80028a:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  80028e:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800292:	0197073b          	addw	a4,a4,s9
  800296:	0017171b          	slliw	a4,a4,0x1
  80029a:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  80029c:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002a0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002a2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002a6:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002aa:	feb570e3          	bgeu	a0,a1,80028a <vprintfmt+0xd0>
            if (width < 0)
  8002ae:	f60d54e3          	bgez	s10,800216 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002b2:	8d66                	mv	s10,s9
  8002b4:	5cfd                	li	s9,-1
  8002b6:	b785                	j	800216 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002b8:	8db6                	mv	s11,a3
  8002ba:	8462                	mv	s0,s8
  8002bc:	bfa9                	j	800216 <vprintfmt+0x5c>
  8002be:	8462                	mv	s0,s8
            altflag = 1;
  8002c0:	4b85                	li	s7,1
            goto reswitch;
  8002c2:	bf91                	j	800216 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002c4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002c6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002ca:	00f74463          	blt	a4,a5,8002d2 <vprintfmt+0x118>
    else if (lflag) {
  8002ce:	1a078763          	beqz	a5,80047c <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002d2:	000a3603          	ld	a2,0(s4)
  8002d6:	46c1                	li	a3,16
  8002d8:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002da:	000d879b          	sext.w	a5,s11
  8002de:	876a                	mv	a4,s10
  8002e0:	85ca                	mv	a1,s2
  8002e2:	8526                	mv	a0,s1
  8002e4:	e71ff0ef          	jal	800154 <printnum>
            break;
  8002e8:	b719                	j	8001ee <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002ea:	000a2503          	lw	a0,0(s4)
  8002ee:	85ca                	mv	a1,s2
  8002f0:	0a21                	addi	s4,s4,8
  8002f2:	9482                	jalr	s1
            break;
  8002f4:	bded                	j	8001ee <vprintfmt+0x34>
    if (lflag >= 2) {
  8002f6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002f8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002fc:	00f74463          	blt	a4,a5,800304 <vprintfmt+0x14a>
    else if (lflag) {
  800300:	16078963          	beqz	a5,800472 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800304:	000a3603          	ld	a2,0(s4)
  800308:	46a9                	li	a3,10
  80030a:	8a2e                	mv	s4,a1
  80030c:	b7f9                	j	8002da <vprintfmt+0x120>
            putch('0', putdat);
  80030e:	85ca                	mv	a1,s2
  800310:	03000513          	li	a0,48
  800314:	9482                	jalr	s1
            putch('x', putdat);
  800316:	85ca                	mv	a1,s2
  800318:	07800513          	li	a0,120
  80031c:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80031e:	000a3603          	ld	a2,0(s4)
            goto number;
  800322:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800324:	0a21                	addi	s4,s4,8
            goto number;
  800326:	bf55                	j	8002da <vprintfmt+0x120>
            putch(ch, putdat);
  800328:	85ca                	mv	a1,s2
  80032a:	02500513          	li	a0,37
  80032e:	9482                	jalr	s1
            break;
  800330:	bd7d                	j	8001ee <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800332:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800336:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800338:	0a21                	addi	s4,s4,8
            goto process_precision;
  80033a:	bf95                	j	8002ae <vprintfmt+0xf4>
    if (lflag >= 2) {
  80033c:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80033e:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800342:	00f74463          	blt	a4,a5,80034a <vprintfmt+0x190>
    else if (lflag) {
  800346:	12078163          	beqz	a5,800468 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  80034a:	000a3603          	ld	a2,0(s4)
  80034e:	46a1                	li	a3,8
  800350:	8a2e                	mv	s4,a1
  800352:	b761                	j	8002da <vprintfmt+0x120>
            if (width < 0)
  800354:	876a                	mv	a4,s10
  800356:	000d5363          	bgez	s10,80035c <vprintfmt+0x1a2>
  80035a:	4701                	li	a4,0
  80035c:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800360:	8462                	mv	s0,s8
            goto reswitch;
  800362:	bd55                	j	800216 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800364:	000d841b          	sext.w	s0,s11
  800368:	fd340793          	addi	a5,s0,-45
  80036c:	00f037b3          	snez	a5,a5
  800370:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800374:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800378:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80037a:	008a0793          	addi	a5,s4,8
  80037e:	e43e                	sd	a5,8(sp)
  800380:	100d8c63          	beqz	s11,800498 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800384:	12071363          	bnez	a4,8004aa <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800388:	000dc783          	lbu	a5,0(s11)
  80038c:	0007851b          	sext.w	a0,a5
  800390:	c78d                	beqz	a5,8003ba <vprintfmt+0x200>
  800392:	0d85                	addi	s11,s11,1
  800394:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800396:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80039a:	000cc563          	bltz	s9,8003a4 <vprintfmt+0x1ea>
  80039e:	3cfd                	addiw	s9,s9,-1
  8003a0:	008c8d63          	beq	s9,s0,8003ba <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003a4:	020b9663          	bnez	s7,8003d0 <vprintfmt+0x216>
                    putch(ch, putdat);
  8003a8:	85ca                	mv	a1,s2
  8003aa:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ac:	000dc783          	lbu	a5,0(s11)
  8003b0:	0d85                	addi	s11,s11,1
  8003b2:	3d7d                	addiw	s10,s10,-1
  8003b4:	0007851b          	sext.w	a0,a5
  8003b8:	f3ed                	bnez	a5,80039a <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003ba:	01a05963          	blez	s10,8003cc <vprintfmt+0x212>
                putch(' ', putdat);
  8003be:	85ca                	mv	a1,s2
  8003c0:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003c4:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003c6:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003c8:	fe0d1be3          	bnez	s10,8003be <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003cc:	6a22                	ld	s4,8(sp)
  8003ce:	b505                	j	8001ee <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003d0:	3781                	addiw	a5,a5,-32
  8003d2:	fcfa7be3          	bgeu	s4,a5,8003a8 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003d6:	03f00513          	li	a0,63
  8003da:	85ca                	mv	a1,s2
  8003dc:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003de:	000dc783          	lbu	a5,0(s11)
  8003e2:	0d85                	addi	s11,s11,1
  8003e4:	3d7d                	addiw	s10,s10,-1
  8003e6:	0007851b          	sext.w	a0,a5
  8003ea:	dbe1                	beqz	a5,8003ba <vprintfmt+0x200>
  8003ec:	fa0cd9e3          	bgez	s9,80039e <vprintfmt+0x1e4>
  8003f0:	b7c5                	j	8003d0 <vprintfmt+0x216>
            if (err < 0) {
  8003f2:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f6:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003f8:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003fa:	41f7d71b          	sraiw	a4,a5,0x1f
  8003fe:	8fb9                	xor	a5,a5,a4
  800400:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800404:	02d64563          	blt	a2,a3,80042e <vprintfmt+0x274>
  800408:	00000797          	auipc	a5,0x0
  80040c:	57878793          	addi	a5,a5,1400 # 800980 <error_string>
  800410:	00369713          	slli	a4,a3,0x3
  800414:	97ba                	add	a5,a5,a4
  800416:	639c                	ld	a5,0(a5)
  800418:	cb99                	beqz	a5,80042e <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  80041a:	86be                	mv	a3,a5
  80041c:	00000617          	auipc	a2,0x0
  800420:	27c60613          	addi	a2,a2,636 # 800698 <main+0x15c>
  800424:	85ca                	mv	a1,s2
  800426:	8526                	mv	a0,s1
  800428:	0d8000ef          	jal	800500 <printfmt>
  80042c:	b3c9                	j	8001ee <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  80042e:	00000617          	auipc	a2,0x0
  800432:	25a60613          	addi	a2,a2,602 # 800688 <main+0x14c>
  800436:	85ca                	mv	a1,s2
  800438:	8526                	mv	a0,s1
  80043a:	0c6000ef          	jal	800500 <printfmt>
  80043e:	bb45                	j	8001ee <vprintfmt+0x34>
    if (lflag >= 2) {
  800440:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800442:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800446:	00f74363          	blt	a4,a5,80044c <vprintfmt+0x292>
    else if (lflag) {
  80044a:	cf81                	beqz	a5,800462 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  80044c:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800450:	02044b63          	bltz	s0,800486 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800454:	8622                	mv	a2,s0
  800456:	8a5e                	mv	s4,s7
  800458:	46a9                	li	a3,10
  80045a:	b541                	j	8002da <vprintfmt+0x120>
            lflag ++;
  80045c:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  80045e:	8462                	mv	s0,s8
            goto reswitch;
  800460:	bb5d                	j	800216 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800462:	000a2403          	lw	s0,0(s4)
  800466:	b7ed                	j	800450 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800468:	000a6603          	lwu	a2,0(s4)
  80046c:	46a1                	li	a3,8
  80046e:	8a2e                	mv	s4,a1
  800470:	b5ad                	j	8002da <vprintfmt+0x120>
  800472:	000a6603          	lwu	a2,0(s4)
  800476:	46a9                	li	a3,10
  800478:	8a2e                	mv	s4,a1
  80047a:	b585                	j	8002da <vprintfmt+0x120>
  80047c:	000a6603          	lwu	a2,0(s4)
  800480:	46c1                	li	a3,16
  800482:	8a2e                	mv	s4,a1
  800484:	bd99                	j	8002da <vprintfmt+0x120>
                putch('-', putdat);
  800486:	85ca                	mv	a1,s2
  800488:	02d00513          	li	a0,45
  80048c:	9482                	jalr	s1
                num = -(long long)num;
  80048e:	40800633          	neg	a2,s0
  800492:	8a5e                	mv	s4,s7
  800494:	46a9                	li	a3,10
  800496:	b591                	j	8002da <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800498:	e329                	bnez	a4,8004da <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049a:	02800793          	li	a5,40
  80049e:	853e                	mv	a0,a5
  8004a0:	00000d97          	auipc	s11,0x0
  8004a4:	1e1d8d93          	addi	s11,s11,481 # 800681 <main+0x145>
  8004a8:	b5f5                	j	800394 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004aa:	85e6                	mv	a1,s9
  8004ac:	856e                	mv	a0,s11
  8004ae:	072000ef          	jal	800520 <strnlen>
  8004b2:	40ad0d3b          	subw	s10,s10,a0
  8004b6:	01a05863          	blez	s10,8004c6 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004ba:	85ca                	mv	a1,s2
  8004bc:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004be:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004c0:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c2:	fe0d1ce3          	bnez	s10,8004ba <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c6:	000dc783          	lbu	a5,0(s11)
  8004ca:	0007851b          	sext.w	a0,a5
  8004ce:	ec0792e3          	bnez	a5,800392 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004d2:	6a22                	ld	s4,8(sp)
  8004d4:	bb29                	j	8001ee <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004d6:	8462                	mv	s0,s8
  8004d8:	bbd9                	j	8002ae <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004da:	85e6                	mv	a1,s9
  8004dc:	00000517          	auipc	a0,0x0
  8004e0:	1a450513          	addi	a0,a0,420 # 800680 <main+0x144>
  8004e4:	03c000ef          	jal	800520 <strnlen>
  8004e8:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ec:	02800793          	li	a5,40
                p = "(null)";
  8004f0:	00000d97          	auipc	s11,0x0
  8004f4:	190d8d93          	addi	s11,s11,400 # 800680 <main+0x144>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004f8:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fa:	fda040e3          	bgtz	s10,8004ba <vprintfmt+0x300>
  8004fe:	bd51                	j	800392 <vprintfmt+0x1d8>

0000000000800500 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800500:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800502:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800506:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800508:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050a:	ec06                	sd	ra,24(sp)
  80050c:	f83a                	sd	a4,48(sp)
  80050e:	fc3e                	sd	a5,56(sp)
  800510:	e0c2                	sd	a6,64(sp)
  800512:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800514:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800516:	ca5ff0ef          	jal	8001ba <vprintfmt>
}
  80051a:	60e2                	ld	ra,24(sp)
  80051c:	6161                	addi	sp,sp,80
  80051e:	8082                	ret

0000000000800520 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800520:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800522:	e589                	bnez	a1,80052c <strnlen+0xc>
  800524:	a811                	j	800538 <strnlen+0x18>
        cnt ++;
  800526:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800528:	00f58863          	beq	a1,a5,800538 <strnlen+0x18>
  80052c:	00f50733          	add	a4,a0,a5
  800530:	00074703          	lbu	a4,0(a4)
  800534:	fb6d                	bnez	a4,800526 <strnlen+0x6>
  800536:	85be                	mv	a1,a5
    }
    return cnt;
}
  800538:	852e                	mv	a0,a1
  80053a:	8082                	ret

000000000080053c <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80053c:	1101                	addi	sp,sp,-32
  80053e:	ec06                	sd	ra,24(sp)
  800540:	e822                	sd	s0,16(sp)
    int pid, exit_code;
    if ((pid = fork()) == 0) {
  800542:	c01ff0ef          	jal	800142 <fork>
  800546:	c169                	beqz	a0,800608 <main+0xcc>
  800548:	842a                	mv	s0,a0
        for (i = 0; i < 10; i ++) {
            yield();
        }
        exit(0xbeaf);
    }
    assert(pid > 0);
  80054a:	0aa05063          	blez	a0,8005ea <main+0xae>
    assert(waitpid(-1, NULL) != 0);
  80054e:	4581                	li	a1,0
  800550:	557d                	li	a0,-1
  800552:	bf3ff0ef          	jal	800144 <waitpid>
  800556:	c93d                	beqz	a0,8005cc <main+0x90>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  800558:	458d                	li	a1,3
  80055a:	05fa                	slli	a1,a1,0x1e
  80055c:	8522                	mv	a0,s0
  80055e:	be7ff0ef          	jal	800144 <waitpid>
  800562:	c531                	beqz	a0,8005ae <main+0x72>
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  800564:	8522                	mv	a0,s0
  800566:	006c                	addi	a1,sp,12
  800568:	bddff0ef          	jal	800144 <waitpid>
  80056c:	e115                	bnez	a0,800590 <main+0x54>
  80056e:	4732                	lw	a4,12(sp)
  800570:	67b1                	lui	a5,0xc
  800572:	eaf78793          	addi	a5,a5,-337 # beaf <_start-0x7f4171>
  800576:	00f71d63          	bne	a4,a5,800590 <main+0x54>
    cprintf("badarg pass.\n");
  80057a:	00000517          	auipc	a0,0x0
  80057e:	29e50513          	addi	a0,a0,670 # 800818 <main+0x2dc>
  800582:	b1fff0ef          	jal	8000a0 <cprintf>
    return 0;
}
  800586:	60e2                	ld	ra,24(sp)
  800588:	6442                	ld	s0,16(sp)
  80058a:	4501                	li	a0,0
  80058c:	6105                	addi	sp,sp,32
  80058e:	8082                	ret
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  800590:	00000697          	auipc	a3,0x0
  800594:	25068693          	addi	a3,a3,592 # 8007e0 <main+0x2a4>
  800598:	00000617          	auipc	a2,0x0
  80059c:	1e060613          	addi	a2,a2,480 # 800778 <main+0x23c>
  8005a0:	45c9                	li	a1,18
  8005a2:	00000517          	auipc	a0,0x0
  8005a6:	1ee50513          	addi	a0,a0,494 # 800790 <main+0x254>
  8005aa:	a7dff0ef          	jal	800026 <__panic>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  8005ae:	00000697          	auipc	a3,0x0
  8005b2:	20a68693          	addi	a3,a3,522 # 8007b8 <main+0x27c>
  8005b6:	00000617          	auipc	a2,0x0
  8005ba:	1c260613          	addi	a2,a2,450 # 800778 <main+0x23c>
  8005be:	45c5                	li	a1,17
  8005c0:	00000517          	auipc	a0,0x0
  8005c4:	1d050513          	addi	a0,a0,464 # 800790 <main+0x254>
  8005c8:	a5fff0ef          	jal	800026 <__panic>
    assert(waitpid(-1, NULL) != 0);
  8005cc:	00000697          	auipc	a3,0x0
  8005d0:	1d468693          	addi	a3,a3,468 # 8007a0 <main+0x264>
  8005d4:	00000617          	auipc	a2,0x0
  8005d8:	1a460613          	addi	a2,a2,420 # 800778 <main+0x23c>
  8005dc:	45c1                	li	a1,16
  8005de:	00000517          	auipc	a0,0x0
  8005e2:	1b250513          	addi	a0,a0,434 # 800790 <main+0x254>
  8005e6:	a41ff0ef          	jal	800026 <__panic>
    assert(pid > 0);
  8005ea:	00000697          	auipc	a3,0x0
  8005ee:	18668693          	addi	a3,a3,390 # 800770 <main+0x234>
  8005f2:	00000617          	auipc	a2,0x0
  8005f6:	18660613          	addi	a2,a2,390 # 800778 <main+0x23c>
  8005fa:	45bd                	li	a1,15
  8005fc:	00000517          	auipc	a0,0x0
  800600:	19450513          	addi	a0,a0,404 # 800790 <main+0x254>
  800604:	a23ff0ef          	jal	800026 <__panic>
        cprintf("fork ok.\n");
  800608:	00000517          	auipc	a0,0x0
  80060c:	15850513          	addi	a0,a0,344 # 800760 <main+0x224>
  800610:	a91ff0ef          	jal	8000a0 <cprintf>
  800614:	4429                	li	s0,10
        for (i = 0; i < 10; i ++) {
  800616:	347d                	addiw	s0,s0,-1
            yield();
  800618:	b2fff0ef          	jal	800146 <yield>
        for (i = 0; i < 10; i ++) {
  80061c:	fc6d                	bnez	s0,800616 <main+0xda>
        exit(0xbeaf);
  80061e:	6531                	lui	a0,0xc
  800620:	eaf50513          	addi	a0,a0,-337 # beaf <_start-0x7f4171>
  800624:	b09ff0ef          	jal	80012c <exit>
