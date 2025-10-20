#ifndef __KERN_MM_SLUB_PMM_H__
#define __KERN_MM_SLUB_PMM_H__

#include <pmm.h>

#define SLUB_NAME_LEN 32

// SLUB管理接口
extern const struct pmm_manager slub_pmm_manager;

// SLUB缓存操作
struct kmem_cache;
struct kmem_cache *kmem_cache_create(const char *name, size_t size);
void kmem_cache_destroy(struct kmem_cache *cache);

// 对象分配释放
void *kmem_cache_alloc(struct kmem_cache *cache);
void kmem_cache_free(struct kmem_cache *cache, void *obj);

// 通用内存分配
void *kmalloc(size_t size);
void kfree(void *obj);

#endif /* !__KERN_MM_SLUB_PMM_H__ */