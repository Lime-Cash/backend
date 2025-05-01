require "test_helper"

class TransferTest < ActiveSupport::TestCase
  test "valid transfer" do
    transfer = Transfer.new(
      amount: 25.0,
      date: Time.current,
      from_account: accounts(:one),
      to_account: accounts(:two)
    )
    assert transfer.valid?
  end

  test "requires amount" do
    transfer = Transfer.new(
      date: Time.current,
      from_account: accounts(:one),
      to_account: accounts(:two)
    )
    assert_not transfer.valid?
  end

  test "requires from_account" do
    transfer = Transfer.new(
      amount: 25.0,
      date: Time.current,
      to_account: accounts(:two)
    )
    assert_not transfer.valid?
  end

  test "requires to_account" do
    transfer = Transfer.new(
      amount: 25.0,
      date: Time.current,
      from_account: accounts(:one)
    )
    assert_not transfer.valid?
  end

  test "has account associations" do
    transfer = transfers(:one)
    assert_instance_of Account, transfer.from_account
    assert_instance_of Account, transfer.to_account
  end
end
