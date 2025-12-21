
obj/__user_waitkill.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	136000ef          	jal	800156 <umain>
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
  800038:	65c50513          	addi	a0,a0,1628 # 800690 <main+0xbe>
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
  80005a:	77250513          	addi	a0,a0,1906 # 8007c8 <main+0x1f6>
  80005e:	042000ef          	jal	8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0d2000ef          	jal	800136 <exit>

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
  80006e:	0c2000ef          	jal	800130 <sys_putc>
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
  800094:	134000ef          	jal	8001c8 <vprintfmt>
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
  8000c8:	100000ef          	jal	8001c8 <vprintfmt>
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

000000000080012c <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  80012c:	4549                	li	a0,18
  80012e:	b75d                	j	8000d4 <syscall>

0000000000800130 <sys_putc>:
}

int
sys_putc(int64_t c) {
  800130:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800132:	4579                	li	a0,30
  800134:	b745                	j	8000d4 <syscall>

0000000000800136 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800136:	1141                	addi	sp,sp,-16
  800138:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80013a:	fd7ff0ef          	jal	800110 <sys_exit>
    cprintf("BUG: exit failed.\n");
  80013e:	00000517          	auipc	a0,0x0
  800142:	57250513          	addi	a0,a0,1394 # 8006b0 <main+0xde>
  800146:	f5bff0ef          	jal	8000a0 <cprintf>
    while (1);
  80014a:	a001                	j	80014a <exit+0x14>

000000000080014c <fork>:
}

int
fork(void) {
    return sys_fork();
  80014c:	b7e9                	j	800116 <sys_fork>

000000000080014e <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  80014e:	b7f1                	j	80011a <sys_wait>

0000000000800150 <yield>:
}

void
yield(void) {
    sys_yield();
  800150:	bfc9                	j	800122 <sys_yield>

0000000000800152 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  800152:	bfd1                	j	800126 <sys_kill>

0000000000800154 <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  800154:	bfe1                	j	80012c <sys_getpid>

0000000000800156 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800156:	1141                	addi	sp,sp,-16
  800158:	e406                	sd	ra,8(sp)
    int ret = main();
  80015a:	478000ef          	jal	8005d2 <main>
    exit(ret);
  80015e:	fd9ff0ef          	jal	800136 <exit>

0000000000800162 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800162:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800164:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800168:	f022                	sd	s0,32(sp)
  80016a:	ec26                	sd	s1,24(sp)
  80016c:	e84a                	sd	s2,16(sp)
  80016e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800170:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800174:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800176:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80017a:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80017e:	84aa                	mv	s1,a0
  800180:	892e                	mv	s2,a1
    if (num >= base) {
  800182:	03067d63          	bgeu	a2,a6,8001bc <printnum+0x5a>
  800186:	e44e                	sd	s3,8(sp)
  800188:	89be                	mv	s3,a5
        while (-- width > 0)
  80018a:	4785                	li	a5,1
  80018c:	00e7d763          	bge	a5,a4,80019a <printnum+0x38>
            putch(padc, putdat);
  800190:	85ca                	mv	a1,s2
  800192:	854e                	mv	a0,s3
        while (-- width > 0)
  800194:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800196:	9482                	jalr	s1
        while (-- width > 0)
  800198:	fc65                	bnez	s0,800190 <printnum+0x2e>
  80019a:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80019c:	00000797          	auipc	a5,0x0
  8001a0:	52c78793          	addi	a5,a5,1324 # 8006c8 <main+0xf6>
  8001a4:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a8:	0007c503          	lbu	a0,0(a5)
}
  8001ac:	70a2                	ld	ra,40(sp)
  8001ae:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b0:	85ca                	mv	a1,s2
  8001b2:	87a6                	mv	a5,s1
}
  8001b4:	6942                	ld	s2,16(sp)
  8001b6:	64e2                	ld	s1,24(sp)
  8001b8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001ba:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001bc:	03065633          	divu	a2,a2,a6
  8001c0:	8722                	mv	a4,s0
  8001c2:	fa1ff0ef          	jal	800162 <printnum>
  8001c6:	bfd9                	j	80019c <printnum+0x3a>

