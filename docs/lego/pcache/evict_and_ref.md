# Mumble pcache eviction and refcount

This is about how Lego is doing eviction against live references of pcache. Unlike the `garbage collection` where it only reclaims object that has no references, pcache eviction may try to evict a pcache that is currently being used by another thread. Both parties need to be very careful. A tricky business.

To describe the issue in a high-level, let us consider this case: the system now has two threads running on two different cores. The first thread try to evict a pcache line, and it truly find a candidate and prepare to evict. Meanwhile, the other thread is currently using this pcache line to do some operations such as `zap_rmap()`. If the first thread evict the pcache line without synchronization with the second thread, oops, the second thread is playing with a wrong pcache.

The textbook idea is adding refcount. However, this is not enough in C. Because:

- There is no way to prevent the second thread from getting the __`pointer`__ to that pcm.
- A simple `inc_refcount()` from the second thread can happen anytime in the middle of first thread's eviction.

Solutions:

 - To actually prevent the second thread from getting the pointer, we should think about _how_ it get the pointer? Luckily, in Lego, there is only one entry point, which is from `pte to pcm` (aka. pcache_meta). So to synchronize pte change becomes very important. Luckily, we are doing pte_lock before getting the pcm. So this simple pte lock ensures the second thread a safe, will-not-be-evicted pcm (of course, with some other checkings). This idea can also be generalized to any data structures that need pointer references: __protect your pointer__!
 - Refcount checking is also necessary. In the eviction routine, we need to use  `atomic_xchg` to reset the refcount. If this fails, it means someone else is using it. Do note, this `atomic_xchg` is carried out with pcm locked. Thus the ordering of locking, get/put matters in the code.

The code itself tells a much more complete story, I strongly recommend you read the code if you are interested. Here I will list the most interesting part. For the other users except eviction, they need to do this:
```c hl_lines="28"
pcm = pte_to_pcache_meta(ptent);
/*   
 * We have a strict lock ordering everyone should obey:
 *      lock pcache
 *      lock pte
 * The caller already locked pte, thus we should avoid deadlock here
 * by droping pte lock first and then acquire both of them in order.
 */
if (unlikely(!trylock_pcache(pcm))) {
	/* in case it got evicted and @pcm becomes invalid */
	get_pcache(pcm);

	/*
	 * Once we release the pte lock, this pcm may be
	 * unmapped by another thread who is doing eviction.
	 * Since we have grabbed one extra ref above, so even
	 * it is unmapped, eviction thread will not fail to free it.
	 */
	spin_unlock(ptl);

	lock_pcache(pcm);
	spin_lock(ptl);

	/*   
	 * Since we dropped the lock, the pcache line might
	 * be got evicted in the middle.
	 */
	if (!pte_same(*pte, ptent)) {
		unlock_pcache(pcm);
		/*   
		 * This put maybe decreases the ref to 0
		 * and eventually free the pcache line.
		 * This happens if the @pcm was selected
		 * to be evicted at the same time.
		 */
		put_pcache(pcm);
		return -EAGAIN;
	}    
	put_pcache(pcm);
}
```

As for the eviction thread, it needs to make sure it is the last user using this pcm:
```c
/*  
 * Each rmap counts one refcount, plus the one grabbed
 * during evict_find_line(), we should have (nr_mapped + 1)
 * here if there are no any other users.
 *
 * Furthurmore, others can not go from munmap/mremap/wp to
 * put_pcache() within pcache_zap_pte(), pcache_move_pte()
 * or pcache_do_wp_page(). Thus the refcount must larger or
 * equal to (nr_mapped + 1).
 *
 * But if there truly other users (refcount > nr_mapped + 1),
 * then we should manually sub the refcount. The other users
 * which are currently holding the ref, will free the pcache
 * once it call put_pcache.
 */
PCACHE_BUG_ON_PCM(pcache_ref_count(pcm) < nr_mapped + 1, pcm);
if (unlikely(!pcache_ref_freeze(pcm, nr_mapped + 1))) {
	if (unlikely(pcache_ref_sub_and_test(pcm, nr_mapped + 1))) {
		pr_info("BUG: pcm refcount, nr_mapped: %d\n", nr_mapped);
		dump_pcache_meta(pcm, "ref error");
		BUG();
	}   

	ClearPcacheReclaim(pcm);
	add_to_lru_list(pcm, pset);
	unlock_pcache(pcm);

	inc_pcache_event(PCACHE_EVICTION_EAGAIN_CONCURRENT);
	return PCACHE_EVICT_EAGAIN_CONCURRENT;
}
```

---
My personal thought: live eviction against live objects/references is very hard. You first need to use refcount to ensure a correct ordering. You also need to have a way to prevent others from using the going-to-be-evicted pointer, or have a way to detect a under-use pointer.  In this Lego pcache case, we use the combination of pte lock, pcache lock, and pcache refcount, to ensure everyone is safe. And all these is quite similar to Linux page operations. I learned a lot from its code. But I still not fully understand how it ensures the page is not used by others, it has way more parties than lego that can use the page at the same time of eviction. Magic kernel folks.

--  
Yizhou Shan :herb:  
Created: Mar 15, 2018  
Last Updated: Mar 16, 2018
