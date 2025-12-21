
obj/__user_forktest.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	126000ef          	jal	800146 <umain>
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
  800038:	5ac50513          	addi	a0,a0,1452 # 8005e0 <main+0xa6>
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
  80005a:	5aa50513          	addi	a0,a0,1450 # 800600 <main+0xc6>
  80005e:	042000ef          	jal	8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0c4000ef          	jal	800128 <exit>

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
  80006e:	0b4000ef          	jal	800122 <sys_putc>
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
  800094:	124000ef          	jal	8001b8 <vprintfmt>
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
  8000c8:	0f0000ef          	jal	8001b8 <vprintfmt>
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

0000000000800122 <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  800122:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800124:	4579                	li	a0,30
  800126:	b77d                	j	8000d4 <syscall>

0000000000800128 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800128:	1141                	addi	sp,sp,-16
  80012a:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80012c:	fe5ff0ef          	jal	800110 <sys_exit>
    cprintf("BUG: exit failed.\n");
  800130:	00000517          	auipc	a0,0x0
  800134:	4d850513          	addi	a0,a0,1240 # 800608 <main+0xce>
  800138:	f69ff0ef          	jal	8000a0 <cprintf>
    while (1);
  80013c:	a001                	j	80013c <exit+0x14>

000000000080013e <fork>:
}

int
fork(void) {
    return sys_fork();
  80013e:	bfe1                	j	800116 <sys_fork>

0000000000800140 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  800140:	4581                	li	a1,0
  800142:	4501                	li	a0,0
  800144:	bfd9                	j	80011a <sys_wait>

0000000000800146 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800146:	1141                	addi	sp,sp,-16
  800148:	e406                	sd	ra,8(sp)
    int ret = main();
  80014a:	3f0000ef          	jal	80053a <main>
    exit(ret);
  80014e:	fdbff0ef          	jal	800128 <exit>

0000000000800152 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800152:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800154:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800158:	f022                	sd	s0,32(sp)
  80015a:	ec26                	sd	s1,24(sp)
  80015c:	e84a                	sd	s2,16(sp)
  80015e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800160:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800164:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  800166:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80016a:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  80016e:	84aa                	mv	s1,a0
  800170:	892e                	mv	s2,a1
    if (num >= base) {
  800172:	03067d63          	bgeu	a2,a6,8001ac <printnum+0x5a>
  800176:	e44e                	sd	s3,8(sp)
  800178:	89be                	mv	s3,a5
        while (-- width > 0)
  80017a:	4785                	li	a5,1
  80017c:	00e7d763          	bge	a5,a4,80018a <printnum+0x38>
            putch(padc, putdat);
  800180:	85ca                	mv	a1,s2
  800182:	854e                	mv	a0,s3
        while (-- width > 0)
  800184:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800186:	9482                	jalr	s1
        while (-- width > 0)
  800188:	fc65                	bnez	s0,800180 <printnum+0x2e>
  80018a:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80018c:	00000797          	auipc	a5,0x0
  800190:	49478793          	addi	a5,a5,1172 # 800620 <main+0xe6>
  800194:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800196:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800198:	0007c503          	lbu	a0,0(a5)
}
  80019c:	70a2                	ld	ra,40(sp)
  80019e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a0:	85ca                	mv	a1,s2
  8001a2:	87a6                	mv	a5,s1
}
  8001a4:	6942                	ld	s2,16(sp)
  8001a6:	64e2                	ld	s1,24(sp)
  8001a8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001aa:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ac:	03065633          	divu	a2,a2,a6
  8001b0:	8722                	mv	a4,s0
  8001b2:	fa1ff0ef          	jal	800152 <printnum>
  8001b6:	bfd9                	j	80018c <printnum+0x3a>

