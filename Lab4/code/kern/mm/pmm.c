#include <default_pmm.h>   // 默认物理内存管理器
#include <best_fit_pmm.h>  // 最佳适应物理内存管理器
#include <defs.h>          // 基本类型定义
#include <error.h>         // 错误码定义
#include <kmalloc.h>       // 内核内存分配
#include <memlayout.h>     // 内存布局定义
#include <mmu.h>           // 内存管理单元
#include <pmm.h>           // 物理内存管理
#include <sbi.h>           // RISC-V SBI调用
#include <stdio.h>         // 标准输入输出
#include <string.h>        // 字符串操作
#include <sync.h>          // 同步原语
#include <vmm.h>           // 虚拟内存管理
#include <riscv.h>         // RISC-V寄存器定义
#include <dtb.h>           // 设备树

// 全局变量定义

// 物理页数组的虚拟地址
struct Page *pages;
// 物理内存总量（以页为单位）
size_t npage = 0;
// 内核镜像映射在VA=KERNBASE和PA=info.base
uint_t va_pa_offset;
// RISC-V中内存从0x80000000开始
const size_t nbase = DRAM_BASE / PGSIZE;

// 启动时页目录的虚拟地址
pde_t *boot_pgdir_va = NULL;
// 启动时页目录的物理地址
uintptr_t boot_pgdir_pa;

// 物理内存管理器
const struct pmm_manager *pmm_manager;

// 函数声明
static void check_alloc_page(void);
static void check_pgdir(void);
static void check_boot_pgdir(void);

// init_pmm_manager - 初始化pmm_manager实例
static void init_pmm_manager(void)
{
    //pmm_manager = &default_pmm_manager;  // 使用默认内存管理器
    pmm_manager = &best_fit_pmm_manager;    // 使用最佳适应内存管理器
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();  // 初始化内存管理器
}

// init_memmap - 调用pmm->init_memmap为空闲内存构建Page结构
static void init_memmap(struct Page *base, size_t n)
{
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - 调用pmm->alloc_pages分配连续的n*PAGESIZE内存
struct Page *alloc_pages(size_t n)
{
    struct Page *page = NULL;
    bool intr_flag;
    // 在临界区内分配页面（禁用中断）
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
    }
    local_intr_restore(intr_flag);
    return page;
}

// free_pages - 调用pmm->free_pages释放连续的n*PAGESIZE内存
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    // 在临界区内释放页面（禁用中断）
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
    }
    local_intr_restore(intr_flag);
}

// nr_free_pages - 调用pmm->nr_free_pages获取当前空闲内存大小
size_t nr_free_pages(void)
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
    }
    local_intr_restore(intr_flag);
    return ret;
}

/* pmm_init - 初始化物理内存管理 */
static void page_init(void)
{
    extern char kern_entry[];  // 内核入口点

    // 设置虚拟地址到物理地址的偏移量
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;

    // 从设备树获取内存信息
    uint64_t mem_begin = get_memory_base();
    uint64_t mem_size  = get_memory_size();
    if (mem_size == 0) {
        panic("DTB memory info not available");  // 设备树内存信息不可用
    }
    uint64_t mem_end   = mem_begin + mem_size;

    // 打印物理内存映射信息
    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
            mem_end - 1);

    uint64_t maxpa = mem_end;

    // 限制最大物理地址不超过内核顶部
    if (maxpa > KERNTOP)
    {
        maxpa = KERNTOP;
    }

    extern char end[];  // 内核结束地址

    // 计算总页数
    npage = maxpa / PGSIZE;
    // BBL将初始页表放在内核之后的第一个可用页面
    // 所以通过向end添加额外偏移来避开它
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    // 标记所有页面为已保留
    for (size_t i = 0; i < npage - nbase; i++)
    {
        SetPageReserved(pages + i);
    }

    // 计算空闲内存起始地址
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));

    // 对齐内存边界
    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    
    // 初始化空闲内存区域
    if (freemem < mem_end)
    {
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
    cprintf("vapaofset is %llu\n", va_pa_offset);
}

