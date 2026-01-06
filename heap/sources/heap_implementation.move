module heap::heap {
    use std::vector;

    /// Heap structure with function value comparator
    struct Heap<T: store + drop + copy> has store, drop, copy {
        data: vector<T>,
        comparator: |T, T|bool has store + copy + drop,
    }


    /// Max heap comparator: a > b
    #[persistent]
    public fun max_comparator<T: store + drop + copy>(a: T, b: T): bool {
        a > b
    }

    /// Min heap comparator: a < b
    #[persistent]
    public fun min_comparator<T: store + drop + copy>(a: T, b: T): bool {
        a < b
    }

    /// Reverse comparator for testing
    #[persistent]
    public fun reverse_comparator<T: store + drop + copy>(a: T, b: T): bool {
        b > a
    }

    public fun new<T: store + drop + copy>(
        comparator: |T, T|bool has store + copy + drop,
    ): Heap<T> {
        Heap {
            data: vector::empty<T>(),
            comparator,
        }
    }


    public fun new_max_heap<T: store + drop + copy>(): Heap<T> {
        Heap {
            data: vector::empty<T>(),
            comparator: max_comparator,  // Reference to persistent function
        }
    }

    public fun new_min_heap<T: store + drop + copy>(): Heap<T> {
        Heap {
            data: vector::empty<T>(),
            comparator: min_comparator,  // Reference to persistent function
        }
    }

   
    public fun insert<T: store + drop + copy>(heap: &mut Heap<T>, value: T) {
        vector::push_back(&mut heap.data, value);
        let index = vector::length(&heap.data) - 1;
        bubble_up(heap, index);
    }

    public fun extract<T: store + drop + copy>(heap: &mut Heap<T>): T {
        let len = vector::length(&heap.data);
        assert!(len > 0, 1); // ERROR_EMPTY_HEAP
        
        if (len == 1) {
            return vector::pop_back(&mut heap.data)
        };

        let result = *vector::borrow(&heap.data, 0);
        let last = vector::pop_back(&mut heap.data);
        *vector::borrow_mut(&mut heap.data, 0) = last;
        bubble_down(heap, 0);
        result
    }

    public fun peek<T: store + drop + copy>(heap: &Heap<T>): T {
        assert!(!is_empty(heap), 2); 
        *vector::borrow(&heap.data, 0)
    }

    /// Check if heap is empty
    public fun is_empty<T: store + drop + copy>(heap: &Heap<T>): bool {
        vector::length(&heap.data) == 0
    }

    /// Get heap size
    public fun size<T: store + drop + copy>(heap: &Heap<T>): u64 {
        vector::length(&heap.data)
    }

    // ============================================
    // INTERNAL HELPER FUNCTIONS
    // ============================================

    fun bubble_up<T: store + drop + copy>(heap: &mut Heap<T>, index: u64) {
        if (index == 0) return;
        
        let parent_index = (index - 1) / 2;
        let current = *vector::borrow(&heap.data, index);
        let parent = *vector::borrow(&heap.data, parent_index);
        
        if ((heap.comparator)(current, parent)) {
            *vector::borrow_mut(&mut heap.data, index) = parent;
            *vector::borrow_mut(&mut heap.data, parent_index) = current;
            bubble_up(heap, parent_index);
        }
    }

    fun bubble_down<T: store + drop + copy>(heap: &mut Heap<T>, index: u64) {
        let len = vector::length(&heap.data);
        let left_child = 2 * index + 1;
        let right_child = 2 * index + 2;
        
        if (left_child >= len) return;
        
        let current = *vector::borrow(&heap.data, index);
        let left = *vector::borrow(&heap.data, left_child);
        
        let swap_index = left_child;
        let swap_value = left;
        
        if (right_child < len) {
            let right = *vector::borrow(&heap.data, right_child);
            if ((heap.comparator)(right, left)) {
                swap_index = right_child;
                swap_value = right;
            }
        };
        
        if ((heap.comparator)(swap_value, current)) {
            *vector::borrow_mut(&mut heap.data, index) = swap_value;
            *vector::borrow_mut(&mut heap.data, swap_index) = current;
            bubble_down(heap, swap_index);
        }
    }


    /// Create heap from existing vector
    public fun heapify<T: store + drop + copy>(
        data: vector<T>,
        comparator: |T, T|bool has store + copy + drop,
    ): Heap<T> {
        let heap = Heap { data, comparator };
        let len = vector::length(&heap.data);
        if (len <= 1) return heap;
        
        let i = (len / 2);
        while (i > 0) {
            i = i - 1;
            bubble_down(&mut heap, i);
        };
        heap
    }

    /// Convert heap to sorted vector
    public fun to_sorted_vector<T: store + drop + copy>(heap: Heap<T>): vector<T> {
        let result = vector::empty<T>();
        while (!is_empty(&heap)) {
            vector::push_back(&mut result, extract(&mut heap));
        };
        result
    }

   
   
    #[test]
    public fun test_max_heap() {
        let heap = new_max_heap();
        
        insert(&mut heap, 5);
        insert(&mut heap, 3);
        insert(&mut heap, 8);
        insert(&mut heap, 1);
        insert(&mut heap, 10);
        
        assert!(peek(&heap) == 10, 1);
        assert!(extract(&mut heap) == 10, 2);
        assert!(extract(&mut heap) == 8, 3);
        assert!(extract(&mut heap) == 5, 4);
        assert!(extract(&mut heap) == 3, 5);
        assert!(extract(&mut heap) == 1, 6);
        assert!(is_empty(&heap), 7);
    }

    #[test]
    public fun test_min_heap() {
        let heap = new_min_heap();
        
        insert(&mut heap, 5);
        insert(&mut heap, 3);
        insert(&mut heap, 8);
        insert(&mut heap, 1);
        insert(&mut heap, 10);
        
        assert!(peek(&heap) == 1, 1);
        assert!(extract(&mut heap) == 1, 2);
        assert!(extract(&mut heap) == 3, 3);
        assert!(extract(&mut heap) == 5, 4);
        assert!(extract(&mut heap) == 8, 5);
        assert!(extract(&mut heap) == 10, 6);
    }

    #[test]
    public fun test_heapify() {
        let data = vector[5, 3, 8, 1, 10, 2];
        let heap = heapify(data, max_comparator);
        
        assert!(extract(&mut heap) == 10, 1);
        assert!(extract(&mut heap) == 8, 2);
        assert!(extract(&mut heap) == 5, 3);
    }

    #[test]
    public fun test_custom_persistent_comparator() {
        
        let heap = Heap {
            data: vector::empty<u64>(),
            comparator: reverse_comparator,
        };
        
        insert(&mut heap, 5);
        insert(&mut heap, 3);
        insert(&mut heap, 8);
        
        // Should behave like min heap
        assert!(extract(&mut heap) == 3, 1);
    }

    #[test]
    public fun test_size_and_empty() {
        let heap = new_max_heap();
        assert!(is_empty(&heap), 1);
        assert!(size(&heap) == 0, 2);
        
        insert(&mut heap, 10);
        assert!(!is_empty(&heap), 3);
        assert!(size(&heap) == 1, 4);
        
        insert(&mut heap, 20);
        assert!(size(&heap) == 2, 5);
        
        extract(&mut heap);
        assert!(size(&heap) == 1, 6);
        
        extract(&mut heap);
        assert!(is_empty(&heap), 7);
    }

}