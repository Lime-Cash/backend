require "test_helper"

class Bank::WithdrawServiceTest < ActiveSupport::TestCase
  VALID_CBU = "1234567890123456789012"
  INVALID_CBU = "1111111111111111111111"

  def setup
    Transfer.delete_all
    Transaction.delete_all
    Account.delete_all
    User.delete_all

    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      password: "Password123!"
    )
    @account = Account.create!(
      user: @user,
      balance: 500.0
    )

    Bank::Api::Mock.valid_cbus = [ VALID_CBU ]
  end


  test "successful withdrawal decreases user account balance and creates transaction" do
    initial_balance = @account.balance
    amount = 50.0
    service = Bank::WithdrawService.new(cbu: VALID_CBU, user_id: @user.id, amount: amount)

    result = service.call

    assert result[:success]
    assert result[:transaction]
    assert result[:bank_response]

    @account.reload
    assert_equal initial_balance - amount, @account.balance

    transaction = result[:transaction]
    assert_equal(amount, transaction.amount)
    assert_equal @account, transaction.account
    assert transaction.date

    bank_response = result[:bank_response]
    assert bank_response["success"]
    assert_equal amount, bank_response["amount"]
    assert_equal VALID_CBU, bank_response["cbu"]
  end

  test "withdrawal with insufficient user funds returns error" do
    excessive_amount = @account.balance + 100.0
    service = Bank::WithdrawService.new(cbu: VALID_CBU, user_id: @user.id, amount: excessive_amount)

    result = service.call

    assert_not result[:success]
    assert result[:error]
    assert_includes result[:error], "Insufficient funds"
  end

  test "withdrawal with invalid CBU returns error" do
    service = Bank::WithdrawService.new(cbu: INVALID_CBU, user_id: @user.id, amount: 50.0)

    result = service.call

    assert_not result[:success]
    assert result[:error]
    assert_includes result[:error], "Invalid CBU"
  end

  test "withdrawal with invalid amount returns error" do
    service = Bank::WithdrawService.new(cbu: VALID_CBU, user_id: @user.id, amount: -50.0)

    result = service.call

    assert_not result[:success]
    assert_equal "Amount must be positive", result[:error]
  end

  test "withdrawal with zero amount returns error" do
    service = Bank::WithdrawService.new(cbu: VALID_CBU, user_id: @user.id, amount: 0)

    result = service.call

    assert_not result[:success]
    assert_equal "Amount must be positive", result[:error]
  end

  test "withdrawal with blank CBU returns error" do
    service = Bank::WithdrawService.new(cbu: "", user_id: @user.id, amount: 50.0)

    result = service.call

    assert_not result[:success]
    assert_equal "CBU cannot be blank", result[:error]
  end

  test "withdrawal with blank user_id returns error" do
    service = Bank::WithdrawService.new(cbu: VALID_CBU, user_id: "", amount: 50.0)

    result = service.call

    assert_not result[:success]
    assert_equal "User ID cannot be blank", result[:error]
  end

  test "withdrawal with non-existent user returns error" do
    non_existent_id = "99999999"
    service = Bank::WithdrawService.new(cbu: VALID_CBU, user_id: non_existent_id, amount: 50.0)

    result = service.call

    assert_not result[:success]
    assert_equal "User not found", result[:error]
  end

  test "withdrawal with user without account returns error" do
    @account.destroy
    service = Bank::WithdrawService.new(cbu: VALID_CBU, user_id: @user.id, amount: 50.0)

    result = service.call

    assert_not result[:success]
    assert_equal "User does not have an account", result[:error]
  end

  test "withdrawal maintains data consistency on bank API failure" do
    initial_balance = @account.balance
    initial_transaction_count = @account.transactions.count

    service = Bank::WithdrawService.new(cbu: INVALID_CBU, user_id: @user.id, amount: 50.0)
    result = service.call

    assert_not result[:success]

    @account.reload
    assert_equal initial_balance, @account.balance
    assert_equal initial_transaction_count, @account.transactions.count
  end

  test "withdrawal maintains data consistency on insufficient user funds" do
    initial_balance = @account.balance
    initial_transaction_count = @account.transactions.count
    excessive_amount = @account.balance + 100.0

    service = Bank::WithdrawService.new(cbu: VALID_CBU, user_id: @user.id, amount: excessive_amount)
    result = service.call

    assert_not result[:success]

    @account.reload
    assert_equal initial_balance, @account.balance
    assert_equal initial_transaction_count, @account.transactions.count
  end

  test "multiple successful withdrawals work correctly" do
    initial_balance = @account.balance
    amount1 = 50.0
    amount2 = 30.0

    service1 = Bank::WithdrawService.new(cbu: VALID_CBU, user_id: @user.id, amount: amount1)
    result1 = service1.call

    assert result1[:success]

    service2 = Bank::WithdrawService.new(cbu: VALID_CBU, user_id: @user.id, amount: amount2)
    result2 = service2.call

    assert result2[:success]

    @account.reload
    assert_equal initial_balance - amount1 - amount2, @account.balance

    assert_equal 2, @account.transactions.count
  end
end
