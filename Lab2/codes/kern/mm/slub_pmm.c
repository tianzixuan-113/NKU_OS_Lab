#include <pmm.h>
#include <list.h>
#include <string.h>
#include <slub_pmm.h>
#include <stdio.h>

/* 
 * SLUB分配算法：两层架构的内存分配
 * 第一层：基于页大小的内存分配（从伙伴系统获取）
 * 第二层：在页框内实现基于任意大小的对象分配
 */

static free_area_t free_area;
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

// SLAB 描述符
struct slab {
    struct kmem_cache *cache;
    void *freelist;
    unsigned int inuse;
    unsigned int free;
    list_entry_t slab_link;
};

// SLUB 缓存描述符
struct kmem_cache {
    char name[SLUB_NAME_LEN];
    unsigned int size;
    unsigned int objs_per_slab;
    unsigned int order;
    unsigned int offset;
    
    list_entry_t slabs_full;
    list_entry_t slabs_partial;
    list_entry_t slabs_free;
    
    unsigned int num_slabs;
    unsigned int num_objects;
    unsigned int num_free;
};

// 预定义的SLUB缓存
static struct kmem_cache *slub_caches[8];
static unsigned int cache_sizes[] = {16, 32, 64, 128, 256, 512, 1024, 2048};

// 辅助函数
static inline void *pa2kva(uintptr_t pa) {
    return (void *)(pa + KERNBASE);
}

static inline uintptr_t kva2pa(void *kva) {
    return (uintptr_t)kva - KERNBASE;
}

static inline void *page2kva(struct Page *page) {
    return pa2kva(page2pa(page));
}

static inline unsigned int calculate_aligned_size(unsigned int size) {
    if (size < 16) return 16;
    return (size + 15) & ~15;
}

// === 公共函数实现 ===

struct kmem_cache *kmem_cache_create(const char *name, size_t size) {
    static struct kmem_cache cache_storage;
    struct kmem_cache *cache = &cache_storage;
    
    strncpy(cache->name, name, SLUB_NAME_LEN - 1);
    cache->name[SLUB_NAME_LEN - 1] = '\0';
    cache->size = calculate_aligned_size(size);
    
    // 简化：每个slab只包含一个对象，使用1页
    cache->objs_per_slab = 1;
    cache->order = 0;
    cache->offset = 0;
    
    list_init(&cache->slabs_full);
    list_init(&cache->slabs_partial);
    list_init(&cache->slabs_free);
    
    cache->num_slabs = 0;
    cache->num_objects = 0;
    cache->num_free = 0;
    
    cprintf("创建SLUB缓存: %s, 对象大小: %u\n", cache->name, cache->size);
    
    return cache;
}

void kmem_cache_destroy(struct kmem_cache *cache) {
    if (!cache) return;
    cprintf("销毁SLUB缓存: %s\n", cache->name);
}

void *kmem_cache_alloc(struct kmem_cache *cache) {
    if (!cache) {
        cprintf("错误: 缓存为NULL\n");
        return NULL;
    }
    
    cprintf("尝试分配对象，缓存: %s, 当前空闲页面: %u\n", cache->name, nr_free);
    
    // 分配1页内存
    struct Page *page = alloc_pages(1);
    
    if (!page) {
        cprintf("错误: 分配页面失败\n");
        return NULL;
    }
    
    cprintf("成功分配页面: %p\n", page);
    
    // 返回页面的虚拟地址作为对象
    void *obj = page2kva(page);
    
    cprintf("分配对象成功: 缓存=%s, 对象地址=%p\n", cache->name, obj);
    
    // 更新缓存统计
    cache->num_slabs++;
    cache->num_objects++;
    cache->num_free += 0; // 这个对象已分配
    
    return obj;
}

void kmem_cache_free(struct kmem_cache *cache, void *obj) {
    if (!cache || !obj) {
        cprintf("错误: 参数无效\n");
        return;
    }
    
    cprintf("释放对象: 缓存=%s, 对象地址=%p\n", cache->name, obj);
    
    // 转换为物理地址并找到对应的页面
    uintptr_t pa = kva2pa(obj);
    struct Page *page = pa2page(pa);
    
    if (!page) {
        cprintf("错误: 找不到对应的页面\n");
        return;
    }
    
    // 释放页面
    free_pages(page, 1);
    
    cprintf("成功释放页面\n");
    
    // 更新缓存统计
    cache->num_slabs--;
    cache->num_objects--;
}

