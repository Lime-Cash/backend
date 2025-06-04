require "test_helper"

class AccountServiceTest < ActiveSupport::TestCase
  setup do
    Transfer.delete_all
    Transaction.delete_all
    Account.delete_all
    User.delete_all

    @user = User.create!(
      name: "Usuario One",
      email: "one@example.com",
      password: "flJlfall123!"
    )
    @account = Account.create!(
      user: @user,
      balance: 100.0
    )

    @other_user = User.create!(
      name: "Usuario Two",
      email: "two@example.com",
      password: "ffasdlfLKJ324l!@"
    )
    @other_account = Account.create!(
      user: @other_user,
      balance: 50.0
    )

    @outgoing_transfer = Transfer.create!(
      from_account: @account,
      to_account: @other_account,
      amount: 50.0
    )

    @incoming_transfer = Transfer.create!(
      from_account: @other_account,
      to_account: @account,
      amount: 25.0
    )
  end

  test "get_activity returns combined and sorted activity" do
    activity = AccountService.get_activity(@user)

    assert_equal 2, activity.size

    types = activity.map { |item| item[:type] }
    assert_includes types, "transfer_sent"
    assert_includes types, "transfer_received"

    outgoing_item = activity.find { |i| i[:type] == "transfer_sent" }
    assert_equal @outgoing_transfer.id, outgoing_item[:id]
    assert_equal @other_account.user.email, outgoing_item[:to_account]

    incoming_item = activity.find { |i| i[:type] == "transfer_received" }
    assert_equal @incoming_transfer.id, incoming_item[:id]
    assert_equal @other_account.user.email, incoming_item[:from_account]

    sorted = activity.sort_by { |i| i[:created_at] }.reverse
    assert_equal sorted, activity
  end
end
