module heap::heap_storage {
    use std::signer;
    use heap::heap_operations;

    
    // FUNCTION VALUE STORAGE
    struct HeapOperations<T: store + drop + copy> has key {
        initialize_max_heap: |&signer| has store + copy,
        initialize_min_heap: |&signer| has store + copy,
        insert: |&signer, T| has store + copy,
        extract: |&signer| has store + copy,
    }


    public entry fun initialize_module<T: store + drop + copy>(account: &signer) {

        let init_max_fn = |s: &signer| heap_operations::init_max_heap<T>(s);
        let init_min_fn = |s: &signer| heap_operations::init_min_heap<T>(s);
        let insert_fn = |s: &signer, v: T| heap_operations::insert<T>(s, v);
        let extract_fn = |s: &signer| heap_operations::extract<T>(s);

        let function_store = HeapOperations {
            initialize_max_heap: init_max_fn,
            initialize_min_heap: init_min_fn,
            insert: insert_fn,
            extract: extract_fn,
        };

        move_to(account, function_store);
    }

  
    // DYNAMIC OPERATION EXECUTION
    public entry fun execute_init_max_heap<T: store + drop + copy>(s: &signer) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        let ops = borrow_global<HeapOperations<T>>(addr);
        (ops.initialize_max_heap)(s);
    }

    public entry fun execute_init_min_heap<T: store + drop + copy>(s: &signer) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        let ops = borrow_global<HeapOperations<T>>(addr);
        (ops.initialize_min_heap)(s);
    }

    public entry fun execute_insert<T: store + drop + copy>(s: &signer, value: T) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        let ops = borrow_global<HeapOperations<T>>(addr);
        (ops.insert)(s, value);
    }

    public entry fun execute_extract<T: store + drop + copy>(s: &signer) 
        acquires HeapOperations 
    {
        let addr = signer::address_of(s);
        let ops = borrow_global<HeapOperations<T>>(addr);
        (ops.extract)(s);
    }
   
    #[view]
    public fun peek<T: store + drop + copy>(addr: address): T {
        heap_operations::peek(addr)
    }

    #[view]
    public fun size<T: store + drop + copy>(addr: address): u64 {
        heap_operations::size<T>(addr)
    }

    #[view]
    public fun is_empty<T: store + drop + copy>(addr: address): bool {
        heap_operations::is_empty<T>(addr)
    }

    #[test(account = @heap)]
    public fun test_dynamic_heap_operations(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
       
        initialize_module<u128>(account);
        execute_init_max_heap<u128>(account);
        
        let addr = signer::address_of(account);
        
        execute_insert<u128>(account, 10);
        execute_insert<u128>(account, 20);
        execute_insert<u128>(account, 5);
        
        assert!(peek<u128>(addr) == 20, 1);
        assert!(size<u128>(addr) == 3, 2);
        
        execute_extract<u128>(account);
        
        assert!(size<u128>(addr) == 2, 3);
        assert!(peek<u128>(addr) == 10, 4);
    }

    #[test(account = @heap)]
    public fun test_min_heap_operations(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module<u64>(account);
        execute_init_min_heap<u64>(account);
        
        let addr = signer::address_of(account);
        
        execute_insert<u64>(account, 10);
        execute_insert<u64>(account, 20);
        execute_insert<u64>(account, 5);
        
        assert!(peek<u64>(addr) == 5, 1);
        execute_extract<u64>(account);
        assert!(peek<u64>(addr) == 10, 2);
    }

    

    #[test(account = @heap)]
    public fun test_multiple_operations(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module<u64>(account);
        execute_init_max_heap<u64>(account);
        let addr = signer::address_of(account);
        
        execute_insert<u64>(account, 5);
        execute_insert<u64>(account, 10);
        assert!(peek<u64>(addr) == 10, 1);

        execute_extract<u64>(account);
        assert!(peek<u64>(addr) == 5, 2);
        
        execute_insert<u64>(account, 15);
        execute_insert<u64>(account, 3);
        assert!(peek<u64>(addr) == 15, 3);
    }

    #[test(account = @heap)]
    public fun test_empty_operations(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module<u64>(account);
        execute_init_max_heap<u64>(account);
        let addr = signer::address_of(account);
        
        assert!(is_empty<u64>(addr), 1);
        assert!(size<u64>(addr) == 0, 2);
        
        execute_insert<u64>(account, 42);
        assert!(!is_empty<u64>(addr), 3);
        assert!(size<u64>(addr) == 1, 4);
    }

    #[test(account = @heap)]
    public fun test_batch_operations(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module<u64>(account);
        execute_init_max_heap<u64>(account);
        let addr = signer::address_of(account);
        
        let i = 0;
        while (i < 10) {
            execute_insert<u64>(account, i);
            i = i + 1;
        };
        
        assert!(size<u64>(addr) == 10, 1);
        assert!(peek<u64>(addr) == 9, 2);
        
        execute_extract<u64>(account);
        execute_extract<u64>(account);
        execute_extract<u64>(account);
        
        assert!(size<u64>(addr) == 7, 3);
    }

    #[test(account = @heap)]
    public fun test_alternating_insert_extract(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module<u64>(account);
        execute_init_max_heap<u64>(account);
        let addr = signer::address_of(account);
        
        execute_insert<u64>(account, 10);
        execute_insert<u64>(account, 20);
        assert!(size<u64>(addr) == 2, 1);

        execute_extract<u64>(account);
        assert!(size<u64>(addr) == 1, 2);
        
        execute_insert<u64>(account, 30);
        execute_insert<u64>(account, 5);
        assert!(size<u64>(addr) == 3, 3);
        assert!(peek<u64>(addr) == 30, 4);
    }

    #[test(account = @heap)]
    public fun test_single_elemen(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module<u64>(account);
        execute_init_min_heap<u64>(account);
        let addr = signer::address_of(account);
        
        execute_insert<u64>(account, 42);
        
        assert!(peek<u64>(addr) == 42, 1);
        assert!(size<u64>(addr) == 1, 2);
        assert!(!is_empty<u64>(addr), 3);
        
        execute_extract<u64>(account);
        assert!(is_empty<u64>(addr), 4);
    }

    #[test(account = @heap)]
    public fun test_duplicate_values(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module<u64>(account);
        execute_init_max_heap<u64>(account);
        let addr = signer::address_of(account);
        
        execute_insert<u64>(account, 10);
        execute_insert<u64>(account, 10);
        execute_insert<u64>(account, 10);
        execute_insert<u64>(account, 5);
        
        assert!(size<u64>(addr) == 4, 1);
        assert!(peek<u64>(addr) == 10, 2);
        
        execute_extract<u64>(account);
        assert!(peek<u64>(addr) == 10, 3);
    }

    #[test(account = @heap)]
    #[expected_failure()]
    public fun test_double_init_fails(account: &signer) 
        acquires HeapOperations 
    {
        initialize_module<u64>(account);
        execute_init_max_heap<u64>(account);
        execute_init_max_heap<u64>(account);
    }

    #[test(account = @heap)]
    #[expected_failure(abort_code = 0x1, location = heap::heap)]
    public fun test_extract_empty_fails(account: &signer) 
        acquires HeapOperations 
    {
        initialize_module<u64>(account);
        execute_init_max_heap<u64>(account);
        execute_extract<u64>(account);
    }

    #[test(account = @heap)]
    #[expected_failure(abort_code = 0x2, location = heap::heap)]
    public fun test_peek_empty_fails(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module<u64>(account);
        execute_init_max_heap<u64>(account);
        let addr = signer::address_of(account);
        peek<u64>(addr);
    }

    #[test(account = @heap)]
    public fun test_function_value_persistence(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module<u64>(account);
        execute_init_max_heap<u64>(account);
        let addr = signer::address_of(account);
        
        // Call same function value multiple times
        execute_insert<u64>(account, 1);
        execute_insert<u64>(account, 2);
        execute_insert<u64>(account, 3);
        
        assert!(size<u64>(addr) == 3, 1);
        
        execute_extract<u64>(account);
        execute_extract<u64>(account);
        
        assert!(size<u64>(addr) == 1, 2);
    }

    #[test(account = @heap)]
    public fun test_large_heap(account: &signer) 
        acquires HeapOperations 
    {
        use std::signer;
        
        initialize_module<u64>(account);
        execute_init_max_heap<u64>(account);
        let addr = signer::address_of(account);
        
        let i = 0;
        while (i < 50) {
            execute_insert<u64>(account, i);
            i = i + 1;
        };
        
        assert!(size<u64>(addr) == 50, 1);
        assert!(peek<u64>(addr) == 49, 2);
        
        let j = 0;
        while (j < 10) {
            execute_extract<u64>(account);
            j = j + 1;
        };
        
        assert!(size<u64>(addr) == 40, 3);
        assert!(peek<u64>(addr) == 39, 4);
    }
}