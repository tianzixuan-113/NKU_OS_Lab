#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>
#include <stdio.h>

#define USE_SKEW_HEAP 1

/* You should define the BigStride constant here*/
/* LAB6 CHALLENGE 1: YOUR CODE */
//#define BIG_STRIDE /* you should give a value, and is ??? */
#define BIG_STRIDE 0x7FFFFFFF

/* The compare function for two skew_heap_node_t's and the
 * corresponding procs*/
static int
proc_stride_comp_f(void *a, void *b)
{
     struct proc_struct *p = le2proc(a, lab6_run_pool);
     struct proc_struct *q = le2proc(b, lab6_run_pool);
     int32_t c = p->lab6_stride - q->lab6_stride;
     if (c > 0)
          return 1;
     else if (c == 0)
          return 0;
     else
          return -1;
}

/*
 * stride_init initializes the run-queue rq with correct assignment for
 * member variables, including:
 *
 *   - run_list: should be a empty list after initialization.
 *   - lab6_run_pool: NULL
 *   - proc_num: 0
 *   - max_time_slice: no need here, the variable would be assigned by the caller.
 *
 * hint: see libs/list.h for routines of the list structures.
 */
static void
stride_init(struct run_queue *rq)
{
     /* LAB6 CHALLENGE 1: YOUR CODE
      * (1) init the ready process list: rq->run_list
      * (2) init the run pool: rq->lab6_run_pool
      * (3) set number of process: rq->proc_num to 0
      */
      /* (1) init the ready process list: rq->run_list */
#if USE_SKEW_HEAP
     /* 使用斜堆，run_list 不使用 */
#else
     list_init(&(rq->run_list));  /* 如果不使用斜堆，初始化链表 */
#endif
     
     /* (2) init the run pool: rq->lab6_run_pool */
     rq->lab6_run_pool = NULL;    /* 斜堆初始为空 */
     
     /* (3) set number of process: rq->proc_num to 0 */
     rq->proc_num = 0;            /* 进程数初始为0 */
}

/*
 * stride_enqueue inserts the process ``proc'' into the run-queue
 * ``rq''. The procedure should verify/initialize the relevant members
 * of ``proc'', and then put the ``lab6_run_pool'' node into the
 * queue(since we use priority queue here). The procedure should also
 * update the meta date in ``rq'' structure.
 *
 * proc->time_slice denotes the time slices allocation for the
 * process, which should set to rq->max_time_slice.
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
     /* LAB6 CHALLENGE 1: YOUR CODE
      * (1) insert the proc into rq correctly
      * NOTICE: you can use skew_heap or list. Important functions
      *         skew_heap_insert: insert a entry into skew_heap
      *         list_add_before: insert  a entry into the last of list
      * (2) recalculate proc->time_slice
      * (3) set proc->rq pointer to rq
      * (4) increase rq->proc_num
      */
      /* (1) insert the proc into rq correctly */
#if USE_SKEW_HEAP
     /* 使用斜堆插入 */
     rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, 
                                         &(proc->lab6_run_pool), 
                                         proc_stride_comp_f);
#else
     /* 使用链表插入 */
     assert(list_empty(&(proc->run_link)));
     list_add_before(&(rq->run_list), &(proc->run_link));
#endif
     
     /* (2) recalculate proc->time_slice */
     if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
          proc->time_slice = rq->max_time_slice;
     }
     
     /* (3) set proc->rq pointer to rq */
     proc->rq = rq;
     
     /* (4) increase rq->proc_num */
     rq->proc_num++;
}

/*
 * stride_dequeue removes the process ``proc'' from the run-queue
 * ``rq'', the operation would be finished by the skew_heap_remove
 * operations. Remember to update the ``rq'' structure.
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static void
stride_dequeue(struct run_queue *rq, struct proc_struct *proc)
{
     /* LAB6 CHALLENGE 1: YOUR CODE
      * (1) remove the proc from rq correctly
      * NOTICE: you can use skew_heap or list. Important functions
      *         skew_heap_remove: remove a entry from skew_heap
      *         list_del_init: remove a entry from the  list
      */
           /* (1) remove the proc from rq correctly */
