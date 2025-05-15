require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "valid account" do
    user = User.create!(name: "Test User", email: "test@example.com", password: "password")
    account = Account.new(user: user, balance: 100.0)
    assert account.valid?
  end

  test "requires balance" do
    account = Account.new(user: users(:one))
    assert_not account.valid?
    assert_includes account.errors[:balance], "can't be blank"
  end

  test "balance must be numeric" do
    account = Account.new(user: users(:one), balance: "abc")
    assert_not account.valid?
    assert_includes account.errors[:balance], "is not a number"
  end

  test "balance cant be negative" do
    account = Account.new(user: users(:one), balance: -5.0)
    assert_not account.valid?
  end

  test "deposit money should add balance" do
    account = Account.new(user: users(:one), balance: 0)
    account.deposit(10)
    assert_equal account.balance, 10
  end

  test "deposit negative amount should raise an exception" do
    account = Account.new(user: users(:one), balance: 0)
    assert_raises(ArgumentError) do
      account.deposit(-10)
    end
  end

  test "withdraw money should subtract balance" do
    account = Account.new(user: users(:one), balance: 10)
    account.withdraw(5)
    assert_equal account.balance, 5
  end

  test "withdraw negative amount should raise an exception" do
    account = Account.new(user: users(:one), balance: 10)
    assert_raises(ArgumentError) do
      account.withdraw(-10)
    end
  end

  test "cant withdraw more than current balance" do
    account = Account.new(user: users(:one), balance: 10)
    assert_raises(StandardError) do
      account.withdraw(20)
    end
  end

  test "user can only have one account" do
    existing = accounts(:one)
    duplicate = Account.new(user: existing.user, balance: 50.0)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "has associations" do
    account = accounts(:one)
    assert_respond_to account, :transactions
    assert_respond_to account, :outgoing_transfers
    assert_respond_to account, :incoming_transfers
    assert_respond_to account, :external_methods
  end
end