// enable_paging - 启用分页机制
static void enable_paging(void)
{
    // 设置satp寄存器：启用分页并设置页表物理地址
    write_csr(satp, 0x8000000000000000 | (boot_pgdir_pa >> RISCV_PGSHIFT));
}

// boot_map_segment - 设置和启用分页机制
// 参数:
//  la:   需要映射的内存的线性地址（在x86段映射之后）
//  size: 内存大小
//  pa:   该内存的物理地址
//  perm: 该内存的权限
static void boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size,
                             uintptr_t pa, uint32_t perm)
{
    // 断言线性地址和物理地址的页内偏移相同
    assert(PGOFF(la) == PGOFF(pa));
    // 计算需要的页面数
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    // 对齐地址到页面边界
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    
    // 逐页建立映射
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE)
    {
        // 获取页表条目指针，如果不存在则创建
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        // 创建页表条目
        *ptep = pte_create(pa >> PGSHIFT, PTE_V | perm);
    }
}

// boot_alloc_page - 使用pmm->alloc_pages(1)分配一个页面
// 返回值: 该分配页面的内核虚拟地址
// 注意: 此函数用于获取PDT(页目录表)和PT(页表)的内存
static void *boot_alloc_page(void)
{
    struct Page *p = alloc_page();
    if (p == NULL)
    {
        panic("boot_alloc_page failed.\n");
    }
    return page2kva(p);
}

// pmm_init - 设置pmm来管理物理内存，构建PDT和PT来设置分页机制
//         - 检查pmm和分页机制的正确性，打印PDT和PT
void pmm_init(void)
{
    // 我们需要分配/释放物理内存（粒度是4KB或其他大小）。
    // 所以在pmm.h中定义了物理内存管理器的框架(struct pmm_manager)
    // 首先我们应该基于该框架初始化物理内存管理器(pmm)。
    // 然后pmm可以分配/释放物理内存。
    // 现在first_fit/best_fit/worst_fit/buddy_system pmm都可用。
    init_pmm_manager();

    // 检测物理内存空间，保留已使用的内存，
    // 然后使用pmm->init_memmap创建空闲页面列表
    page_init();

    // 使用pmm->check验证pmm中分配/释放函数的正确性
    check_alloc_page();
    
    // 创建boot_pgdir，初始页目录(页目录表，PDT)
    extern char boot_page_table_sv39[];
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
    boot_pgdir_pa = PADDR(boot_pgdir_va);

    check_pgdir();

    // 静态断言检查内核地址对齐
    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

        // 现在基本的虚拟内存映射(参见memlayout.h)已建立。
    // 检查基本虚拟内存映射的正确性。
    check_boot_pgdir();

    // 初始化内核内存分配器
    kmalloc_init();
}

