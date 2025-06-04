const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory accounts with CBU numbers
const accounts = {
  '1234567890123456789012': { cbu: '1234567890123456789012', balance: 1000.00, name: 'Account 1' },
  '2345678901234567890123': { cbu: '2345678901234567890123', balance: 2500.50, name: 'Account 2' },
  '3456789012345678901234': { cbu: '3456789012345678901234', balance: 500.75, name: 'Account 3' },
  '4567890123456789012345': { cbu: '4567890123456789012345', balance: 10000.00, name: 'Account 4' },
  '5678901234567890123456': { cbu: '5678901234567890123456', balance: 750.25, name: 'Account 5' }
};

// Validation helpers
const validateAmount = (amount) => {
  const numAmount = parseFloat(amount);
  if (!amount || isNaN(numAmount) || numAmount <= 0) {
    throw new Error('Invalid amount. Amount must be a positive number.');
  }
  return numAmount;
};

const validateCBU = (cbu) => {
  if (!cbu || typeof cbu !== 'string' || cbu.length !== 22) {
    throw new Error('Invalid CBU. CBU must be a 22-digit string.');
  }
  if (!accounts[cbu]) {
    throw new Error('Account not found for the provided CBU.');
  }
};

// POST /withdraw - Withdraw money from account
app.post('/withdraw', (req, res) => {
  try {
    const { cbu, amount: rawAmount } = req.body;

    // Validate inputs
    validateCBU(cbu);
    const amount = validateAmount(rawAmount);

    const account = accounts[cbu];

    // Check if sufficient funds
    if (account.balance < amount) {
      return res.status(400).json({
        success: false,
        error: `Insufficient funds`
      });
    }

    // Perform withdrawal
    account.balance -= amount;

    res.json({
      success: true,
      message: `Successfully withdrew $${amount.toFixed(2)} from account ${cbu}`,
      data: {
        cbu: account.cbu,
        newBalance: account.balance,
        withdrawnAmount: amount,
        transaction: {
          type: 'withdrawal',
          amount: amount,
          timestamp: new Date().toISOString()
        }
      }
    });

  } catch (error) {
    const statusCode = error.message.includes('not found') ? 404 : 400;
    res.status(statusCode).json({
      success: false,
      error: error.message
    });
  }
});

// POST /deposit - Deposit money to account
app.post('/deposit', (req, res) => {
  try {
    const { cbu, amount: rawAmount } = req.body;

    // Validate inputs
    validateCBU(cbu);
    const amount = validateAmount(rawAmount);

    const account = accounts[cbu];

    // Perform deposit
    account.balance += amount;

    res.json({
      success: true,
      message: `Successfully deposited $${amount.toFixed(2)} to account ${cbu}`,
      data: {
        cbu: account.cbu,
        newBalance: account.balance,
        depositedAmount: amount,
        transaction: {
          type: 'deposit',
          amount: amount,
          timestamp: new Date().toISOString()
        }
      }
    });

  } catch (error) {
    const statusCode = error.message.includes('not found') ? 404 : 400;
    res.status(statusCode).json({
      success: false,
      error: error.message
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found'
  });
});

app.listen(PORT, () => {
  console.log(`🏦 Fake Bank API running on port ${PORT}`);
  console.log('\n📋 Available accounts:');
  Object.values(accounts).forEach(account => {
    console.log(`  • ${account.name}: CBU ${account.cbu} - Balance: $${account.balance.toFixed(2)}`);
  });
  console.log('\n🔗 Available endpoints:');
  console.log('  • POST /withdraw');
  console.log('  • POST /deposit');
});
