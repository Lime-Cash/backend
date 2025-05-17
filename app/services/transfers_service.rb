class TransfersService
  def self.transfer(from:, to:, amount:)
  raise ArgumentError, "Amount must be positive" unless amount.positive?

    ActiveRecord::Base.transaction do
      from_account = Account.find(from)
      to_account = Account.find(to)

      from_account.withdraw(amount)
      to_account.deposit(amount)

      from_account.save!
      to_account.save!

      Transfer.create!(
        amount: amount,
        date: Time.current,
        from_account: from_account,
        to_account: to_account
      )
    end
  end
end
