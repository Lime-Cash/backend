require "test_helper"

class Bank::DepositServiceTest < ActiveSupport::TestCase
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
      balance: 100.0
    )

    Bank::Api::Mock.valid_cbus = [ VALID_CBU ]
  end

  test "successful deposit increases user account balance and creates transaction" do
    initial_balance = @account.balance
    amount = 50.0
    service = Bank::DepositService.new(cbu: VALID_CBU, user_id: @user.id, amount: amount)

    result = service.call

    assert result[:success]
    assert result[:transaction]
    assert result[:bank_response]

    @account.reload
    assert_equal initial_balance + amount, @account.balance

    transaction = result[:transaction]
    assert_equal amount, transaction.amount
    assert_equal @account, transaction.account
    assert transaction.date

    bank_response = result[:bank_response]
    assert bank_response["success"]
    assert_equal amount, bank_response["amount"]
    assert_equal VALID_CBU, bank_response["cbu"]
  end

  test "deposit with invalid CBU returns error" do
    service = Bank::DepositService.new(cbu: INVALID_CBU, user_id: @user.id, amount: 50.0)

    result = service.call

    assert_not result[:success]
    assert result[:error]
    assert_includes result[:error], "Invalid CBU"
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

    service = Bank::DepositService.new(cbu: INVALID_CBU, user_id: @user.id, amount: 50.0)
    result = service.call

    assert_not result[:success]

    @account.reload
    assert_equal initial_balance, @account.balance
    assert_equal initial_transaction_count, @account.transactions.count
  end

  test "deposit with insufficient bank funds returns error" do
    excessive_amount = 1500.0

    service = Bank::DepositService.new(cbu: VALID_CBU, user_id: @user.id, amount: excessive_amount)
    result = service.call

    assert_not result[:success]
    assert result[:error]
    assert_includes result[:error], "Insufficient funds"
  end
end
