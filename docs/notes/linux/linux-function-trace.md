# How to Dump Function Call Graph in Linux

??? note "Version History"
	|Date|Description|
	|:---|-----------|
	|Nov 1, 2021| new|

I want to share the method I use to dump the function call graph
in a live Linux machine. This is particularly useful when you are
studying the source code and try to understand the call flow.
This is not the only way to do so, but I found it convenient in my own reading flow.

The approach I took is fairly simple, I use **ftrace**.
It has a feature to monitor the call graph AND dump the latency.
I wrote a very simple script for this purpose.

The whole scripts are uploaded to this repo https://github.com/lastweek/linux-ftrace.
These are the steps I'd take

1. Modify the `set_graph_function.sh`, add the functions I want to dump.
2. Run `set_graph_function.sh` directly.
3. Dump the trace by running `cat_trace_file.sh`.
4. Disable tracing by running `disable.sh`.

The nice thing about ftrace is that it also measures the latency.
If you want to understand how ftrace is able to dynamically measure
the latency and has such a great flexibility, please check out
my other blog here: http://lastweek.io/notes/trace/#ftrace.


## Examples

Say I want to check `handle_mm_fault()`'s runtime call graph.
I would first modify the scipts to include this func.
```bash
set -e

DIR=/sys/kernel/debug/tracing

# Presetup if any
# ./prepare.sh

# Disable tracing and clear trace
echo 0 > $DIR/tracing_on
echo > $DIR/trace
echo > $DIR/set_ftrace_filter
echo > $DIR/set_graph_function

# Setup tracer type
echo function_graph > $DIR/current_tracer

#
# The functions we'd trace
#
echo handle_mm_fault >> $DIR/set_graph_function

echo "Enabled graph functions:"
cat $DIR/set_graph_function

echo 1 > $DIR/tracing_on
```

Run the scripts, and look into the trace file, it would give
us something like the following. Though, keep in mind that
functions like `handle_mm_fault()` is very dynamic, there
are many call graph combos.
```
# tracer: function_graph                            
#                                                            
# CPU  DURATION                  FUNCTION CALLS       
# |     |   |                     |   |   |   |       
 39)               |  handle_mm_fault() {           
 39)   0.677 us    |    mem_cgroup_from_task();       
 39)   0.918 us    |    __count_memcg_events();         
 39)               |    __handle_mm_fault() {                 
 39)               |      do_huge_pmd_numa_page() {             
 39)   0.682 us    |        _raw_spin_lock();       
 39)   0.570 us    |        pmd_trans_migrating();                 
 39)               |        mpol_misplaced() {                 
 39)   0.471 us    |          __get_vma_policy();       
 39)               |          get_vma_policy.part.0() {       
 39)   0.387 us    |            get_task_policy.part.0();       
 39)   1.091 us    |          }                            
 39)               |          should_numa_migrate_memory() {       
 39)   0.374 us    |            page_cpupid_xchg_last();       
 39)   1.095 us    |          }       
 39)   4.410 us    |        }       
 39)   0.389 us    |        unlock_page();       
 39)               |        task_numa_fault() {       
 39)               |          __kmalloc() {           
 39)   0.382 us    |            kmalloc_slab();       
 39)               |            _cond_resched() {            
 39)   0.391 us    |              rcu_all_qs();       
 39)   1.115 us    |            }                   
 39)   0.391 us    |            should_failslab();       
 39)   0.461 us    |            memcg_kmem_put_cache();       
 39)   4.628 us    |          }                         
 39)   0.529 us    |          task_numa_placement();          
 39)   6.481 us    |        }                                   
 39) + 15.130 us   |      }           
 39) + 16.854 us   |    }                                          
 39) + 21.198 us   |  }
```