#if USE_SKEW_HEAP
     /* 从斜堆中移除 */
     rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool, 
                                        &(proc->lab6_run_pool), 
                                        proc_stride_comp_f);
#else
     /* 从链表中移除 */
     assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
     list_del_init(&(proc->run_link));
#endif
     
     /* 更新运行队列信息 */
     proc->rq = NULL;       /* 清空进程的运行队列指针 */
     rq->proc_num--;        /* 减少进程计数 */

}
/*
 * stride_pick_next pick the element from the ``run-queue'', with the
 * minimum value of stride, and returns the corresponding process
 * pointer. The process pointer would be calculated by macro le2proc,
 * see kern/process/proc.h for definition. Return NULL if
 * there is no process in the queue.
 *
 * When one proc structure is selected, remember to update the stride
 * property of the proc. (stride += BIG_STRIDE / priority)
 *
 * hint: see libs/skew_heap.h for routines of the priority
 * queue structures.
 */
static struct proc_struct *
stride_pick_next(struct run_queue *rq)
{
     /* LAB6 CHALLENGE 1: YOUR CODE
      * (1) get a  proc_struct pointer p  with the minimum value of stride
             (1.1) If using skew_heap, we can use le2proc get the p from rq->lab6_run_pol
             (1.2) If using list, we have to search list to find the p with minimum stride value
      * (2) update p;s stride value: p->lab6_stride
      * (3) return p
      */
      #if USE_SKEW_HEAP
     /* (1.1) 使用斜堆，获取stride最小的进程 */
     if (rq->lab6_run_pool == NULL) {
          return NULL;  /* 斜堆为空，返回NULL */
     }
     
     struct proc_struct *p = le2proc(rq->lab6_run_pool, lab6_run_pool);
#else
     /* (1.2) 使用链表，查找stride最小的进程 */
     if (list_empty(&(rq->run_list))) {
          return NULL;  /* 链表为空，返回NULL */
     }
     
     list_entry_t *le = list_next(&(rq->run_list));
     struct proc_struct *p = le2proc(le, run_link);
     struct proc_struct *min_p = p;
     uint32_t min_stride = p->lab6_stride;
     
     /* 遍历链表找到stride最小的进程 */
     while ((le = list_next(le)) != &(rq->run_list)) {
          p = le2proc(le, run_link);
          if (p->lab6_stride < min_stride) {
               min_stride = p->lab6_stride;
               min_p = p;
          }
     }
     p = min_p;
#endif
     
     /* (2) update p's stride value: p->lab6_stride */
     if (p->lab6_priority > 0) {
          /* 计算pass值：BIG_STRIDE / priority */
          uint32_t pass = BIG_STRIDE / p->lab6_priority;
          if (pass == 0) {
               pass = 1;  /* 确保至少增加1，防止除0错误 */
          }
          p->lab6_stride += pass;
     } else {
          /* 如果优先级为0，设置为1并增加BIG_STRIDE */
          p->lab6_priority = 1;
          p->lab6_stride += BIG_STRIDE;
     }
     
     /* (3) return p */
     return p;

}

/*
 * stride_proc_tick works with the tick event of current process. You
 * should check whether the time slices for current process is
 * exhausted and update the proc struct ``proc''. proc->time_slice
 * denotes the time slices left for current
 * process. proc->need_resched is the flag variable for process
 * switching.
 */
static void
stride_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
     /* LAB6 CHALLENGE 1: YOUR CODE */
      if (proc->time_slice > 0) {
          proc->time_slice--;  /* 减少时间片 */
     }
     
     /* 检查时间片是否用完 */
     if (proc->time_slice == 0) {
          proc->need_resched = 1;  /* 设置需要重新调度的标志 */
     }

}

struct sched_class stride_sched_class = {
    .name = "stride_scheduler",
    .init = stride_init,
    .enqueue = stride_enqueue,
    .dequeue = stride_dequeue,
    .pick_next = stride_pick_next,
    .proc_tick = stride_proc_tick,
};
