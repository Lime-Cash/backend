# Fake Bank API

A simplified mock banking API with only withdraw and deposit operations.

## Setup

1. Navigate to the fake-bank-api directory:
```bash
cd bank-api
```

2. Install dependencies:
```bash
npm install
```

3. Start the server:
```bash
npm start
```

The API will run on `http://localhost:3001`

## Available Accounts

| Account Name | CBU                    | Initial Balance |
|-------------|------------------------|----------------|
| Account 1   | 1234567890123456789012 | $1,000.00      |
| Account 2   | 2345678901234567890123 | $2,500.50      |
| Account 3   | 3456789012345678901234 | $500.75        |
| Account 4   | 4567890123456789012345 | $10,000.00     |
| Account 5   | 5678901234567890123456 | $750.25        |

## API Endpoints

### POST /withdraw
Withdraw money from an account.

**Request Body:**
```json
{
  "cbu": "1234567890123456789012",
  "amount": 100.50
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Successfully withdrew $100.50 from account 1234567890123456789012",
  "data": {
    "cbu": "1234567890123456789012",
    "newBalance": 899.50,
    "withdrawnAmount": 100.50,
    "transaction": {
      "type": "withdrawal",
      "amount": 100.50,
      "timestamp": "2024-01-01T12:00:00.000Z"
    }
  }
}
```

### POST /deposit
Deposit money to an account.

**Request Body:**
```json
{
  "cbu": "1234567890123456789012",
  "amount": 500.00
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Successfully deposited $500.00 to account 1234567890123456789012",
  "data": {
    "cbu": "1234567890123456789012",
    "newBalance": 1399.50,
    "depositedAmount": 500.00,
    "transaction": {
      "type": "deposit",
      "amount": 500.00,
      "timestamp": "2024-01-01T12:00:00.000Z"
    }
  }
}
```

## Error Handling

- **Invalid CBU**: 400/404 status with error message
- **Invalid Amount**: 400 status (negative, zero, or non-numeric amounts)
- **Insufficient Funds**: 400 status with current balance information
- **Account Not Found**: 404 status

## Testing with curl

```bash
# Withdraw money
curl -X POST http://localhost:3001/withdraw \
  -H "Content-Type: application/json" \
  -d '{"cbu": "1234567890123456789012", "amount": 100}'

# Deposit money
curl -X POST http://localhost:3001/deposit \
  -H "Content-Type: application/json" \
  -d '{"cbu": "1234567890123456789012", "amount": 200}'
```
```

```.gitignore:fake-bank-api/.gitignore
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
```

Perfect! I've simplified the fake bank API as requested:

## 🏦 **Updated Features:**

### **Removed:**
- ❌ Random error simulation (`simulateRandomError()`)
- ❌ `/health` endpoint
- ❌ `/accounts` endpoint  
- ❌ `/accounts/:cbu` endpoint

### **Kept:**
- ✅ `POST /withdraw` - Withdraw money from account
- ✅ `POST /deposit` - Deposit money to account
- ✅ All validation (CBU format, amount validation, insufficient funds)
- ✅ Proper error handling for real issues
- ✅ 5 in-memory accounts with CBU numbers

The API is now focused exclusively on the core banking operations you need for testing transfers, without any unnecessary endpoints or artificial error simulation.