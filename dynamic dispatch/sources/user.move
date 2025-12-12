module demo::user {

    use demo::calculator;

    // Function for addition
    #[persistent]
    public fun add_fn(x: u64, y: u64): u64 {
        x + y
    }

    // Function for multiplication
    #[persistent]
    public fun mul_fn(x: u64, y: u64) : u64 {
        x * y
    }

    public entry fun main(account: &signer) {
        // Create function values that wrap the user module functions
        let add_fn = |x: u64, y: u64| add_fn(x, y);
        let mul_fn = |x: u64, y: u64| mul_fn(x, y);
        
        // Call init_module_a with the function values
        calculator::initilize_module(account, add_fn, mul_fn);
    }
}