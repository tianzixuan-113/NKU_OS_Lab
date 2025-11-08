#include <clock.h>
#include <defs.h>
#include <sbi.h>
#include <stdio.h>
#include <riscv.h>

volatile size_t ticks;  // 系统时钟滴答计数器，volatile防止编译器优化

/**
 * get_cycles - 读取CPU的时间计数器
 * 返回值: 从系统启动开始经过的时钟周期数
 * 
 * 根据RISC-V架构的字长使用不同的读取方式：
 * - 64位系统：直接使用rdtime指令
 * - 32位系统：需要分两次读取并处理可能的重叠问题
 */
static inline uint64_t get_cycles(void) {
#if __riscv_xlen == 64
    // 64位系统：单条指令读取完整64位时间值
    uint64_t n;
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    return n;
#else
    // 32位系统：需要分别读取高32位和低32位，并处理读取过程中的进位
    uint32_t lo, hi, tmp;
    __asm__ __volatile__(
        "1:\n"                  // 标签，用于循环
        "rdtimeh %0\n"          // 读取时间计数器高32位
        "rdtime %1\n"           // 读取时间计数器低32位  
        "rdtimeh %2\n"          // 再次读取时间计数器高32位（用于检测进位）
        "bne %0, %2, 1b"        // 如果两次读取的高位不同，说明发生了进位，重新读取
        : "=&r"(hi), "=&r"(lo), "=&r"(tmp));  // 输出操作数
    return ((uint64_t)hi << 32) | lo;  // 组合成64位值返回
#endif
}

// 定时器中断间隔的时钟周期数（硬编码值）
// 这个值决定了定时器中断的频率
static uint64_t timebase = 100000;

/**
 * clock_init - 初始化时钟系统
 * 
 * 功能：
 * 1. 启用定时器中断
 * 2. 设置定时器中断间隔
 * 3. 初始化时钟计数器
 * 4. 设置第一个定时器中断事件
 * 
 * 注意：当前使用硬编码的timebase值，实际应根据不同模拟器调整：
 * - Spike模拟器(2MHz)：应除以500
 * - QEMU模拟器(10MHz)：应除以100
 */
void clock_init(void) {
    // 在sie(Supervisor Interrupt Enable)寄存器中启用定时器中断
    // MIP_STIP: Supervisor Timer Interrupt Pending 位
    set_csr(sie, MIP_STIP);
    
    // 设置定时器中断间隔（当前为硬编码，实际应该根据硬件动态计算）
    // timebase = sbi_timebase() / 500;  // Spike模拟器
    // timebase = sbi_timebase() / 100;  // QEMU模拟器
    
    // 设置第一个定时器中断事件
    clock_set_next_event();

    // 初始化系统时钟滴答计数器为0
    ticks = 0;

    // 输出初始化完成信息
    cprintf("++ setup timer interrupts\n");
}

/**
 * clock_set_next_event - 设置下一个定时器中断事件
 * 
 * 通过SBI调用设置一个未来的时间点，当CPU时间计数器达到该值时触发定时器中断
 * 计算方式：当前时间 + 定时器间隔(timebase)
 */
void clock_set_next_event(void) { 
    sbi_set_timer(get_cycles() + timebase); 
}