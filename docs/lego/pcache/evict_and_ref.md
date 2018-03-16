# Mumble pcache eviction and refcount

This is about how Lego is doing eviction again live references of pcache. Unlike the garbage collection where it only reclaims object that has no references, pcache eviction may try to evict a pcache that is currently being used by another thread. Both party need to be very careful. A tricky business.

To describe the issue in a high-level, let us consider this case: the system now has two threads running on two different cores. The first thread trys to evict a pcache line, and it truly find a candidate and prepare to evict. Meanwhile, the other thread is currently using this pcache line to do some operations such as zap_rmap. If the first thread evict the pcache line without synchronization with the second thread, oops, the second thread is playing with a wrong pcache.

The textbook solution is adding refcount. But this is not enough in C. There is no way to prevent the second thread getting the pointer to pcm. To actually prevent the second thread from getting the pointer, we should think about how it get the pointer. There is only one entry point, which is from pte to pcm (aka. pcache_meta).

So to synchronize pte change becomes very important. Luckily, we are doing pte_lock before getting the pcm. So this simple pte lock ensures the second thread a safe, will-not-be-evicted pcm (of course, with some other checkings).

My personal thought on this issue: live eviction against live objects/references is very hard to do. You first need to use refcount to ensure a correct ordering. You also need to have a way to prevent others from using the going-to-be-evicted pointer, or have a way to detect a under-use pointer.  In this Lego pcache case, we use the combination of pte lock, pcache lock, and pcache refcount, to ensure everyone is safe.

This is quite similar to Linux page operations. I learned a lot from its coding. But I still not fully understand how it ensures the page is not used by others, it has way more parties than lego that can use the page at the same time of eviction.

--  
Yizhou Shan  
Created: Mar 15, 2018 23:58  
Last Updated: Mar 15, 2018
