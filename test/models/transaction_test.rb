require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "valid transaction" do
    transaction = Transaction.new(
      amount: 50.0,
      transaction_type: "deposit",
      external_service: "bank",
      date: Time.current,
      account: accounts(:one),
    )
    assert transaction.valid?
  end

  test "requires amount" do
    transaction = Transaction.new(
      date: Time.current,
      transaction_type: "deposit",
      external_service: "bank",
      account: accounts(:one),
    )
    assert_not transaction.valid?
  end

  test "requires account" do
    transaction = Transaction.new(
      amount: 50.0,
      transaction_type: "deposit",
      external_service: "bank",
      date: Time.current,
    )
    assert_not transaction.valid?
  end

  test "requires transaction type" do
    transaction = Transaction.new(
      amount: 50.0,
      external_service: "bank",
      date: Time.current,
    )

    assert_not transaction.valid?
  end

  test "requires external service" do
    transaction = Transaction.new(
      amount: 50.0,
      transaction_type: "deposit",
      date: Time.current,
    )

    assert_not transaction.valid?
  end

  test "has associations" do
    transaction = transactions(:one)
    assert_instance_of Account, transaction.account
  end
end
