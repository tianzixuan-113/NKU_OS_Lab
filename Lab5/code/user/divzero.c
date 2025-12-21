#include <stdio.h>
#include <ulib.h>

int zero;

// 自定义除法函数
int safe_div(int a, int b) {
    if (b == 0) {
        return -1;
    }
    return a / b;
}

int
main(void) {
    cprintf("value is %d.\n", safe_div(1, zero));
    
    if (safe_div(1, zero) == -1) {
        return 0;  // 成功退出
    } else {
        panic("FAIL: T.T\n");
    }
}