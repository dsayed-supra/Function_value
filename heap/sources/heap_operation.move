module heap::heap_operations {
    use std::signer;
    use heap::heap::{Self, Heap};

    /// Storage for heap (duplicated here to avoid circular dependency)
    struct StoredHeap has key {
        heap: Heap<u64>,
    }

    // PERSISTENT OPERATION FUNCTIONS
    // These are in a SEPARATE module to avoid reentrancy
    #[persistent]
    public fun init_max_heap(account: &signer) {
        let heap = heap::new_max_heap();
        move_to(account, StoredHeap { heap });
    }

    #[persistent]
    public fun init_min_heap(account: &signer) {
        let heap = heap::new_min_heap();
        move_to(account, StoredHeap { heap });
    }

    #[persistent]
    public fun insert(account: &signer, value: u64) acquires StoredHeap {
        let addr = signer::address_of(account);
        let stored = borrow_global_mut<StoredHeap>(addr);
        heap::insert(&mut stored.heap, value);
    }

    #[persistent]
    public fun extract(account: &signer) acquires StoredHeap {
        let addr = signer::address_of(account);
        let stored = borrow_global_mut<StoredHeap>(addr);
        heap::extract(&mut stored.heap);
    }

    #[view]
    public fun peek(addr: address): u64 acquires StoredHeap {
        let stored = borrow_global<StoredHeap>(addr);
        heap::peek(&stored.heap)
    }

    #[view]
    public fun size(addr: address): u64 acquires StoredHeap {
        let stored = borrow_global<StoredHeap>(addr);
        heap::size(&stored.heap)
    }

    #[view]
    public fun is_empty(addr: address): bool acquires StoredHeap {
        let stored = borrow_global<StoredHeap>(addr);
        heap::is_empty(&stored.heap)
    }
}