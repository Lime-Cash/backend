require "test_helper"

class TransfersServiceTest < ActiveSupport::TestCase
  setup do
    Transfer.delete_all
  end

  test "successfully transfers money between accounts" do
    from_account = accounts(:one)
    to_account = accounts(:two)
    initial_from_balance = from_account.balance
    initial_to_balance = to_account.balance
    amount = 50.0

    TransfersService.transfer(from: from_account.id, to: to_account.id, amount: amount)

    from_account.reload
    to_account.reload

    assert_equal initial_from_balance - amount, from_account.balance
    assert_equal initial_to_balance + amount, to_account.balance
    assert_equal 1, Transfer.where(from_account: from_account, to_account: to_account, amount: amount).count
  end

  test "raises error when from account has insufficient funds" do
    from_account = accounts(:one)
    to_account = accounts(:two)
    amount = from_account.balance + 1

    assert_raises(ActiveRecord::RecordInvalid) do
      TransfersService.transfer(from: from_account.id, to: to_account.id, amount: amount)
    end
  end

  test "raises error when account is not found" do
    assert_raises(ActiveRecord::RecordNotFound) do
      TransfersService.transfer(from: "non_existent", to: "non_existent", amount: 50.0)
    end
  end

  test "maintains data consistency when error occurs" do
    from_account = accounts(:one)
    to_account = accounts(:two)
    initial_from_balance = from_account.balance
    initial_to_balance = to_account.balance
    amount = 50.0

    # Simulate an error by making the amount negative
    assert_raises(ActiveRecord::RecordInvalid) do
      TransfersService.transfer(from: from_account.id, to: to_account.id, amount: -amount)
    end

    from_account.reload
    to_account.reload

    assert_equal initial_from_balance, from_account.balance
    assert_equal initial_to_balance, to_account.balance
    assert_equal 0, Transfer.where(from_account: from_account, to_account: to_account).count
  end
end
