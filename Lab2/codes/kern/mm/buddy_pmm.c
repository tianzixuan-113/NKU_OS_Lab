#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

/* Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 
   每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...
*/

// 最大阶数，支持最大块大小为2^MAX_ORDER页
#define MAX_ORDER 10

static free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

// 每个阶的空闲链表
static list_entry_t buddy_free_lists[MAX_ORDER + 1];
static unsigned int buddy_nr_free[MAX_ORDER + 1];

// 计算2的n次幂
static inline unsigned int power_of_two(unsigned int n) {
    return 1U << n;
}

// 计算以2为底的对数（向上取整）
static inline unsigned int log2_ceil(unsigned int x) {
    unsigned int order = 0;
    while ((1U << order) < x) {
        order++;
    }
    return order;
}

// 获取页的阶数
static inline unsigned int get_page_order(struct Page *page) {
    return page->property;
}

// 设置页的阶数
static inline void set_page_order(struct Page *page, unsigned int order) {
    page->property = order;
}

// 检查页是否已分配
static inline int page_is_allocated(struct Page *page) {
    return !PageProperty(page);
}

// 设置页为已分配
static inline void set_page_allocated(struct Page *page) {
    ClearPageProperty(page);
}

// 设置页为空闲
static inline void set_page_freed(struct Page *page) {
    SetPageProperty(page);
}

/// 计算伙伴块的索引
static inline unsigned long get_buddy_index(struct Page *page, unsigned int order) {
    unsigned long page_index = (page - pages);  // 修改 base 为 pages
    return page_index ^ power_of_two(order);
}

// 获取伙伴块
static struct Page *get_buddy(struct Page *page, unsigned int order) {
    unsigned long buddy_index = get_buddy_index(page, order);
    return pages + buddy_index;  // 修改 base 为 pages
}

// 检查两个块是否是连续的伙伴块
static bool is_continuous_buddies(struct Page *page1, struct Page *page2, unsigned int order) {
    unsigned long idx1 = page1 - pages;  // 修改 base 为 pages
    unsigned long idx2 = page2 - pages;  // 修改 base 为 pages
    unsigned long lower_idx = (idx1 < idx2) ? idx1 : idx2;
    
    // 检查两个块是否是连续的伙伴块
    return (idx1 ^ idx2) == power_of_two(order) && 
           (lower_idx & ((power_of_two(order + 1)) - 1)) == 0;
}

static void
buddy_init(void) {
    // 初始化各阶空闲链表
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_init(&buddy_free_lists[i]);
        buddy_nr_free[i] = 0;
    }
    nr_free = 0;
}

static void
buddy_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    
    // 初始化所有页
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    
    nr_free += n;
    
    // 计算最大可能的阶数
    unsigned int max_order = 0;
    while (power_of_two(max_order + 1) <= n && max_order < MAX_ORDER) {
        max_order++;
    }
    
    size_t allocated_size = 0;
    size_t remaining = n;
    
    // 将内存划分为2的幂次方的块
    while (remaining > 0) {
        unsigned int current_order = max_order;
        while (current_order > 0 && power_of_two(current_order) > remaining) {
            current_order--;
        }
        
        if (power_of_two(current_order) <= remaining) {
            // 初始化这个块
            struct Page *block_base = base + allocated_size;
            block_base->property = current_order;
            set_page_freed(block_base);
            
            // 添加到对应阶的空闲链表
            list_add(&buddy_free_lists[current_order], &(block_base->page_link));
            buddy_nr_free[current_order]++;
            
            allocated_size += power_of_two(current_order);
            remaining -= power_of_two(current_order);
        } else {
            // 处理剩余的小块（小于最小阶）
            break;
        }
    }
    
    // 如果有剩余的小块，将它们合并到最小阶中
    if (remaining > 0) {
        // 将剩余页面作为小块处理
        for (size_t i = allocated_size; i < n; i++) {
            struct Page *p = base + i;
            p->property = 0; // 最小阶
            set_page_freed(p);
            list_add(&buddy_free_lists[0], &(p->page_link));
            buddy_nr_free[0]++;
        }
    }
}

static struct Page *
buddy_alloc_pages(size_t n) {
    if (n == 0) {
        return NULL;  // 分配0页直接返回NULL
    }
    
    if (n > nr_free) {
        return NULL;
    }
    
    // 计算所需阶数
    unsigned int required_order = log2_ceil(n);
    
    if (required_order > MAX_ORDER) {
        return NULL;
    }
    
    // 从所需阶数开始向上查找可用块
    unsigned int current_order = required_order;
    struct Page *allocated_block = NULL;
    
    while (current_order <= MAX_ORDER) {
        if (buddy_nr_free[current_order] > 0) {
            // 找到可用块
            list_entry_t *le = list_next(&buddy_free_lists[current_order]);
            allocated_block = le2page(le, page_link);
            
            // 从空闲链表中移除
            list_del(le);
            buddy_nr_free[current_order]--;
            nr_free -= power_of_two(current_order);
            
            // 如果块太大，需要分割
            while (current_order > required_order) {
                current_order--;
                
                // 分割块：后半部分作为伙伴块
                struct Page *buddy = allocated_block + power_of_two(current_order);
                
                // 设置伙伴块的属性
                set_page_order(buddy, current_order);
                set_page_freed(buddy);
                
                // 将伙伴块加入对应阶的空闲链表
                list_add(&buddy_free_lists[current_order], &(buddy->page_link));
                buddy_nr_free[current_order]++;
                nr_free += power_of_two(current_order);
            }
            
            // 设置分配块的属性
            set_page_order(allocated_block, required_order);
            set_page_allocated(allocated_block);
            
            return allocated_block;
        }
        current_order++;
    }
    
    return NULL; // 没有找到合适的块
}

