module heap::heap_storage {
    use std::signer;
    use heap::heap_operations;

    
    // FUNCTION VALUE STORAGE
    struct HeapOperations has key {
        initialize_max_heap: |&signer| has store + copy,
        initialize_min_heap: |&signer| has store + copy,
        insert: |&signer, u64| has store + copy,
        extract: |&signer| has store + copy,
    }

    
    public entry fun initialize_module(account: &signer) {
        
        let init_max_fn = |s: &signer| heap_operations::init_max_heap(s);
        let init_min_fn = |s: &signer| heap_operations::init_min_heap(s);
        let insert_fn = |s: &signer, v: u64| heap_operations::insert(s, v);
        let extract_fn = |s: &signer| heap_operations::extract(s);

        let function_store = HeapOperations {
            initialize_max_heap: init_max_fn,
            initialize_min_heap: init_min_fn,
            insert: insert_fn,
            extract: extract_fn,
        };

        move_to(account, function_store);
    }

  
    // DYNAMIC OPERATION EXECUTION
    public entry fun execute_init_max_heap(s: &signer) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        let ops = borrow_global<HeapOperations>(addr);
        (ops.initialize_max_heap)(s);
    }

    public entry fun execute_init_min_heap(s: &signer) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        let ops = borrow_global<HeapOperations>(addr);
        (ops.initialize_min_heap)(s);
    }

    public entry fun execute_insert(s: &signer, value: u64) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        let ops = borrow_global<HeapOperations>(addr);
        (ops.insert)(s, value);
    }

    public entry fun execute_extract(s: &signer) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        let ops = borrow_global<HeapOperations>(addr);
        (ops.extract)(s);
    }
   
    #[view]
    public fun peek(addr: address): u64 {
        heap_operations::peek(addr)
    }

    #[view]
    public fun size(addr: address): u64 {
        heap_operations::size(addr)
    }

    #[view]
    public fun is_empty(addr: address): bool {
        heap_operations::is_empty(addr)
    }

    #[test(account = @heap)]
    public fun test_dynamic_heap_operations(account: &signer) 
        acquires HeapOperations 
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
        
        assert!(size(addr) == 2, 3);
        assert!(peek(addr) == 10, 4);
    }

    #[test(account = @heap)]
    public fun test_min_heap_operations(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module(account);
        execute_init_min_heap(account);
        
        let addr = signer::address_of(account);
        
        execute_insert(account, 10);
        execute_insert(account, 20);
        execute_insert(account, 5);
        
        assert!(peek(addr) == 5, 1);
        
        execute_extract(account);
        assert!(peek(addr) == 10, 2);
    }

    

    #[test(account = @heap)]
    public fun test_multiple_operations(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module(account);
        execute_init_max_heap(account);
        let addr = signer::address_of(account);
        
        execute_insert(account, 5);
        execute_insert(account, 10);
        assert!(peek(addr) == 10, 1);
        
        execute_extract(account);
        assert!(peek(addr) == 5, 2);
        
        execute_insert(account, 15);
        execute_insert(account, 3);
        assert!(peek(addr) == 15, 3);
    }

    #[test(account = @heap)]
    public fun test_empty_operations(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module(account);
        execute_init_max_heap(account);
        let addr = signer::address_of(account);
        
        assert!(is_empty(addr), 1);
        assert!(size(addr) == 0, 2);
        
        execute_insert(account, 42);
        assert!(!is_empty(addr), 3);
        assert!(size(addr) == 1, 4);
    }

    #[test(account = @heap)]
    public fun test_batch_operations(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module(account);
        execute_init_max_heap(account);
        let addr = signer::address_of(account);
        
        let i = 0;
        while (i < 10) {
            execute_insert(account, i);
            i = i + 1;
        };
        
        assert!(size(addr) == 10, 1);
        assert!(peek(addr) == 9, 2);
        
        execute_extract(account);
        execute_extract(account);
        execute_extract(account);
        
        assert!(size(addr) == 7, 3);
    }

    #[test(account = @heap)]
    public fun test_alternating_insert_extract(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module(account);
        execute_init_max_heap(account);
        let addr = signer::address_of(account);
        
        execute_insert(account, 10);
        execute_insert(account, 20);
        assert!(size(addr) == 2, 1);
        
        execute_extract(account);
        assert!(size(addr) == 1, 2);
        
        execute_insert(account, 30);
        execute_insert(account, 5);
        assert!(size(addr) == 3, 3);
        assert!(peek(addr) == 30, 4);
    }

    #[test(account = @heap)]
    public fun test_single_element(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module(account);
        execute_init_min_heap(account);
        let addr = signer::address_of(account);
        
        execute_insert(account, 42);
        
        assert!(peek(addr) == 42, 1);
        assert!(size(addr) == 1, 2);
        assert!(!is_empty(addr), 3);
        
        execute_extract(account);
        assert!(is_empty(addr), 4);
    }

    #[test(account = @heap)]
    public fun test_duplicate_values(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module(account);
        execute_init_max_heap(account);
        let addr = signer::address_of(account);
        
        execute_insert(account, 10);
        execute_insert(account, 10);
        execute_insert(account, 10);
        execute_insert(account, 5);
        
        assert!(size(addr) == 4, 1);
        assert!(peek(addr) == 10, 2);
        
        execute_extract(account);
        assert!(peek(addr) == 10, 3);
    }

    #[test(account = @heap)]
    #[expected_failure()]
    public fun test_double_init_fails(account: &signer) 
        acquires HeapOperations 
    {
        initialize_module(account);
        execute_init_max_heap(account);
        execute_init_max_heap(account);
    }

    #[test(account = @heap)]
    #[expected_failure(abort_code = 0x1, location = heap::heap)]
    public fun test_extract_empty_fails(account: &signer) 
        acquires HeapOperations 
    {
        initialize_module(account);
        execute_init_max_heap(account);
        execute_extract(account);
    }

    #[test(account = @heap)]
    #[expected_failure(abort_code = 0x2, location = heap::heap)]
    public fun test_peek_empty_fails(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module(account);
        execute_init_max_heap(account);
        let addr = signer::address_of(account);
        peek(addr);
    }

    #[test(account = @heap)]
    public fun test_function_value_persistence(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module(account);
        execute_init_max_heap(account);
        let addr = signer::address_of(account);
        
        // Call same function value multiple times
        execute_insert(account, 1);
        execute_insert(account, 2);
        execute_insert(account, 3);
        
        assert!(size(addr) == 3, 1);
        
        execute_extract(account);
        execute_extract(account);
        
        assert!(size(addr) == 1, 2);
    }

    #[test(account = @heap)]
    public fun test_large_heap(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module(account);
        execute_init_max_heap(account);
        let addr = signer::address_of(account);
        
        let i = 0;
        while (i < 50) {
            execute_insert(account, i);
            i = i + 1;
        };
        
        assert!(size(addr) == 50, 1);
        assert!(peek(addr) == 49, 2);
        
        let j = 0;
        while (j < 10) {
            execute_extract(account);
            j = j + 1;
        };
        
        assert!(size(addr) == 40, 3);
        assert!(peek(addr) == 39, 4);
    }
}