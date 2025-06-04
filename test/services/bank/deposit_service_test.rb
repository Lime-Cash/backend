require "test_helper"
require "net/http"
require "uri"

class Bank::DepositServiceTest < ActiveSupport::TestCase
  # Valid CBU from bank API server
  VALID_CBU = "1234567890123456789012"
  INVALID_CBU = "1111111111111111111111"

  def setup
    # Clean up data
    Transfer.delete_all
    Transaction.delete_all
    Account.delete_all
    User.delete_all

    # Create test user and account
    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "Password123!"
    )
    @account = Account.create!(
      user: @user,
      balance: 100.0
    )

    # Ensure we're using the test bank API URL
    @original_bank_api_url = ENV["BANK_API_URL"]
    ENV["BANK_API_URL"] = "http://localhost:3001"

    # Verify bank API is accessible
    begin
      Net::HTTP.get_response(URI("http://localhost:3001"))
    rescue Errno::ECONNREFUSED
      skip "Bank API server is not running on localhost:3001. Please start it with: cd bank-api && npm start"
    end
  end

  def teardown
    ENV["BANK_API_URL"] = @original_bank_api_url
  end

  test "successful deposit increases user account balance and creates transaction" do
    initial_balance = @account.balance
    amount = 50.0
    service = Bank::DepositService.new(cbu: VALID_CBU, user_id: @user.id, amount: amount)

    # Record initial bank account balance for verification
    initial_bank_response = Bank::BankApi.deposit(cbu: VALID_CBU, amount: 1.0)
    Bank::BankApi.withdraw(cbu: VALID_CBU, amount: 1.0) # Reset the 1.0 test deposit

    result = service.call

    assert result[:success]
    assert result[:transaction]
    assert result[:bank_response]

    # Verify user account balance increased
    @account.reload
    assert_equal initial_balance + amount, @account.balance

    # Verify transaction was created
    transaction = result[:transaction]
    assert_equal amount, transaction.amount
    assert_equal @account, transaction.account
    assert transaction.date

    # Verify bank API was called and money was withdrawn from bank account
    bank_response = result[:bank_response]
    assert bank_response["success"]
    assert_equal "withdrawal", bank_response["data"]["transaction"]["type"]
    assert_equal amount, bank_response["data"]["withdrawnAmount"]
  end

  test "deposit with invalid CBU returns error" do
    service = Bank::DepositService.new(cbu: INVALID_CBU, user_id: @user.id, amount: 50.0)

    result = service.call

    assert_not result[:success]
    assert result[:error]
    assert_includes result[:error], "not found"
  end

  test "deposit with invalid amount returns error" do
    service = Bank::DepositService.new(cbu: VALID_CBU, user_id: @user.id, amount: -50.0)

    result = service.call

    assert_not result[:success]
    assert_equal "Amount must be positive", result[:error]
  end

  test "deposit with zero amount returns error" do
    service = Bank::DepositService.new(cbu: VALID_CBU, user_id: @user.id, amount: 0)

    result = service.call

    assert_not result[:success]
    assert_equal "Amount must be positive", result[:error]
  end

  test "deposit with blank CBU returns error" do
    service = Bank::DepositService.new(cbu: "", user_id: @user.id, amount: 50.0)

    result = service.call

    assert_not result[:success]
    assert_equal "CBU cannot be blank", result[:error]
  end

  test "deposit with blank user_id returns error" do
    service = Bank::DepositService.new(cbu: VALID_CBU, user_id: "", amount: 50.0)

    result = service.call

    assert_not result[:success]
    assert_equal "User ID cannot be blank", result[:error]
  end

  test "deposit with non-existent user returns error" do
    non_existent_id = "99999999"
    service = Bank::DepositService.new(cbu: VALID_CBU, user_id: non_existent_id, amount: 50.0)

    result = service.call

    assert_not result[:success]
    assert_equal "User not found", result[:error]
  end

  test "deposit with user without account returns error" do
    @account.destroy
    service = Bank::DepositService.new(cbu: VALID_CBU, user_id: @user.id, amount: 50.0)

    result = service.call

    assert_not result[:success]
    assert_equal "User does not have an account", result[:error]
  end

  test "deposit maintains data consistency on bank API failure" do
    initial_balance = @account.balance
    initial_transaction_count = @account.transactions.count

    # Use invalid CBU to force bank API error
    service = Bank::DepositService.new(cbu: INVALID_CBU, user_id: @user.id, amount: 50.0)
    result = service.call

    # Ensure the operation failed
    assert_not result[:success]

    # Ensure no changes were made to the user account
    @account.reload
    assert_equal initial_balance, @account.balance
    assert_equal initial_transaction_count, @account.transactions.count
  end

  test "deposit with insufficient bank funds returns error" do
    # Use account with lower balance and try to withdraw a large amount
    low_balance_cbu = "3456789012345678901234" # Account 3 has 500.75 balance
    excessive_amount = 10000.0

    service = Bank::DepositService.new(cbu: low_balance_cbu, user_id: @user.id, amount: excessive_amount)
    result = service.call

    assert_not result[:success]
    assert result[:error]
    assert_includes result[:error], "Insufficient funds"
  end
end
