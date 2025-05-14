class AccountService


  def self.get_balance_by_user(user)
    account = user.account
    raise ActiveRecord::RecordNotFound, "Account not found for user" unless account
    account.balance
  end
end