// get_pte - 获取pte并返回该pte的内核虚拟地址
//        - 如果包含该pte的PT不存在，则为PT分配一个页面
// 参数:
//  pgdir:  PDT的内核虚拟基地址
//  la:     需要映射的线性地址
//  create: 逻辑值，决定是否为PT分配页面
// 返回值: 该pte的内核虚拟地址
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    // 获取一级页目录条目
    pde_t *pdep1 = &pgdir[PDX1(la)];
    // 如果一级页目录条目无效
    if (!(*pdep1 & PTE_V))
    {
        struct Page *page;
        // 如果不创建或分配页面失败，返回NULL
        if (!create || (page = alloc_page()) == NULL)
        {
            return NULL;
        }
        // 设置页面引用计数为1
        set_page_ref(page, 1);
        // 获取页面的物理地址
        uintptr_t pa = page2pa(page);
        // 清空页面内容
        memset(KADDR(pa), 0, PGSIZE);
        // 创建一级页目录条目
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    
    // 获取二级页目录条目
    pde_t *pdep0 = &((pte_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
    // 如果二级页目录条目无效
    if (!(*pdep0 & PTE_V))
    {
        struct Page *page;
        // 如果不创建或分配页面失败，返回NULL
        if (!create || (page = alloc_page()) == NULL)
        {
            return NULL;
        }
        // 设置页面引用计数为1
        set_page_ref(page, 1);
        // 获取页面的物理地址
        uintptr_t pa = page2pa(page);
        // 清空页面内容
        memset(KADDR(pa), 0, PGSIZE);
        // 创建二级页目录条目
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    
    // 返回页表条目指针
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}

// get_page - 使用PDT pgdir获取线性地址la相关的Page结构
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
    // 获取页表条目
    pte_t *ptep = get_pte(pgdir, la, 0);
    // 如果需要存储pte指针
    if (ptep_store != NULL)
    {
        *ptep_store = ptep;
    }
    // 如果pte存在且有效，返回对应的页面
    if (ptep != NULL && *ptep & PTE_V)
    {
        return pte2page(*ptep);
    }
    return NULL;
}

// page_remove_pte - 释放与线性地址la相关的Page结构
//                - 并清理(使无效)与线性地址la相关的pte
// 注意: PT被更改，因此需要使TLB失效
static inline void page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep)
{
    // (1) 检查该页表条目是否有效
    if (*ptep & PTE_V)
    { 
        // (2) 找到pte对应的页面
        struct Page *page = pte2page(*ptep);
        // (3) 减少页面引用计数
        page_ref_dec(page);
        // (4) 当页面引用计数达到0时释放该页面
        if (page_ref(page) == 0)
        { 
            free_page(page);
        }
        // (5) 清除二级页表条目
        *ptep = 0;
        // (6) 刷新TLB
        tlb_invalidate(pgdir, la);
    }
}

// page_remove - 释放与线性地址la相关且具有已验证pte的Page
void page_remove(pde_t *pgdir, uintptr_t la)
{
    // 获取页表条目
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep != NULL)
    {
        // 移除页面
        page_remove_pte(pgdir, la, ptep);
    }
}

// page_insert - 建立Page的物理地址与线性地址la的映射
// 参数:
//  pgdir: PDT的内核虚拟基地址
//  page:  需要映射的Page
//  la:    需要映射的线性地址
//  perm:  在相关pte中设置的该Page的权限
// 返回值: 总是0
// 注意: PT被更改，因此需要使TLB失效
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm)
{
    // 获取页表条目，如果不存在则创建
    pte_t *ptep = get_pte(pgdir, la, 1);
    if (ptep == NULL)
    {
        return -E_NO_MEM;  // 内存不足
    }
    
    // 增加页面引用计数
    page_ref_inc(page);
    
    // 如果pte已有效
    if (*ptep & PTE_V)
    {
        struct Page *p = pte2page(*ptep);
        // 如果映射的是同一个页面
        if (p == page)
        {
            // 恢复引用计数
            page_ref_dec(page);
        }
        else
        {
            // 移除旧的映射
            page_remove_pte(pgdir, la, ptep);
        }
    }
    
    // 创建新的页表条目
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
    // 使TLB失效
    tlb_invalidate(pgdir, la);
    return 0;
}

// tlb_invalidate - 使TLB条目失效，但仅当正在编辑的页表是处理器当前使用的页表时
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    // flush_tlb();  // 刷新整个TLB，有更好的方法吗？
    // 使用sfence.vma指令刷新指定地址的TLB条目
    asm volatile("sfence.vma %0" : : "r"(la));
}

// check_alloc_page - 检查页面分配功能
static void check_alloc_page(void)
{
    pmm_manager->check();  // 调用内存管理器的检查函数
    cprintf("check_alloc_page() succeeded!\n");
}