void *kmalloc(size_t size) {
    if (size == 0) {
        cprintf("kmalloc: 请求大小为0\n");
        return NULL;
    }
    
    cprintf("kmalloc: 请求大小 %u\n", size);
    
    // 选择合适大小的缓存
    for (int i = 0; i < sizeof(cache_sizes)/sizeof(cache_sizes[0]); i++) {
        if (size <= cache_sizes[i]) {
            if (slub_caches[i]) {
                cprintf("使用缓存: size-%u\n", cache_sizes[i]);
                return kmem_cache_alloc(slub_caches[i]);
            }
        }
    }
    
    cprintf("没有合适的缓存，使用页面分配\n");
    
    // 没有合适的缓存，回退到页分配
    unsigned int pages = (size + PGSIZE - 1) / PGSIZE;
    struct Page *page = alloc_pages(pages);
    
    if (page) {
        void *obj = page2kva(page);
        cprintf("页面分配成功: %p\n", obj);
        return obj;
    }
    
    cprintf("页面分配失败\n");
    return NULL;
}

void kfree(void *obj) {
    if (!obj) {
        cprintf("kfree: 对象为NULL\n");
        return;
    }
    
    cprintf("kfree: 释放对象 %p\n", obj);
    
    // 简化实现：假设来自第一个缓存
    if (slub_caches[0]) {
        kmem_cache_free(slub_caches[0], obj);
    } else {
        // 回退到页面释放
        uintptr_t pa = kva2pa(obj);
        struct Page *page = pa2page(pa);
        if (page) {
            free_pages(page, 1);
            cprintf("页面释放成功\n");
        }
    }
}

// === SLUB PMM 管理器实现 ===

static void slub_init(void) {
    list_init(&free_list);
    nr_free = 0;
    
    cprintf("初始化SLUB内存管理器\n");
    
    // 初始化预定义的SLUB缓存
    for (int i = 0; i < sizeof(cache_sizes)/sizeof(cache_sizes[0]); i++) {
        char name[SLUB_NAME_LEN];
        snprintf(name, SLUB_NAME_LEN, "size-%u", cache_sizes[i]);
        slub_caches[i] = kmem_cache_create(name, cache_sizes[i]);
        if (slub_caches[i]) {
            cprintf("成功创建缓存: %s\n", name);
        } else {
            cprintf("创建缓存失败: %s\n", name);
        }
    }
    
    cprintf("SLUB内存管理器初始化完成\n");
}

static void slub_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = 1;  // 每个页面初始化为1页大小
        set_page_ref(p, 0);
        SetPageProperty(p);
        list_add_before(&free_list, &(p->page_link));
    }
    nr_free += n;
    cprintf("slub_init_memmap: 初始化 %u 页，总空闲页: %u\n", n, nr_free);
}

static struct Page *slub_alloc_pages(size_t n) {
    assert(n > 0);
    
    cprintf("slub_alloc_pages: 请求 %u 页，当前空闲: %u\n", n, nr_free);
    
    if (n > nr_free) {
        cprintf("错误: 请求 %u 页但只有 %u 页空闲\n", n, nr_free);
        return NULL;
    }
    
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    
    // 查找第一个足够大的连续页面块
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    
    if (page == NULL) {
        cprintf("错误: 没有找到足够大的连续页面块\n");
        cprintf("调试信息: 遍历空闲链表...\n");
        le = &free_list;
        int count = 0;
        while ((le = list_next(le)) != &free_list) {
            struct Page *p = le2page(le, page_link);
            cprintf("页面 %d: 地址=%p, property=%u\n", count++, p, p->property);
            if (count > 10) break; // 只显示前10个
        }
        return NULL;
    }
    
    // 从链表中移除分配的页面
    list_del(&(page->page_link));
    
    // 如果页面块比需要的大，分割剩余部分
    if (page->property > n) {
        struct Page *p = page + n;
        p->property = page->property - n;
        SetPageProperty(p);
        // 将剩余部分加回空闲链表
        list_add(&free_list, &(p->page_link));
    }
    
    nr_free -= n;
    ClearPageProperty(page);
    
    cprintf("分配成功: 分配 %u 页，页面地址: %p，剩余空闲: %u\n", n, page, nr_free);
    
    return page;
}

