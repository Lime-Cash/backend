require "test_helper"

class TransactionTest < ActiveSupport::TestCase
  test "valid transaction" do
    transaction = Transaction.new(
      amount: 50.0,
      date: Time.current,
      account: accounts(:one),
      external_method: external_methods(:one)
    )
    assert transaction.valid?
  end

  test "requires amount" do
    transaction = Transaction.new(
      date: Time.current,
      account: accounts(:one),
      external_method: external_methods(:one)
    )
    assert_not transaction.valid?
  end

  test "requires account" do
    transaction = Transaction.new(
      amount: 50.0,
      date: Time.current,
      external_method: external_methods(:one)
    )
    assert_not transaction.valid?
  end

  test "has associations" do
    transaction = transactions(:one)
    assert_instance_of Account, transaction.account
    assert_instance_of ExternalMethod, transaction.external_method
  end
end