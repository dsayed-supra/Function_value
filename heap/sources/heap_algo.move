module heap::algorithms {
    use heap::heap::{Self, Heap};
    use std::vector;

    /// Heap sort
    public fun heap_sort(data: vector<u64>, ascending: bool): vector<u64> {
        let comparator = if (ascending) {
            heap::min_comparator  // Use persistent function
        } else {
            heap::max_comparator  // Use persistent function
        };
        
        let heap = heap::heapify(data, comparator);
        heap::to_sorted_vector(heap)
    }

    /// Find k largest elements
    public fun find_k_largest(data: &vector<u64>, k: u64): vector<u64> {
        assert!(k > 0, 1);
        let heap = heap::new_min_heap();
        let i = 0;
        let len = vector::length(data);
        
        while (i < len) {
            let val = *vector::borrow(data, i);
            if (heap::size(&heap) < k) {
                heap::insert(&mut heap, val);
            } else {
                let min = heap::peek(&heap);
                if (val > min) {
                    heap::extract(&mut heap);
                    heap::insert(&mut heap, val);
                }
            };
            i = i + 1;
        };
        
        heap::to_sorted_vector(heap)
    }

    #[test]
    public fun test_heap_sort() {
        let data = vector[5, 2, 8, 1, 9, 3];
        
        let asc = heap_sort(data, true);
        assert!(*vector::borrow(&asc, 0) == 1, 1);
        assert!(*vector::borrow(&asc, 5) == 9, 2);
        
        let desc = heap_sort(data, false);
        assert!(*vector::borrow(&desc, 0) == 9, 3);
        assert!(*vector::borrow(&desc, 5) == 1, 4);
    }

    #[test]
    public fun test_k_largest() {
        let data = vector[5, 2, 8, 1, 9, 3, 7];
        let largest = find_k_largest(&data, 3);
        assert!(vector::length(&largest) == 3, 1);
    }
}