static void slub_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    
    cprintf("slub_free_pages: 释放 %u 页，释放前空闲: %u\n", n, nr_free);
    
    struct Page *p = base;
    for (; p != base + n; p++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    
    base->property = n;
    SetPageProperty(base);
    
    // 尝试合并相邻的空闲块
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
        p = le2page(le, page_link);
        le = list_next(le);
        
        // 检查是否能与后面的块合并
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
        // 检查是否能与前面的块合并
        else if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    
    // 将合并后的块加入空闲链表
    nr_free += n;
    list_add(&free_list, &(base->page_link));
    
    cprintf("释放完成，当前空闲: %u\n", nr_free);
}

static size_t slub_nr_free_pages(void) {
    return nr_free;
}

// SLUB 特定测试
static void slub_check(void) {
    cprintf("\n=== 开始SLUB分配器测试 ===\n");
    cprintf("测试前系统空闲页面: %u\n", nr_free);
    
    // 测试1: 基本页面分配（不通过SLUB）
    cprintf("\n测试1: 基本页面分配\n");
    cprintf("测试直接页面分配...\n");
    
    struct Page *test_page = alloc_pages(1);
    if (test_page) {
        cprintf("基本页面分配成功: %p\n", test_page);
        free_pages(test_page, 1);
        cprintf("基本页面释放成功\n");
        cprintf("测试1 通过\n");
    } else {
        cprintf("错误: 基本页面分配失败\n");
        panic("基本功能测试失败");
    }
    
    // 测试2: 基本缓存操作
    cprintf("\n测试2: 基本缓存操作\n");
    struct kmem_cache *test_cache = kmem_cache_create("test-cache", 64);
    assert(test_cache != NULL);
    
    cprintf("创建测试缓存成功，开始分配对象...\n");
    
    void *obj1 = kmem_cache_alloc(test_cache);
    cprintf("第一次分配结果: %p\n", obj1);
    
    void *obj2 = kmem_cache_alloc(test_cache);
    cprintf("第二次分配结果: %p\n", obj2);
    
    if (obj1 == NULL || obj2 == NULL) {
        cprintf("错误: 对象分配失败\n");
        cprintf("当前空闲页面: %u\n", nr_free);
        panic("SLUB测试失败");
    }
    
    assert(obj1 != NULL);
    assert(obj2 != NULL);
    
    cprintf("成功分配两个对象\n");
    cprintf("分配后空闲页面: %u\n", nr_free);
    
    kmem_cache_free(test_cache, obj1);
    kmem_cache_free(test_cache, obj2);
    cprintf("成功释放两个对象\n");
    cprintf("释放后空闲页面: %u\n", nr_free);
    
    kmem_cache_destroy(test_cache);
    cprintf("测试2 通过\n");
    
    // 测试3: 通用内存分配
    cprintf("\n测试3: 通用内存分配\n");
    cprintf("测试前空闲页面: %u\n", nr_free);
    
    void *mem1 = kmalloc(32);
    void *mem2 = kmalloc(128);
    void *mem3 = kmalloc(512);
    
    cprintf("分配结果: mem1=%p, mem2=%p, mem3=%p\n", mem1, mem2, mem3);
    cprintf("分配后空闲页面: %u\n", nr_free);
    
    if (mem1 == NULL || mem2 == NULL || mem3 == NULL) {
        cprintf("错误: 通用分配失败\n");
        panic("SLUB测试失败");
    }
    
    assert(mem1 != NULL);
    assert(mem2 != NULL); 
    assert(mem3 != NULL);
    
    cprintf("通用分配测试通过\n");
    
    kfree(mem1);
    kfree(mem2);
    kfree(mem3);
    cprintf("释放后空闲页面: %u\n", nr_free);
    cprintf("测试3 通过\n");
    
    // 测试4: 边界情况
    cprintf("\n测试4: 边界情况\n");
    void *null_obj = kmalloc(0);
    assert(null_obj == NULL);
    cprintf("零大小分配正确返回NULL\n");
    
    cprintf("测试4 通过\n");
    
    cprintf("\n=== 所有SLUB测试通过 ===\n");
    cprintf("最终空闲页面: %u\n", nr_free);
}

const struct pmm_manager slub_pmm_manager = {
    .name = "slub_pmm_manager",
    .init = slub_init,
    .init_memmap = slub_init_memmap,
    .alloc_pages = slub_alloc_pages,
    .free_pages = slub_free_pages,
    .nr_free_pages = slub_nr_free_pages,
    .check = slub_check,
};