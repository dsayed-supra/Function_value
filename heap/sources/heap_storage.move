module heap::heap_storage {
    use std::signer;
    use heap::heap::{Self, Heap};

    struct StoredHeap has key {
        heap: Heap<u64>,
    }

    struct HeapOperations has key {
        initialize_max_heap: |&signer| has store + copy,
        initialize_min_heap: |&signer| has store + copy,
        insert: |&signer, u64| has store + copy,
        extract: |&signer| has store + copy,
    }

    public entry fun initialize_module(
        account: &signer) {
        let init_max_fn = |s: &signer| initialize_max_heap(s);
        let init_min_fn = |s: &signer| initialize_min_heap(s);
        let insert_fn = |s: &signer, v: u64| insert(s, v);
        let extract_fn = |s: &signer| extract(s);

        let function_store = HeapOperations {
            initialize_max_heap: init_max_fn,
            initialize_min_heap: init_min_fn,
            insert: insert_fn,
            extract: extract_fn,
        };

        move_to(account, function_store);
    }

    #[persistent]
    public fun initialize_max_heap(account: &signer) {
        let heap = heap::new_max_heap();
        move_to(account, StoredHeap { heap });
    }

    #[persistent]
    public fun initialize_min_heap(account: &signer) {
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


    /// Execute initialize_max_heap operation dynamically
    public entry fun execute_init_max_heap(s: &signer) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        
        // Move out operations (similar to your Calculator pattern)
        let HeapOperations { 
            initialize_max_heap, 
            initialize_min_heap, 
            insert, 
            extract 
        } = move_from<HeapOperations>(addr);
        
        // Execute the stored function
        (initialize_max_heap)(s);
        
        // Move operations back
        move_to(s, HeapOperations {
            initialize_max_heap,
            initialize_min_heap,
            insert,
            extract,
        });
        
        
    }

    /// Execute initialize_min_heap operation dynamically
    public entry fun execute_init_min_heap(s: &signer) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        
        let HeapOperations { 
            initialize_max_heap, 
            initialize_min_heap, 
            insert, 
            extract 
        } = move_from<HeapOperations>(addr);
        
        // Execute the stored function
        (initialize_min_heap)(s);
        
        move_to(s, HeapOperations {
            initialize_max_heap,
            initialize_min_heap,
            insert,
            extract,
        });
        
       
    }

    /// Execute insert operation dynamically
    public entry fun execute_insert(s: &signer, value: u64) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        
        let HeapOperations { 
            initialize_max_heap, 
            initialize_min_heap, 
            insert, 
            extract 
        } = move_from<HeapOperations>(addr);
        
        // Execute the stored insert function
        (insert)(s, value);
        
        move_to(s, HeapOperations {
            initialize_max_heap,
            initialize_min_heap,
            insert,
            extract,
        });
        
       
    }

    /// Execute extract operation dynamically
    public entry fun execute_extract(s: &signer) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        
        let HeapOperations { 
            initialize_max_heap, 
            initialize_min_heap, 
            insert, 
            extract 
        } = move_from<HeapOperations>(addr);
        
        // Execute the stored extract function
        (extract)(s);
        
        move_to(s, HeapOperations {
            initialize_max_heap,
            initialize_min_heap,
            insert,
            extract,
        });
        
       
    }

    /// View top value
    #[view]
    public fun peek(addr: address): u64 acquires StoredHeap {
        let stored = borrow_global<StoredHeap>(addr);
        heap::peek(&stored.heap)
    }

    /// View heap size
    #[view]
    public fun size(addr: address): u64 acquires StoredHeap {
        let stored = borrow_global<StoredHeap>(addr);
        heap::size(&stored.heap)
    }

    /// Check if empty
    #[view]
    public fun is_empty(addr: address): bool acquires StoredHeap {
        let stored = borrow_global<StoredHeap>(addr);
        heap::is_empty(&stored.heap)
    }

    #[test(account = @heap)]
    public fun test_dynamic_heap_operations(account: &signer) 
        acquires HeapOperations, StoredHeap 
    {
        use std::signer;
       
        initialize_module(account);
        
        execute_init_max_heap(account);
        
        let addr = signer::address_of(account);
        
        execute_insert(account, 10);
        execute_insert(account, 20);
        execute_insert(account, 5);
        
        
        assert!(peek(addr) == 20, 1);
        assert!(size(addr) == 3, 2);
        
        execute_extract(account);
        
        assert!(size(addr) == 2, 4);
       
    }

    #[test(account = @heap)]
    public fun test_min_heap_operations(account: &signer) 
        acquires HeapOperations, StoredHeap 
    {
        use std::signer;
        
        initialize_module(account);
        
        execute_init_min_heap(account);
        
        let addr = signer::address_of(account);
        
        execute_insert(account, 10);
        execute_insert(account, 20);
        execute_insert(account, 5);
        
        // Min heap: 5 should be at top
        assert!(peek(addr) == 5, 1);
        
        execute_extract(account);
        
        // After extracting 5, next min should be 10
        assert!(peek(addr) == 10, 2);
    }
}
