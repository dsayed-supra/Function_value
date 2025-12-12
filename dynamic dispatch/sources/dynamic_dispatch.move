module demo::calculator {

    use std::signer;

    struct Calculator has key {
        add_fn: |u64, u64|u64 has store+copy,
        mul_fn: |u64, u64|u64  has store+copy,
    }

    struct CalcResult has key{
        value: u64,
    }

    /// Publish calculator under signer
    public fun initilize_module(
        s: &signer,
        add_fn: |u64, u64|u64 has  store+copy,
        mul_fn: |u64, u64|u64 has  store+copy,
    ) {
        move_to(s, Calculator { add_fn, mul_fn });
        move_to(s, CalcResult { value: 0 });
    }

    /// Use stored add function
    public entry fun compute_add(s: &signer, x: u64, y: u64) acquires Calculator,CalcResult {
        let addr = signer::address_of(s);
        
        let Calculator{add_fn, mul_fn} = move_from<Calculator>(addr);
        
        // Call the function - it will be copied since it has copy ability
        let val = add_fn(x, y);
        
        
        move_to(s, Calculator { add_fn, mul_fn });
        let result_ref = borrow_global_mut<CalcResult>(addr);
        result_ref.value = val;
        
    }
    
    #[view]
    public fun get_result(addr: address): u64 acquires CalcResult {
        let result = borrow_global<CalcResult>(addr);
        result.value
    }
    /// Use stored multiply function
    public entry fun compute_mul(s: &signer, x: u64, y: u64) acquires Calculator,CalcResult {
        let addr = signer::address_of(s);
        let Calculator{add_fn, mul_fn} = move_from<Calculator>(addr);
        
        // Call the function - it will be copied since it has copy ability
        let val = mul_fn(x, y);
        move_to(s, Calculator { add_fn, mul_fn });
        let result_ref = borrow_global_mut<CalcResult>(addr);
        result_ref.value = val;

    }

}