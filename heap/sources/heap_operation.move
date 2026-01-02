module heap::heap_operations {
    use std::signer;
    use heap::heap::{Self, Heap};

    /// Storage for heap (duplicated here to avoid circular dependency)
    struct StoredHeap<T: store + drop + copy> has key {
        heap: Heap<T>,
    }

    // PERSISTENT OPERATION FUNCTIONS
    // These are in a SEPARATE module to avoid reentrancy
    #[persistent]
    public fun init_max_heap<T: store + drop + copy>(account: &signer) {
        let heap = heap::new_max_heap<T>();
        move_to(account, StoredHeap { heap });
    }

    #[persistent]
    public fun init_min_heap<T: store + drop + copy>(account: &signer) {
        let heap = heap::new_min_heap<T>();
        move_to(account, StoredHeap { heap });
    }

    #[persistent]
    public fun insert<T: store + drop + copy>(account: &signer, value: T) acquires StoredHeap {
        let addr = signer::address_of(account);
        let stored = borrow_global_mut<StoredHeap<T>>(addr);
        heap::insert(&mut stored.heap, value);
    }

    #[persistent]
    public fun extract<T: store + drop + copy>(account: &signer) acquires StoredHeap {
        let addr = signer::address_of(account);
        let stored = borrow_global_mut<StoredHeap<T>>(addr);
        heap::extract(&mut stored.heap);
    }

    #[view]
    public fun peek<T: store + drop + copy>(addr: address): T acquires StoredHeap {
        let stored = borrow_global<StoredHeap<T>>(addr);
        heap::peek(&stored.heap)
    }

    #[view]
    public fun size<T: store + drop + copy>(addr: address): u64 acquires StoredHeap {
        let stored = borrow_global<StoredHeap<T>>(addr);
        heap::size(&stored.heap)
    }

    #[view]
    public fun is_empty<T: store + drop + copy>(addr: address): bool acquires StoredHeap {
        let stored = borrow_global<StoredHeap<T>>(addr);
        heap::is_empty(&stored.heap)
    }
}