00000000008001c8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c8:	7119                	addi	sp,sp,-128
  8001ca:	f4a6                	sd	s1,104(sp)
  8001cc:	f0ca                	sd	s2,96(sp)
  8001ce:	ecce                	sd	s3,88(sp)
  8001d0:	e8d2                	sd	s4,80(sp)
  8001d2:	e4d6                	sd	s5,72(sp)
  8001d4:	e0da                	sd	s6,64(sp)
  8001d6:	f862                	sd	s8,48(sp)
  8001d8:	fc86                	sd	ra,120(sp)
  8001da:	f8a2                	sd	s0,112(sp)
  8001dc:	fc5e                	sd	s7,56(sp)
  8001de:	f466                	sd	s9,40(sp)
  8001e0:	f06a                	sd	s10,32(sp)
  8001e2:	ec6e                	sd	s11,24(sp)
  8001e4:	84aa                	mv	s1,a0
  8001e6:	8c32                	mv	s8,a2
  8001e8:	8a36                	mv	s4,a3
  8001ea:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ec:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001f0:	05500b13          	li	s6,85
  8001f4:	00000a97          	auipc	s5,0x0
  8001f8:	688a8a93          	addi	s5,s5,1672 # 80087c <main+0x2aa>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fc:	000c4503          	lbu	a0,0(s8)
  800200:	001c0413          	addi	s0,s8,1
  800204:	01350a63          	beq	a0,s3,800218 <vprintfmt+0x50>
            if (ch == '\0') {
  800208:	cd0d                	beqz	a0,800242 <vprintfmt+0x7a>
            putch(ch, putdat);
  80020a:	85ca                	mv	a1,s2
  80020c:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020e:	00044503          	lbu	a0,0(s0)
  800212:	0405                	addi	s0,s0,1
  800214:	ff351ae3          	bne	a0,s3,800208 <vprintfmt+0x40>
        width = precision = -1;
  800218:	5cfd                	li	s9,-1
  80021a:	8d66                	mv	s10,s9
        char padc = ' ';
  80021c:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800220:	4b81                	li	s7,0
  800222:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800224:	00044683          	lbu	a3,0(s0)
  800228:	00140c13          	addi	s8,s0,1
  80022c:	fdd6859b          	addiw	a1,a3,-35
  800230:	0ff5f593          	zext.b	a1,a1
  800234:	02bb6663          	bltu	s6,a1,800260 <vprintfmt+0x98>
  800238:	058a                	slli	a1,a1,0x2
  80023a:	95d6                	add	a1,a1,s5
  80023c:	4198                	lw	a4,0(a1)
  80023e:	9756                	add	a4,a4,s5
  800240:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800242:	70e6                	ld	ra,120(sp)
  800244:	7446                	ld	s0,112(sp)
  800246:	74a6                	ld	s1,104(sp)
  800248:	7906                	ld	s2,96(sp)
  80024a:	69e6                	ld	s3,88(sp)
  80024c:	6a46                	ld	s4,80(sp)
  80024e:	6aa6                	ld	s5,72(sp)
  800250:	6b06                	ld	s6,64(sp)
  800252:	7be2                	ld	s7,56(sp)
  800254:	7c42                	ld	s8,48(sp)
  800256:	7ca2                	ld	s9,40(sp)
  800258:	7d02                	ld	s10,32(sp)
  80025a:	6de2                	ld	s11,24(sp)
  80025c:	6109                	addi	sp,sp,128
  80025e:	8082                	ret
            putch('%', putdat);
  800260:	85ca                	mv	a1,s2
  800262:	02500513          	li	a0,37
  800266:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800268:	fff44783          	lbu	a5,-1(s0)
  80026c:	02500713          	li	a4,37
  800270:	8c22                	mv	s8,s0
  800272:	f8e785e3          	beq	a5,a4,8001fc <vprintfmt+0x34>
  800276:	ffec4783          	lbu	a5,-2(s8)
  80027a:	1c7d                	addi	s8,s8,-1
  80027c:	fee79de3          	bne	a5,a4,800276 <vprintfmt+0xae>
  800280:	bfb5                	j	8001fc <vprintfmt+0x34>
                ch = *fmt;
  800282:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800286:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800288:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80028c:	fd06071b          	addiw	a4,a2,-48
  800290:	24e56a63          	bltu	a0,a4,8004e4 <vprintfmt+0x31c>
                ch = *fmt;
  800294:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800296:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800298:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  80029c:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  8002a0:	0197073b          	addw	a4,a4,s9
  8002a4:	0017171b          	slliw	a4,a4,0x1
  8002a8:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  8002aa:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002ae:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002b0:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002b4:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002b8:	feb570e3          	bgeu	a0,a1,800298 <vprintfmt+0xd0>
            if (width < 0)
  8002bc:	f60d54e3          	bgez	s10,800224 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002c0:	8d66                	mv	s10,s9
  8002c2:	5cfd                	li	s9,-1
  8002c4:	b785                	j	800224 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002c6:	8db6                	mv	s11,a3
  8002c8:	8462                	mv	s0,s8
  8002ca:	bfa9                	j	800224 <vprintfmt+0x5c>
  8002cc:	8462                	mv	s0,s8
            altflag = 1;
  8002ce:	4b85                	li	s7,1
            goto reswitch;
  8002d0:	bf91                	j	800224 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002d2:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002d4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002d8:	00f74463          	blt	a4,a5,8002e0 <vprintfmt+0x118>
    else if (lflag) {
  8002dc:	1a078763          	beqz	a5,80048a <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002e0:	000a3603          	ld	a2,0(s4)
  8002e4:	46c1                	li	a3,16
  8002e6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002e8:	000d879b          	sext.w	a5,s11
  8002ec:	876a                	mv	a4,s10
  8002ee:	85ca                	mv	a1,s2
  8002f0:	8526                	mv	a0,s1
  8002f2:	e71ff0ef          	jal	800162 <printnum>
            break;
  8002f6:	b719                	j	8001fc <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002f8:	000a2503          	lw	a0,0(s4)
  8002fc:	85ca                	mv	a1,s2
  8002fe:	0a21                	addi	s4,s4,8
  800300:	9482                	jalr	s1
            break;
  800302:	bded                	j	8001fc <vprintfmt+0x34>
    if (lflag >= 2) {
  800304:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800306:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  80030a:	00f74463          	blt	a4,a5,800312 <vprintfmt+0x14a>
    else if (lflag) {
  80030e:	16078963          	beqz	a5,800480 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800312:	000a3603          	ld	a2,0(s4)
  800316:	46a9                	li	a3,10
  800318:	8a2e                	mv	s4,a1
  80031a:	b7f9                	j	8002e8 <vprintfmt+0x120>
            putch('0', putdat);
  80031c:	85ca                	mv	a1,s2
  80031e:	03000513          	li	a0,48
  800322:	9482                	jalr	s1
            putch('x', putdat);
  800324:	85ca                	mv	a1,s2
  800326:	07800513          	li	a0,120
  80032a:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80032c:	000a3603          	ld	a2,0(s4)
            goto number;
  800330:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800332:	0a21                	addi	s4,s4,8
            goto number;
  800334:	bf55                	j	8002e8 <vprintfmt+0x120>
            putch(ch, putdat);
  800336:	85ca                	mv	a1,s2
  800338:	02500513          	li	a0,37
  80033c:	9482                	jalr	s1
            break;
  80033e:	bd7d                	j	8001fc <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800340:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800344:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800346:	0a21                	addi	s4,s4,8
            goto process_precision;
  800348:	bf95                	j	8002bc <vprintfmt+0xf4>
    if (lflag >= 2) {
  80034a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80034c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800350:	00f74463          	blt	a4,a5,800358 <vprintfmt+0x190>
    else if (lflag) {
  800354:	12078163          	beqz	a5,800476 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800358:	000a3603          	ld	a2,0(s4)
  80035c:	46a1                	li	a3,8
  80035e:	8a2e                	mv	s4,a1
  800360:	b761                	j	8002e8 <vprintfmt+0x120>
            if (width < 0)
  800362:	876a                	mv	a4,s10
  800364:	000d5363          	bgez	s10,80036a <vprintfmt+0x1a2>
  800368:	4701                	li	a4,0
  80036a:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  80036e:	8462                	mv	s0,s8
            goto reswitch;
  800370:	bd55                	j	800224 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800372:	000d841b          	sext.w	s0,s11
  800376:	fd340793          	addi	a5,s0,-45
  80037a:	00f037b3          	snez	a5,a5
  80037e:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800382:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800386:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800388:	008a0793          	addi	a5,s4,8
  80038c:	e43e                	sd	a5,8(sp)
  80038e:	100d8c63          	beqz	s11,8004a6 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800392:	12071363          	bnez	a4,8004b8 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800396:	000dc783          	lbu	a5,0(s11)
  80039a:	0007851b          	sext.w	a0,a5
  80039e:	c78d                	beqz	a5,8003c8 <vprintfmt+0x200>
  8003a0:	0d85                	addi	s11,s11,1
  8003a2:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  8003a4:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a8:	000cc563          	bltz	s9,8003b2 <vprintfmt+0x1ea>
  8003ac:	3cfd                	addiw	s9,s9,-1
  8003ae:	008c8d63          	beq	s9,s0,8003c8 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003b2:	020b9663          	bnez	s7,8003de <vprintfmt+0x216>
                    putch(ch, putdat);
  8003b6:	85ca                	mv	a1,s2
  8003b8:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ba:	000dc783          	lbu	a5,0(s11)
  8003be:	0d85                	addi	s11,s11,1
  8003c0:	3d7d                	addiw	s10,s10,-1
  8003c2:	0007851b          	sext.w	a0,a5
  8003c6:	f3ed                	bnez	a5,8003a8 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003c8:	01a05963          	blez	s10,8003da <vprintfmt+0x212>
                putch(' ', putdat);
  8003cc:	85ca                	mv	a1,s2
  8003ce:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003d2:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003d4:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003d6:	fe0d1be3          	bnez	s10,8003cc <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003da:	6a22                	ld	s4,8(sp)
  8003dc:	b505                	j	8001fc <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003de:	3781                	addiw	a5,a5,-32
  8003e0:	fcfa7be3          	bgeu	s4,a5,8003b6 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003e4:	03f00513          	li	a0,63
  8003e8:	85ca                	mv	a1,s2
  8003ea:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ec:	000dc783          	lbu	a5,0(s11)
  8003f0:	0d85                	addi	s11,s11,1
  8003f2:	3d7d                	addiw	s10,s10,-1
  8003f4:	0007851b          	sext.w	a0,a5
  8003f8:	dbe1                	beqz	a5,8003c8 <vprintfmt+0x200>
  8003fa:	fa0cd9e3          	bgez	s9,8003ac <vprintfmt+0x1e4>
  8003fe:	b7c5                	j	8003de <vprintfmt+0x216>
            if (err < 0) {
  800400:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800404:	4661                	li	a2,24
            err = va_arg(ap, int);
  800406:	0a21                	addi	s4,s4,8
            if (err < 0) {
  800408:	41f7d71b          	sraiw	a4,a5,0x1f
  80040c:	8fb9                	xor	a5,a5,a4
  80040e:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800412:	02d64563          	blt	a2,a3,80043c <vprintfmt+0x274>
  800416:	00000797          	auipc	a5,0x0
  80041a:	5c278793          	addi	a5,a5,1474 # 8009d8 <error_string>
  80041e:	00369713          	slli	a4,a3,0x3
  800422:	97ba                	add	a5,a5,a4
  800424:	639c                	ld	a5,0(a5)
  800426:	cb99                	beqz	a5,80043c <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800428:	86be                	mv	a3,a5
  80042a:	00000617          	auipc	a2,0x0
  80042e:	2ce60613          	addi	a2,a2,718 # 8006f8 <main+0x126>
  800432:	85ca                	mv	a1,s2
  800434:	8526                	mv	a0,s1
  800436:	0d8000ef          	jal	80050e <printfmt>
  80043a:	b3c9                	j	8001fc <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  80043c:	00000617          	auipc	a2,0x0
  800440:	2ac60613          	addi	a2,a2,684 # 8006e8 <main+0x116>
  800444:	85ca                	mv	a1,s2
  800446:	8526                	mv	a0,s1
  800448:	0c6000ef          	jal	80050e <printfmt>
  80044c:	bb45                	j	8001fc <vprintfmt+0x34>
    if (lflag >= 2) {
  80044e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800450:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800454:	00f74363          	blt	a4,a5,80045a <vprintfmt+0x292>
    else if (lflag) {
  800458:	cf81                	beqz	a5,800470 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  80045a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80045e:	02044b63          	bltz	s0,800494 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800462:	8622                	mv	a2,s0
  800464:	8a5e                	mv	s4,s7
  800466:	46a9                	li	a3,10
  800468:	b541                	j	8002e8 <vprintfmt+0x120>
            lflag ++;
  80046a:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  80046c:	8462                	mv	s0,s8
            goto reswitch;
  80046e:	bb5d                	j	800224 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800470:	000a2403          	lw	s0,0(s4)
  800474:	b7ed                	j	80045e <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800476:	000a6603          	lwu	a2,0(s4)
  80047a:	46a1                	li	a3,8
  80047c:	8a2e                	mv	s4,a1
  80047e:	b5ad                	j	8002e8 <vprintfmt+0x120>
  800480:	000a6603          	lwu	a2,0(s4)
  800484:	46a9                	li	a3,10
  800486:	8a2e                	mv	s4,a1
  800488:	b585                	j	8002e8 <vprintfmt+0x120>
  80048a:	000a6603          	lwu	a2,0(s4)
  80048e:	46c1                	li	a3,16
  800490:	8a2e                	mv	s4,a1
  800492:	bd99                	j	8002e8 <vprintfmt+0x120>
                putch('-', putdat);
  800494:	85ca                	mv	a1,s2
  800496:	02d00513          	li	a0,45
  80049a:	9482                	jalr	s1
                num = -(long long)num;
  80049c:	40800633          	neg	a2,s0
  8004a0:	8a5e                	mv	s4,s7
  8004a2:	46a9                	li	a3,10
  8004a4:	b591                	j	8002e8 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  8004a6:	e329                	bnez	a4,8004e8 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a8:	02800793          	li	a5,40
  8004ac:	853e                	mv	a0,a5
  8004ae:	00000d97          	auipc	s11,0x0
  8004b2:	233d8d93          	addi	s11,s11,563 # 8006e1 <main+0x10f>
  8004b6:	b5f5                	j	8003a2 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b8:	85e6                	mv	a1,s9
  8004ba:	856e                	mv	a0,s11
  8004bc:	072000ef          	jal	80052e <strnlen>
  8004c0:	40ad0d3b          	subw	s10,s10,a0
  8004c4:	01a05863          	blez	s10,8004d4 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004c8:	85ca                	mv	a1,s2
  8004ca:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004cc:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004ce:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d0:	fe0d1ce3          	bnez	s10,8004c8 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004d4:	000dc783          	lbu	a5,0(s11)
  8004d8:	0007851b          	sext.w	a0,a5
  8004dc:	ec0792e3          	bnez	a5,8003a0 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004e0:	6a22                	ld	s4,8(sp)
  8004e2:	bb29                	j	8001fc <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004e4:	8462                	mv	s0,s8
  8004e6:	bbd9                	j	8002bc <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004e8:	85e6                	mv	a1,s9
  8004ea:	00000517          	auipc	a0,0x0
  8004ee:	1f650513          	addi	a0,a0,502 # 8006e0 <main+0x10e>
  8004f2:	03c000ef          	jal	80052e <strnlen>
  8004f6:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004fa:	02800793          	li	a5,40
                p = "(null)";
  8004fe:	00000d97          	auipc	s11,0x0
  800502:	1e2d8d93          	addi	s11,s11,482 # 8006e0 <main+0x10e>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800506:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  800508:	fda040e3          	bgtz	s10,8004c8 <vprintfmt+0x300>
  80050c:	bd51                	j	8003a0 <vprintfmt+0x1d8>

000000000080050e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800510:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800514:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800516:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800518:	ec06                	sd	ra,24(sp)
  80051a:	f83a                	sd	a4,48(sp)
  80051c:	fc3e                	sd	a5,56(sp)
  80051e:	e0c2                	sd	a6,64(sp)
  800520:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800522:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800524:	ca5ff0ef          	jal	8001c8 <vprintfmt>
}
  800528:	60e2                	ld	ra,24(sp)
  80052a:	6161                	addi	sp,sp,80
  80052c:	8082                	ret

000000000080052e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80052e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800530:	e589                	bnez	a1,80053a <strnlen+0xc>
  800532:	a811                	j	800546 <strnlen+0x18>
        cnt ++;
  800534:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800536:	00f58863          	beq	a1,a5,800546 <strnlen+0x18>
  80053a:	00f50733          	add	a4,a0,a5
  80053e:	00074703          	lbu	a4,0(a4)
  800542:	fb6d                	bnez	a4,800534 <strnlen+0x6>
  800544:	85be                	mv	a1,a5
    }
    return cnt;
}
  800546:	852e                	mv	a0,a1
  800548:	8082                	ret

000000000080054a <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  80054a:	1141                	addi	sp,sp,-16
  80054c:	e406                	sd	ra,8(sp)
    yield();
  80054e:	c03ff0ef          	jal	800150 <yield>
    yield();
  800552:	bffff0ef          	jal	800150 <yield>
    yield();
  800556:	bfbff0ef          	jal	800150 <yield>
    yield();
  80055a:	bf7ff0ef          	jal	800150 <yield>
    yield();
  80055e:	bf3ff0ef          	jal	800150 <yield>
    yield();
}
  800562:	60a2                	ld	ra,8(sp)
  800564:	0141                	addi	sp,sp,16
    yield();
  800566:	b6ed                	j	800150 <yield>

0000000000800568 <loop>:

int parent, pid1, pid2;

void
loop(void) {
  800568:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  80056a:	00000517          	auipc	a0,0x0
  80056e:	25650513          	addi	a0,a0,598 # 8007c0 <main+0x1ee>
loop(void) {
  800572:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  800574:	b2dff0ef          	jal	8000a0 <cprintf>
    while (1);
  800578:	a001                	j	800578 <loop+0x10>

000000000080057a <work>:
}

void
work(void) {
  80057a:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  80057c:	00000517          	auipc	a0,0x0
  800580:	25450513          	addi	a0,a0,596 # 8007d0 <main+0x1fe>
work(void) {
  800584:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  800586:	b1bff0ef          	jal	8000a0 <cprintf>
    do_yield();
  80058a:	fc1ff0ef          	jal	80054a <do_yield>
    if (kill(parent) == 0) {
  80058e:	00001517          	auipc	a0,0x1
  800592:	a7a52503          	lw	a0,-1414(a0) # 801008 <parent>
  800596:	bbdff0ef          	jal	800152 <kill>
  80059a:	e105                	bnez	a0,8005ba <work+0x40>
        cprintf("kill parent ok.\n");
  80059c:	00000517          	auipc	a0,0x0
  8005a0:	24450513          	addi	a0,a0,580 # 8007e0 <main+0x20e>
  8005a4:	afdff0ef          	jal	8000a0 <cprintf>
        do_yield();
  8005a8:	fa3ff0ef          	jal	80054a <do_yield>
        if (kill(pid1) == 0) {
  8005ac:	00001517          	auipc	a0,0x1
  8005b0:	a5852503          	lw	a0,-1448(a0) # 801004 <pid1>
  8005b4:	b9fff0ef          	jal	800152 <kill>
  8005b8:	c501                	beqz	a0,8005c0 <work+0x46>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  8005ba:	557d                	li	a0,-1
  8005bc:	b7bff0ef          	jal	800136 <exit>
            cprintf("kill child1 ok.\n");
  8005c0:	00000517          	auipc	a0,0x0
  8005c4:	23850513          	addi	a0,a0,568 # 8007f8 <main+0x226>
  8005c8:	ad9ff0ef          	jal	8000a0 <cprintf>
            exit(0);
  8005cc:	4501                	li	a0,0
  8005ce:	b69ff0ef          	jal	800136 <exit>

00000000008005d2 <main>:
}

int
main(void) {
  8005d2:	1141                	addi	sp,sp,-16
  8005d4:	e406                	sd	ra,8(sp)
    parent = getpid();
  8005d6:	b7fff0ef          	jal	800154 <getpid>
  8005da:	00001797          	auipc	a5,0x1
  8005de:	a2a7a723          	sw	a0,-1490(a5) # 801008 <parent>
    if ((pid1 = fork()) == 0) {
  8005e2:	b6bff0ef          	jal	80014c <fork>
  8005e6:	00001797          	auipc	a5,0x1
  8005ea:	a0a7af23          	sw	a0,-1506(a5) # 801004 <pid1>
  8005ee:	c92d                	beqz	a0,800660 <main+0x8e>
        loop();
    }

    assert(pid1 > 0);
  8005f0:	04a05863          	blez	a0,800640 <main+0x6e>

    if ((pid2 = fork()) == 0) {
  8005f4:	b59ff0ef          	jal	80014c <fork>
  8005f8:	00001797          	auipc	a5,0x1
  8005fc:	a0a7a423          	sw	a0,-1528(a5) # 801000 <pid2>
  800600:	c541                	beqz	a0,800688 <main+0xb6>
        work();
    }
    if (pid2 > 0) {
  800602:	06a05163          	blez	a0,800664 <main+0x92>
        cprintf("wait child 1.\n");
  800606:	00000517          	auipc	a0,0x0
  80060a:	24250513          	addi	a0,a0,578 # 800848 <main+0x276>
  80060e:	a93ff0ef          	jal	8000a0 <cprintf>
        waitpid(pid1, NULL);
  800612:	00001517          	auipc	a0,0x1
  800616:	9f252503          	lw	a0,-1550(a0) # 801004 <pid1>
  80061a:	4581                	li	a1,0
  80061c:	b33ff0ef          	jal	80014e <waitpid>
        panic("waitpid %d returns\n", pid1);
  800620:	00001697          	auipc	a3,0x1
  800624:	9e46a683          	lw	a3,-1564(a3) # 801004 <pid1>
  800628:	00000617          	auipc	a2,0x0
  80062c:	23060613          	addi	a2,a2,560 # 800858 <main+0x286>
  800630:	03400593          	li	a1,52
  800634:	00000517          	auipc	a0,0x0
  800638:	20450513          	addi	a0,a0,516 # 800838 <main+0x266>
  80063c:	9ebff0ef          	jal	800026 <__panic>
    assert(pid1 > 0);
  800640:	00000697          	auipc	a3,0x0
  800644:	1d068693          	addi	a3,a3,464 # 800810 <main+0x23e>
  800648:	00000617          	auipc	a2,0x0
  80064c:	1d860613          	addi	a2,a2,472 # 800820 <main+0x24e>
  800650:	02c00593          	li	a1,44
  800654:	00000517          	auipc	a0,0x0
  800658:	1e450513          	addi	a0,a0,484 # 800838 <main+0x266>
  80065c:	9cbff0ef          	jal	800026 <__panic>
        loop();
  800660:	f09ff0ef          	jal	800568 <loop>
    }
    else {
        kill(pid1);
  800664:	00001517          	auipc	a0,0x1
  800668:	9a052503          	lw	a0,-1632(a0) # 801004 <pid1>
  80066c:	ae7ff0ef          	jal	800152 <kill>
    }
    panic("FAIL: T.T\n");
  800670:	00000617          	auipc	a2,0x0
  800674:	20060613          	addi	a2,a2,512 # 800870 <main+0x29e>
  800678:	03900593          	li	a1,57
  80067c:	00000517          	auipc	a0,0x0
  800680:	1bc50513          	addi	a0,a0,444 # 800838 <main+0x266>
  800684:	9a3ff0ef          	jal	800026 <__panic>
        work();
  800688:	ef3ff0ef          	jal	80057a <work>