00000000008001b8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001b8:	7119                	addi	sp,sp,-128
  8001ba:	f4a6                	sd	s1,104(sp)
  8001bc:	f0ca                	sd	s2,96(sp)
  8001be:	ecce                	sd	s3,88(sp)
  8001c0:	e8d2                	sd	s4,80(sp)
  8001c2:	e4d6                	sd	s5,72(sp)
  8001c4:	e0da                	sd	s6,64(sp)
  8001c6:	f862                	sd	s8,48(sp)
  8001c8:	fc86                	sd	ra,120(sp)
  8001ca:	f8a2                	sd	s0,112(sp)
  8001cc:	fc5e                	sd	s7,56(sp)
  8001ce:	f466                	sd	s9,40(sp)
  8001d0:	f06a                	sd	s10,32(sp)
  8001d2:	ec6e                	sd	s11,24(sp)
  8001d4:	84aa                	mv	s1,a0
  8001d6:	8c32                	mv	s8,a2
  8001d8:	8a36                	mv	s4,a3
  8001da:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001dc:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001e0:	05500b13          	li	s6,85
  8001e4:	00000a97          	auipc	s5,0x0
  8001e8:	5b4a8a93          	addi	s5,s5,1460 # 800798 <main+0x25e>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ec:	000c4503          	lbu	a0,0(s8)
  8001f0:	001c0413          	addi	s0,s8,1
  8001f4:	01350a63          	beq	a0,s3,800208 <vprintfmt+0x50>
            if (ch == '\0') {
  8001f8:	cd0d                	beqz	a0,800232 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001fa:	85ca                	mv	a1,s2
  8001fc:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fe:	00044503          	lbu	a0,0(s0)
  800202:	0405                	addi	s0,s0,1
  800204:	ff351ae3          	bne	a0,s3,8001f8 <vprintfmt+0x40>
        width = precision = -1;
  800208:	5cfd                	li	s9,-1
  80020a:	8d66                	mv	s10,s9
        char padc = ' ';
  80020c:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800210:	4b81                	li	s7,0
  800212:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800214:	00044683          	lbu	a3,0(s0)
  800218:	00140c13          	addi	s8,s0,1
  80021c:	fdd6859b          	addiw	a1,a3,-35
  800220:	0ff5f593          	zext.b	a1,a1
  800224:	02bb6663          	bltu	s6,a1,800250 <vprintfmt+0x98>
  800228:	058a                	slli	a1,a1,0x2
  80022a:	95d6                	add	a1,a1,s5
  80022c:	4198                	lw	a4,0(a1)
  80022e:	9756                	add	a4,a4,s5
  800230:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800232:	70e6                	ld	ra,120(sp)
  800234:	7446                	ld	s0,112(sp)
  800236:	74a6                	ld	s1,104(sp)
  800238:	7906                	ld	s2,96(sp)
  80023a:	69e6                	ld	s3,88(sp)
  80023c:	6a46                	ld	s4,80(sp)
  80023e:	6aa6                	ld	s5,72(sp)
  800240:	6b06                	ld	s6,64(sp)
  800242:	7be2                	ld	s7,56(sp)
  800244:	7c42                	ld	s8,48(sp)
  800246:	7ca2                	ld	s9,40(sp)
  800248:	7d02                	ld	s10,32(sp)
  80024a:	6de2                	ld	s11,24(sp)
  80024c:	6109                	addi	sp,sp,128
  80024e:	8082                	ret
            putch('%', putdat);
  800250:	85ca                	mv	a1,s2
  800252:	02500513          	li	a0,37
  800256:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  800258:	fff44783          	lbu	a5,-1(s0)
  80025c:	02500713          	li	a4,37
  800260:	8c22                	mv	s8,s0
  800262:	f8e785e3          	beq	a5,a4,8001ec <vprintfmt+0x34>
  800266:	ffec4783          	lbu	a5,-2(s8)
  80026a:	1c7d                	addi	s8,s8,-1
  80026c:	fee79de3          	bne	a5,a4,800266 <vprintfmt+0xae>
  800270:	bfb5                	j	8001ec <vprintfmt+0x34>
                ch = *fmt;
  800272:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  800276:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  800278:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  80027c:	fd06071b          	addiw	a4,a2,-48
  800280:	24e56a63          	bltu	a0,a4,8004d4 <vprintfmt+0x31c>
                ch = *fmt;
  800284:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800286:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  800288:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  80028c:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800290:	0197073b          	addw	a4,a4,s9
  800294:	0017171b          	slliw	a4,a4,0x1
  800298:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  80029a:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  80029e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002a0:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002a4:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002a8:	feb570e3          	bgeu	a0,a1,800288 <vprintfmt+0xd0>
            if (width < 0)
  8002ac:	f60d54e3          	bgez	s10,800214 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002b0:	8d66                	mv	s10,s9
  8002b2:	5cfd                	li	s9,-1
  8002b4:	b785                	j	800214 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002b6:	8db6                	mv	s11,a3
  8002b8:	8462                	mv	s0,s8
  8002ba:	bfa9                	j	800214 <vprintfmt+0x5c>
  8002bc:	8462                	mv	s0,s8
            altflag = 1;
  8002be:	4b85                	li	s7,1
            goto reswitch;
  8002c0:	bf91                	j	800214 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002c2:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002c4:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002c8:	00f74463          	blt	a4,a5,8002d0 <vprintfmt+0x118>
    else if (lflag) {
  8002cc:	1a078763          	beqz	a5,80047a <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002d0:	000a3603          	ld	a2,0(s4)
  8002d4:	46c1                	li	a3,16
  8002d6:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002d8:	000d879b          	sext.w	a5,s11
  8002dc:	876a                	mv	a4,s10
  8002de:	85ca                	mv	a1,s2
  8002e0:	8526                	mv	a0,s1
  8002e2:	e71ff0ef          	jal	800152 <printnum>
            break;
  8002e6:	b719                	j	8001ec <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002e8:	000a2503          	lw	a0,0(s4)
  8002ec:	85ca                	mv	a1,s2
  8002ee:	0a21                	addi	s4,s4,8
  8002f0:	9482                	jalr	s1
            break;
  8002f2:	bded                	j	8001ec <vprintfmt+0x34>
    if (lflag >= 2) {
  8002f4:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002f6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002fa:	00f74463          	blt	a4,a5,800302 <vprintfmt+0x14a>
    else if (lflag) {
  8002fe:	16078963          	beqz	a5,800470 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800302:	000a3603          	ld	a2,0(s4)
  800306:	46a9                	li	a3,10
  800308:	8a2e                	mv	s4,a1
  80030a:	b7f9                	j	8002d8 <vprintfmt+0x120>
            putch('0', putdat);
  80030c:	85ca                	mv	a1,s2
  80030e:	03000513          	li	a0,48
  800312:	9482                	jalr	s1
            putch('x', putdat);
  800314:	85ca                	mv	a1,s2
  800316:	07800513          	li	a0,120
  80031a:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80031c:	000a3603          	ld	a2,0(s4)
            goto number;
  800320:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800322:	0a21                	addi	s4,s4,8
            goto number;
  800324:	bf55                	j	8002d8 <vprintfmt+0x120>
            putch(ch, putdat);
  800326:	85ca                	mv	a1,s2
  800328:	02500513          	li	a0,37
  80032c:	9482                	jalr	s1
            break;
  80032e:	bd7d                	j	8001ec <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800330:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800334:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  800336:	0a21                	addi	s4,s4,8
            goto process_precision;
  800338:	bf95                	j	8002ac <vprintfmt+0xf4>
    if (lflag >= 2) {
  80033a:	4705                	li	a4,1
            precision = va_arg(ap, int);
  80033c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800340:	00f74463          	blt	a4,a5,800348 <vprintfmt+0x190>
    else if (lflag) {
  800344:	12078163          	beqz	a5,800466 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  800348:	000a3603          	ld	a2,0(s4)
  80034c:	46a1                	li	a3,8
  80034e:	8a2e                	mv	s4,a1
  800350:	b761                	j	8002d8 <vprintfmt+0x120>
            if (width < 0)
  800352:	876a                	mv	a4,s10
  800354:	000d5363          	bgez	s10,80035a <vprintfmt+0x1a2>
  800358:	4701                	li	a4,0
  80035a:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  80035e:	8462                	mv	s0,s8
            goto reswitch;
  800360:	bd55                	j	800214 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800362:	000d841b          	sext.w	s0,s11
  800366:	fd340793          	addi	a5,s0,-45
  80036a:	00f037b3          	snez	a5,a5
  80036e:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800372:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  800376:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  800378:	008a0793          	addi	a5,s4,8
  80037c:	e43e                	sd	a5,8(sp)
  80037e:	100d8c63          	beqz	s11,800496 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800382:	12071363          	bnez	a4,8004a8 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800386:	000dc783          	lbu	a5,0(s11)
  80038a:	0007851b          	sext.w	a0,a5
  80038e:	c78d                	beqz	a5,8003b8 <vprintfmt+0x200>
  800390:	0d85                	addi	s11,s11,1
  800392:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800394:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800398:	000cc563          	bltz	s9,8003a2 <vprintfmt+0x1ea>
  80039c:	3cfd                	addiw	s9,s9,-1
  80039e:	008c8d63          	beq	s9,s0,8003b8 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003a2:	020b9663          	bnez	s7,8003ce <vprintfmt+0x216>
                    putch(ch, putdat);
  8003a6:	85ca                	mv	a1,s2
  8003a8:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003aa:	000dc783          	lbu	a5,0(s11)
  8003ae:	0d85                	addi	s11,s11,1
  8003b0:	3d7d                	addiw	s10,s10,-1
  8003b2:	0007851b          	sext.w	a0,a5
  8003b6:	f3ed                	bnez	a5,800398 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003b8:	01a05963          	blez	s10,8003ca <vprintfmt+0x212>
                putch(' ', putdat);
  8003bc:	85ca                	mv	a1,s2
  8003be:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003c2:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003c4:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003c6:	fe0d1be3          	bnez	s10,8003bc <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003ca:	6a22                	ld	s4,8(sp)
  8003cc:	b505                	j	8001ec <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003ce:	3781                	addiw	a5,a5,-32
  8003d0:	fcfa7be3          	bgeu	s4,a5,8003a6 <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003d4:	03f00513          	li	a0,63
  8003d8:	85ca                	mv	a1,s2
  8003da:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003dc:	000dc783          	lbu	a5,0(s11)
  8003e0:	0d85                	addi	s11,s11,1
  8003e2:	3d7d                	addiw	s10,s10,-1
  8003e4:	0007851b          	sext.w	a0,a5
  8003e8:	dbe1                	beqz	a5,8003b8 <vprintfmt+0x200>
  8003ea:	fa0cd9e3          	bgez	s9,80039c <vprintfmt+0x1e4>
  8003ee:	b7c5                	j	8003ce <vprintfmt+0x216>
            if (err < 0) {
  8003f0:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f4:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003f6:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003f8:	41f7d71b          	sraiw	a4,a5,0x1f
  8003fc:	8fb9                	xor	a5,a5,a4
  8003fe:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800402:	02d64563          	blt	a2,a3,80042c <vprintfmt+0x274>
  800406:	00000797          	auipc	a5,0x0
  80040a:	4ea78793          	addi	a5,a5,1258 # 8008f0 <error_string>
  80040e:	00369713          	slli	a4,a3,0x3
  800412:	97ba                	add	a5,a5,a4
  800414:	639c                	ld	a5,0(a5)
  800416:	cb99                	beqz	a5,80042c <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  800418:	86be                	mv	a3,a5
  80041a:	00000617          	auipc	a2,0x0
  80041e:	23660613          	addi	a2,a2,566 # 800650 <main+0x116>
  800422:	85ca                	mv	a1,s2
  800424:	8526                	mv	a0,s1
  800426:	0d8000ef          	jal	8004fe <printfmt>
  80042a:	b3c9                	j	8001ec <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  80042c:	00000617          	auipc	a2,0x0
  800430:	21460613          	addi	a2,a2,532 # 800640 <main+0x106>
  800434:	85ca                	mv	a1,s2
  800436:	8526                	mv	a0,s1
  800438:	0c6000ef          	jal	8004fe <printfmt>
  80043c:	bb45                	j	8001ec <vprintfmt+0x34>
    if (lflag >= 2) {
  80043e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800440:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800444:	00f74363          	blt	a4,a5,80044a <vprintfmt+0x292>
    else if (lflag) {
  800448:	cf81                	beqz	a5,800460 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  80044a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  80044e:	02044b63          	bltz	s0,800484 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800452:	8622                	mv	a2,s0
  800454:	8a5e                	mv	s4,s7
  800456:	46a9                	li	a3,10
  800458:	b541                	j	8002d8 <vprintfmt+0x120>
            lflag ++;
  80045a:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  80045c:	8462                	mv	s0,s8
            goto reswitch;
  80045e:	bb5d                	j	800214 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800460:	000a2403          	lw	s0,0(s4)
  800464:	b7ed                	j	80044e <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  800466:	000a6603          	lwu	a2,0(s4)
  80046a:	46a1                	li	a3,8
  80046c:	8a2e                	mv	s4,a1
  80046e:	b5ad                	j	8002d8 <vprintfmt+0x120>
  800470:	000a6603          	lwu	a2,0(s4)
  800474:	46a9                	li	a3,10
  800476:	8a2e                	mv	s4,a1
  800478:	b585                	j	8002d8 <vprintfmt+0x120>
  80047a:	000a6603          	lwu	a2,0(s4)
  80047e:	46c1                	li	a3,16
  800480:	8a2e                	mv	s4,a1
  800482:	bd99                	j	8002d8 <vprintfmt+0x120>
                putch('-', putdat);
  800484:	85ca                	mv	a1,s2
  800486:	02d00513          	li	a0,45
  80048a:	9482                	jalr	s1
                num = -(long long)num;
  80048c:	40800633          	neg	a2,s0
  800490:	8a5e                	mv	s4,s7
  800492:	46a9                	li	a3,10
  800494:	b591                	j	8002d8 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  800496:	e329                	bnez	a4,8004d8 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800498:	02800793          	li	a5,40
  80049c:	853e                	mv	a0,a5
  80049e:	00000d97          	auipc	s11,0x0
  8004a2:	19bd8d93          	addi	s11,s11,411 # 800639 <main+0xff>
  8004a6:	b5f5                	j	800392 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004a8:	85e6                	mv	a1,s9
  8004aa:	856e                	mv	a0,s11
  8004ac:	072000ef          	jal	80051e <strnlen>
  8004b0:	40ad0d3b          	subw	s10,s10,a0
  8004b4:	01a05863          	blez	s10,8004c4 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004b8:	85ca                	mv	a1,s2
  8004ba:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004bc:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004be:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c0:	fe0d1ce3          	bnez	s10,8004b8 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c4:	000dc783          	lbu	a5,0(s11)
  8004c8:	0007851b          	sext.w	a0,a5
  8004cc:	ec0792e3          	bnez	a5,800390 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004d0:	6a22                	ld	s4,8(sp)
  8004d2:	bb29                	j	8001ec <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004d4:	8462                	mv	s0,s8
  8004d6:	bbd9                	j	8002ac <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004d8:	85e6                	mv	a1,s9
  8004da:	00000517          	auipc	a0,0x0
  8004de:	15e50513          	addi	a0,a0,350 # 800638 <main+0xfe>
  8004e2:	03c000ef          	jal	80051e <strnlen>
  8004e6:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ea:	02800793          	li	a5,40
                p = "(null)";
  8004ee:	00000d97          	auipc	s11,0x0
  8004f2:	14ad8d93          	addi	s11,s11,330 # 800638 <main+0xfe>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004f6:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004f8:	fda040e3          	bgtz	s10,8004b8 <vprintfmt+0x300>
  8004fc:	bd51                	j	800390 <vprintfmt+0x1d8>

00000000008004fe <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004fe:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800500:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800504:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800506:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800508:	ec06                	sd	ra,24(sp)
  80050a:	f83a                	sd	a4,48(sp)
  80050c:	fc3e                	sd	a5,56(sp)
  80050e:	e0c2                	sd	a6,64(sp)
  800510:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800512:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800514:	ca5ff0ef          	jal	8001b8 <vprintfmt>
}
  800518:	60e2                	ld	ra,24(sp)
  80051a:	6161                	addi	sp,sp,80
  80051c:	8082                	ret

000000000080051e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  80051e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800520:	e589                	bnez	a1,80052a <strnlen+0xc>
  800522:	a811                	j	800536 <strnlen+0x18>
        cnt ++;
  800524:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800526:	00f58863          	beq	a1,a5,800536 <strnlen+0x18>
  80052a:	00f50733          	add	a4,a0,a5
  80052e:	00074703          	lbu	a4,0(a4)
  800532:	fb6d                	bnez	a4,800524 <strnlen+0x6>
  800534:	85be                	mv	a1,a5
    }
    return cnt;
}
  800536:	852e                	mv	a0,a1
  800538:	8082                	ret

000000000080053a <main>:
#include <stdio.h>

const int max_child = 32;

int
main(void) {
  80053a:	1101                	addi	sp,sp,-32
  80053c:	e822                	sd	s0,16(sp)
  80053e:	e426                	sd	s1,8(sp)
  800540:	ec06                	sd	ra,24(sp)
    int n, pid;
    for (n = 0; n < max_child; n ++) {
  800542:	4401                	li	s0,0
  800544:	02000493          	li	s1,32
        if ((pid = fork()) == 0) {
  800548:	bf7ff0ef          	jal	80013e <fork>
  80054c:	c915                	beqz	a0,800580 <main+0x46>
            cprintf("I am child %d\n", n);
            exit(0);
        }
        assert(pid > 0);
  80054e:	04a05e63          	blez	a0,8005aa <main+0x70>
    for (n = 0; n < max_child; n ++) {
  800552:	2405                	addiw	s0,s0,1
  800554:	fe941ae3          	bne	s0,s1,800548 <main+0xe>
    if (n > max_child) {
        panic("fork claimed to work %d times!\n", n);
    }

    for (; n > 0; n --) {
        if (wait() != 0) {
  800558:	be9ff0ef          	jal	800140 <wait>
  80055c:	ed05                	bnez	a0,800594 <main+0x5a>
    for (; n > 0; n --) {
  80055e:	347d                	addiw	s0,s0,-1
  800560:	fc65                	bnez	s0,800558 <main+0x1e>
            panic("wait stopped early\n");
        }
    }

    if (wait() == 0) {
  800562:	bdfff0ef          	jal	800140 <wait>
  800566:	c12d                	beqz	a0,8005c8 <main+0x8e>
        panic("wait got too many\n");
    }

    cprintf("forktest pass.\n");
  800568:	00000517          	auipc	a0,0x0
  80056c:	22050513          	addi	a0,a0,544 # 800788 <main+0x24e>
  800570:	b31ff0ef          	jal	8000a0 <cprintf>
    return 0;
}
  800574:	60e2                	ld	ra,24(sp)
  800576:	6442                	ld	s0,16(sp)
  800578:	64a2                	ld	s1,8(sp)
  80057a:	4501                	li	a0,0
  80057c:	6105                	addi	sp,sp,32
  80057e:	8082                	ret
            cprintf("I am child %d\n", n);
  800580:	85a2                	mv	a1,s0
  800582:	00000517          	auipc	a0,0x0
  800586:	19650513          	addi	a0,a0,406 # 800718 <main+0x1de>
  80058a:	b17ff0ef          	jal	8000a0 <cprintf>
            exit(0);
  80058e:	4501                	li	a0,0
  800590:	b99ff0ef          	jal	800128 <exit>
            panic("wait stopped early\n");
  800594:	00000617          	auipc	a2,0x0
  800598:	1c460613          	addi	a2,a2,452 # 800758 <main+0x21e>
  80059c:	45dd                	li	a1,23
  80059e:	00000517          	auipc	a0,0x0
  8005a2:	1aa50513          	addi	a0,a0,426 # 800748 <main+0x20e>
  8005a6:	a81ff0ef          	jal	800026 <__panic>
        assert(pid > 0);
  8005aa:	00000697          	auipc	a3,0x0
  8005ae:	17e68693          	addi	a3,a3,382 # 800728 <main+0x1ee>
  8005b2:	00000617          	auipc	a2,0x0
  8005b6:	17e60613          	addi	a2,a2,382 # 800730 <main+0x1f6>
  8005ba:	45b9                	li	a1,14
  8005bc:	00000517          	auipc	a0,0x0
  8005c0:	18c50513          	addi	a0,a0,396 # 800748 <main+0x20e>
  8005c4:	a63ff0ef          	jal	800026 <__panic>
        panic("wait got too many\n");
  8005c8:	00000617          	auipc	a2,0x0
  8005cc:	1a860613          	addi	a2,a2,424 # 800770 <main+0x236>
  8005d0:	45f1                	li	a1,28
  8005d2:	00000517          	auipc	a0,0x0
  8005d6:	17650513          	addi	a0,a0,374 # 800748 <main+0x20e>
  8005da:	a4dff0ef          	jal	800026 <__panic>
