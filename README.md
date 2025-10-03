# Aptos Payment System Contract

Production-ready Move smart contract for decentralized payments on Aptos blockchain.

## Features

- ✅ Direct APT payments between addresses
- ✅ Payment request creation and fulfillment
- ✅ Event emissions for tracking
- ✅ View functions for querying payment data
- ✅ Payment history management

## Prerequisites

1. Install Aptos CLI:
```bash
curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3
```

2. Verify installation:
```bash
aptos --version
```

## Quick Start

### 1. Deploy to Testnet

```bash
cd ignore1/contracts_lancerpay
./scripts/deploy.sh testnet
```

### 2. Deploy to Mainnet

```bash
./scripts/deploy.sh mainnet
```

### 3. Configure Your App

After deployment, copy the module address and update your `.env`:

```env
NEXT_PUBLIC_INTEGRATION_APTOS=true
NEXT_PUBLIC_APTOS_NETWORK=testnet
NEXT_PUBLIC_APTOS_MODULE_ADDRESS=0xYOUR_MODULE_ADDRESS_HERE
```

## Contract Functions

### Entry Functions (Write)

1. **send_payment**
   - Direct APT payment to recipient
   - Args: `recipient: address, amount: u64`

2. **create_payment_request**
   - Create a payment request
   - Args: `recipient: address, amount: u64, token_type: String`

3. **fulfill_payment_request**
   - Fulfill an existing payment request
   - Args: `request_owner: address, request_id: u64`

### View Functions (Read)

1. **get_payment_request**
   - Get details of a payment request
   - Args: `owner: address, request_id: u64`
   - Returns: `(address, u64, String, bool, u64)`

2. **get_request_count**
   - Get total number of requests for an address
   - Args: `owner: address`
   - Returns: `u64`

3. **has_payment_history**
   - Check if address has payment history
   - Args: `addr: address`
   - Returns: `bool`

## Testing

Run contract tests:

```bash
cd contract
aptos move test
```

## Development

### Compile Only

```bash
cd contract
aptos move compile
```

### Local Testing

```bash
aptos move test --coverage
```

## Available Move Commands (npm scripts in main app)

- `npm run move:publish` - Publish Move contracts
- `npm run move:test` - Run Move unit tests
- `npm run move:compile` - Compile Move contracts
- `npm run move:upgrade` - Upgrade Move contracts

## Architecture

```
contract/
├── Move.toml                    # Package configuration
├── sources/
│   └── payment_system.move      # Main payment contract
└── tests/                       # Contract tests
```

## Events

The contract emits the following events:

- `PaymentSentEvent` - When a payment is sent
- `PaymentRequestCreatedEvent` - When a payment request is created
- `PaymentRequestFulfilledEvent` - When a request is fulfilled

## Security Considerations

- All amounts are validated (must be > 0)
- Payment requests can only be fulfilled once
- Request IDs are validated before access
- Proper error handling with descriptive error codes

## Error Codes

- `E_NOT_INITIALIZED = 1` - Payment history not initialized
- `E_ALREADY_FULFILLED = 2` - Payment request already fulfilled
- `E_INVALID_AMOUNT = 3` - Amount must be greater than 0
- `E_INVALID_REQUEST_ID = 4` - Request ID does not exist

## Support

For issues or questions, please refer to the main repository documentation.
