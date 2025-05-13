class AccountService
  def self.get_balance(account_id)
    account = Account.find(account_id)
    account.balance
  end
end
