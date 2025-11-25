#ifndef __KERN_MM_MMU_H__
#define __KERN_MM_MMU_H__

#ifndef __ASSEMBLER__
#include <defs.h>
#endif /* !__ASSEMBLER__ */

// A linear address 'la' has a three-part structure as follows:
//
// +--------10------+-------10-------+---------12----------+
// | Page Directory |   Page Table   | Offset within Page  |
// |      Index     |     Index      |                     |
// +----------------+----------------+---------------------+
//  \--- PDX(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \----------- PPN(la) -----------/
//
// The PDX, PTX, PGOFF, and PPN macros decompose linear addresses as shown.
// To construct a linear address la from PDX(la), PTX(la), and PGOFF(la),
// use PGADDR(PDX(la), PTX(la), PGOFF(la)).

// RISC-V uses 32-bit virtual address to access 34-bit physical address!
// Sv32 page table entry:
// +---------12----------+--------10-------+---2----+-------8-------+
// |       PPN[1]        |      PPN[0]     |Reserved|D|A|G|U|X|W|R|V|
// +---------12----------+-----------------+--------+---------------+

// 页目录索引宏（两级页表结构）
#define PDX1(la) ((((uintptr_t)(la)) >> PDX1SHIFT) & 0x1FF)  // 一级页目录索引（位30-21）
#define PDX0(la) ((((uintptr_t)(la)) >> PDX0SHIFT) & 0x1FF)  // 二级页目录索引（位21-12）

// 页表索引宏
#define PTX(la) ((((uintptr_t)(la)) >> PTXSHIFT) & 0x1FF)    // 页表索引（位21-12）

// 地址的页号字段
#define PPN(la) (((uintptr_t)(la)) >> PTXSHIFT)              // 获取页号

// 页内偏移量
#define PGOFF(la) (((uintptr_t)(la)) & 0xFFF)                // 获取12位页内偏移

// 从索引和偏移量构造线性地址
#define PGADDR(d1, d0, t, o) ((uintptr_t)((d1) << PDX1SHIFT |(d0) << PDX0SHIFT | (t) << PTXSHIFT | (o)))

// 从页表条目或页目录条目中提取地址
#define PTE_ADDR(pte)   (((uintptr_t)(pte) & ~0x3FF) << (PTXSHIFT - PTE_PPN_SHIFT))  // 提取PTE中的物理页号
#define PDE_ADDR(pde)   PTE_ADDR(pde)  // PDE地址提取与PTE相同

/* 页目录和页表常量 */
#define NPDEENTRY       512                    // 每个页目录的页目录条目数
#define NPTEENTRY       512                    // 每个页表的页表条目数

#define PGSIZE          4096                    // 每页映射的字节数
#define PGSHIFT         12                      // log2(PGSIZE)
#define PTSIZE          (PGSIZE * NPTEENTRY)    // 每个页目录条目映射的字节数
#define PTSHIFT         21                      // log2(PTSIZE)

#define PTXSHIFT        12                      // 线性地址中PTX的偏移量
#define PDX0SHIFT       21                      // 线性地址中PDX的偏移量
#define PDX1SHIFT		30                      // 一级页目录索引偏移量
#define PTE_PPN_SHIFT   10                      // 物理地址中PPN的偏移量

// 页表条目(PTE)字段标志位
#define PTE_V     0x001 // Valid - 条目有效
#define PTE_R     0x002 // Read - 可读权限
#define PTE_W     0x004 // Write - 可写权限
#define PTE_X     0x008 // Execute - 可执行权限
#define PTE_U     0x010 // User - 用户模式可访问
#define PTE_G     0x020 // Global - 全局映射（TLB不失效）
#define PTE_A     0x040 // Accessed - 已被访问
#define PTE_D     0x080 // Dirty - 已被写入
#define PTE_SOFT  0x300 // Reserved for Software - 软件保留位

// 常用的权限组合
#define PAGE_TABLE_DIR (PTE_V)                    // 页目录有效
#define READ_ONLY (PTE_R | PTE_V)                 // 只读权限
#define READ_WRITE (PTE_R | PTE_W | PTE_V)        // 读写权限
#define EXEC_ONLY (PTE_X | PTE_V)                 // 只执行权限
#define READ_EXEC (PTE_R | PTE_X | PTE_V)         // 读执行权限
#define READ_WRITE_EXEC (PTE_R | PTE_W | PTE_X | PTE_V)  // 读写下执行权限

#define PTE_USER (PTE_R | PTE_W | PTE_X | PTE_U | PTE_V)  // 用户权限

#endif /* !__KERN_MM_MMU_H__ */