// check_pgdir - 检查页目录功能
static void check_pgdir(void)
{
    size_t nr_free_store;

    // 保存当前空闲页面数
    nr_free_store = nr_free_pages();

    // 各种断言检查
    assert(npage <= KERNTOP / PGSIZE);
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);

    // 测试页面插入和获取
    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert(page_ref(p1) == 1);

    // 测试页表遍历
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);

    // 测试用户权限
    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
    assert(*ptep & PTE_U);
    assert(*ptep & PTE_W);
    assert(boot_pgdir_va[0] & PTE_U);
    assert(page_ref(p2) == 1);

    // 测试页面替换
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
    assert(page_ref(p1) == 2);
    assert(page_ref(p2) == 0);
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
    assert(pte2page(*ptep) == p1);
    assert((*ptep & PTE_U) == 0);

    // 测试页面移除
    page_remove(boot_pgdir_va, 0x0);
    assert(page_ref(p1) == 1);
    assert(page_ref(p2) == 0);

    page_remove(boot_pgdir_va, PGSIZE);
    assert(page_ref(p1) == 0);
    assert(page_ref(p2) == 0);

    // 检查页目录引用计数
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);

    // 清理测试资源
    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
    flush_tlb();  // 刷新TLB

    // 验证空闲页面数恢复
    assert(nr_free_store == nr_free_pages());

    cprintf("check_pgdir() succeeded!\n");
}

// check_boot_pgdir - 检查启动页目录
static void check_boot_pgdir(void)
{
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    // 保存当前空闲页面数
    nr_free_store = nr_free_pages();

    // 检查内核地址空间的映射
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    // 检查页目录条目
    assert(boot_pgdir_va[0] == 0);

    // 测试页面共享
    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 1);
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
    assert(page_ref(p) == 2);

    // 测试内存访问
    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);

    // 测试字符串操作
    *(char *)(page2kva(p) + 0x100) = '\0';
    assert(strlen((const char *)0x100) == 0);

    // 清理资源
    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
    flush_tlb();

    // 验证空闲页面数恢复
    assert(nr_free_store == nr_free_pages());

    cprintf("check_boot_pgdir() succeeded!\n");
}

// perm2str - 使用字符串'u,r,w,-'表示权限
static const char *perm2str(int perm)
{
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';  // 用户权限
    str[1] = 'r';                         // 读权限（总是显示）
    str[2] = (perm & PTE_W) ? 'w' : '-';  // 写权限
    str[3] = '\0';
    return str;
}

// get_pgtable_items - 在PDT或PT的[left, right]范围内，查找连续的线性地址空间
//                  - (left_store*X_SIZE~right_store*X_SIZE) 对于PDT或PT
//                  - X_SIZE=PTSIZE=4M, 如果是PDT; X_SIZE=PGSIZE=4K, 如果是PT
// 参数:
//  left:        未使用???
//  right:       表范围的高端
//  start:       表范围的低端
//  table:       表的起始地址
//  left_store:  表下一个范围高端的指针
//  right_store: 表下一个范围低端的指针
//  返回值: 0 - 不是有效的条目范围, perm - 具有perm权限的有效条目范围
static int get_pgtable_items(size_t left, size_t right, size_t start,
                             uintptr_t *table, size_t *left_store,
                             size_t *right_store)
{
    // 检查起始位置是否在有效范围内
    if (start >= right)
    {
        return 0;
    }
    
    // 跳过无效的条目
    while (start < right && !(table[start] & PTE_V))
    {
        start++;
    }
    
    // 如果找到有效条目
    if (start < right)
    {
        // 存储左边界
        if (left_store != NULL)
        {
            *left_store = start;
        }
        
        // 获取权限位
        int perm = (table[start++] & PTE_USER);
        
        // 查找具有相同权限的连续条目
        while (start < right && (table[start] & PTE_USER) == perm)
        {
            start++;
        }
        
        // 存储右边界
        if (right_store != NULL)
        {
            *right_store = start;
        }
        
        return perm;  // 返回权限
    }
    return 0;  // 未找到有效条目
}