static void
buddy_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    
    unsigned int order = get_page_order(base);
    assert(power_of_two(order) == n); // 确保释放大小与分配时一致
    
    set_page_freed(base);
    nr_free += n;
    
    // 尝试与伙伴块合并
    while (order < MAX_ORDER) {
        struct Page *buddy = get_buddy(base, order);
        
        // 检查伙伴块是否存在、空闲且阶数相同
        if (!page_is_allocated(buddy) && 
            get_page_order(buddy) == order && 
            is_continuous_buddies(base, buddy, order)) {
            
            // 从空闲链表中移除伙伴块
            list_del(&(buddy->page_link));
            buddy_nr_free[order]--;
            nr_free -= power_of_two(order);
            
            // 合并为更大的块
            if (base > buddy) {
                base = buddy;
            }
            order++;
        } else {
            break;
        }
    }
    
    // 将合并后的块加入对应阶的空闲链表
    set_page_order(base, order);
    list_add(&buddy_free_lists[order], &(base->page_link));
    buddy_nr_free[order]++;
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

// 打印伙伴系统状态（用于调试）
static void
buddy_show(void) {
    cprintf("伙伴系统状态:\n");
    cprintf("总空闲页数: %u\n", nr_free);
    
    for (int i = 0; i <= MAX_ORDER; i++) {
        cprintf("阶数 %d (大小 %d): %d 个空闲块\n", 
                i, power_of_two(i), buddy_nr_free[i]);
        
        // 打印每个空闲块的信息
        list_entry_t *le = &buddy_free_lists[i];
        while ((le = list_next(le)) != &buddy_free_lists[i]) {
            struct Page *page = le2page(le, page_link);
            cprintf("  块地址: %p, 大小: %d\n", page, power_of_two(i));
        }
    }
}

// 基础测试函数
static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(nr_free == 1);

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// 伙伴系统特定测试
static void
buddy_check(void) {
    cprintf("=== 开始伙伴系统测试 ===\n\n");
    
    // 测试1: 基本分配释放
    cprintf("测试1: 基本分配和释放功能\n");
    struct Page *p1 = alloc_pages(1);
    assert(p1 != NULL);
    cprintf("成功分配1页内存，地址: %p\n", p1);
    
    struct Page *p2 = alloc_pages(2);
    assert(p2 != NULL);
    cprintf("成功分配2页内存，地址: %p\n", p2);
    
    free_pages(p1, 1);
    cprintf("成功释放1页内存\n");
    
    free_pages(p2, 2);
    cprintf("成功释放2页内存\n");
    cprintf("测试1 通过\n\n");
    
    // 测试2: 伙伴合并
    cprintf("测试2: 伙伴合并测试\n");
    struct Page *blocks[4];
    for (int i = 0; i < 4; i++) {
        blocks[i] = alloc_pages(1);
        assert(blocks[i] != NULL);
        cprintf("分配块 %d，地址: %p\n", i, blocks[i]);
    }
    
    // 按特定顺序释放以测试合并
    free_pages(blocks[0], 1);
    free_pages(blocks[1], 1);
    free_pages(blocks[2], 1);
    free_pages(blocks[3], 1);
    
    cprintf("所有块已释放，检查合并情况...\n");
    // 应该合并成一个大块
    assert(buddy_nr_free[2] >= 1); // 至少有一个4页的块
    cprintf("测试2 通过\n\n");
    
    // 测试3: 边界情况
    cprintf("测试3: 边界情况测试\n");
    // 分配0页
    struct Page *p0 = alloc_pages(0);
    assert(p0 == NULL);
    cprintf("零页分配正确返回 NULL\n");
    
    // 分配超过最大阶的页数
    struct Page *p_large = alloc_pages(power_of_two(MAX_ORDER + 1));
    assert(p_large == NULL);
    cprintf("超大分配正确返回 NULL\n");
    cprintf("测试3 通过\n\n");
    
    // 测试4: 精确大小分配
    cprintf("测试4: 精确大小分配测试\n");
    struct Page *p_exact = alloc_pages(4);
    assert(p_exact != NULL);
    assert(get_page_order(p_exact) == 2); // 4页对应阶数2
    free_pages(p_exact, 4);
    cprintf("精确大小分配测试 通过\n\n");
    
    cprintf("=== 所有伙伴系统测试通过 ===\n");
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};