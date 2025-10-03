module payment_addr::payment_system {
    use std::signer;
    use std::string::String;
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::event;
    use aptos_framework::timestamp;

    // ======================== Structs ========================

    struct PaymentRequest has key, store {
        recipient: address,
        amount: u64,
        token_type: String,
        fulfilled: bool,
        created_at: u64,
    }

    struct PaymentHistory has key {
        requests: vector<PaymentRequest>,
        next_id: u64,
    }

    #[event]
    struct PaymentSentEvent has drop, store {
        sender: address,
        recipient: address,
        amount: u64,
        timestamp: u64,
    }

    #[event]
    struct PaymentRequestCreatedEvent has drop, store {
        request_id: u64,
        recipient: address,
        amount: u64,
        creator: address,
        timestamp: u64,
    }

    #[event]
    struct PaymentRequestFulfilledEvent has drop, store {
        request_id: u64,
        fulfiller: address,
        timestamp: u64,
    }

    // ======================== Errors ========================

    const E_NOT_INITIALIZED: u64 = 1;
    const E_ALREADY_FULFILLED: u64 = 2;
    const E_INVALID_AMOUNT: u64 = 3;
    const E_INVALID_REQUEST_ID: u64 = 4;

    // ======================== Init Functions ========================

    fun init_module(sender: &signer) {
        move_to(sender, PaymentHistory {
            requests: vector::empty(),
            next_id: 0,
        });
    }

    // ======================== Write Functions ========================

    public entry fun send_payment(
        sender: &signer,
        recipient: address,
        amount: u64,
    ) {
        assert!(amount > 0, E_INVALID_AMOUNT);
        
        let payment = coin::withdraw<AptosCoin>(sender, amount);
        coin::deposit(recipient, payment);

        event::emit(PaymentSentEvent {
            sender: signer::address_of(sender),
            recipient,
            amount,
            timestamp: timestamp::now_seconds(),
        });
    }

    public entry fun create_payment_request(
        sender: &signer,
        recipient: address,
        amount: u64,
        token_type: String,
    ) acquires PaymentHistory {
        assert!(amount > 0, E_INVALID_AMOUNT);
        
        let sender_addr = signer::address_of(sender);
        
        if (!exists<PaymentHistory>(sender_addr)) {
            move_to(sender, PaymentHistory {
                requests: vector::empty(),
                next_id: 0,
            });
        };

        let history = borrow_global_mut<PaymentHistory>(sender_addr);
        let request_id = history.next_id;
        
        let request = PaymentRequest {
            recipient,
            amount,
            token_type,
            fulfilled: false,
            created_at: timestamp::now_seconds(),
        };

        vector::push_back(&mut history.requests, request);
        history.next_id = history.next_id + 1;

        event::emit(PaymentRequestCreatedEvent {
            request_id,
            recipient,
            amount,
            creator: sender_addr,
            timestamp: timestamp::now_seconds(),
        });
    }

    public entry fun fulfill_payment_request(
        sender: &signer,
        request_owner: address,
        request_id: u64,
    ) acquires PaymentHistory {
        assert!(exists<PaymentHistory>(request_owner), E_NOT_INITIALIZED);
        
        let history = borrow_global_mut<PaymentHistory>(request_owner);
        assert!(request_id < vector::length(&history.requests), E_INVALID_REQUEST_ID);
        
        let request = vector::borrow_mut(&mut history.requests, request_id);
        assert!(!request.fulfilled, E_ALREADY_FULFILLED);

        let payment = coin::withdraw<AptosCoin>(sender, request.amount);
        coin::deposit(request.recipient, payment);
        
        request.fulfilled = true;

        event::emit(PaymentRequestFulfilledEvent {
            request_id,
            fulfiller: signer::address_of(sender),
            timestamp: timestamp::now_seconds(),
        });
    }

    // ======================== View Functions ========================

    #[view]
    public fun get_payment_request(owner: address, request_id: u64): (address, u64, String, bool, u64) acquires PaymentHistory {
        assert!(exists<PaymentHistory>(owner), E_NOT_INITIALIZED);
        
        let history = borrow_global<PaymentHistory>(owner);
        assert!(request_id < vector::length(&history.requests), E_INVALID_REQUEST_ID);
        
        let request = vector::borrow(&history.requests, request_id);
        (request.recipient, request.amount, request.token_type, request.fulfilled, request.created_at)
    }

    #[view]
    public fun get_request_count(owner: address): u64 acquires PaymentHistory {
        if (!exists<PaymentHistory>(owner)) {
            return 0
        };
        let history = borrow_global<PaymentHistory>(owner);
        vector::length(&history.requests)
    }

    #[view]
    public fun has_payment_history(addr: address): bool {
        exists<PaymentHistory>(addr)
    }

    // ======================== Test Only ========================

    #[test_only]
    public fun init_module_for_test(sender: &signer) {
        init_module(sender);
    }
}
