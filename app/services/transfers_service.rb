class TransfersService
  def self.transfer(from:, to:, amount:)
    ActiveRecord::Base.transaction do
      from_account = Account.find(from)
      to_account = Account.find(to)

      if amount <= 0
        raise ActiveRecord::RecordInvalid.new(from_account), "Amount must be positive"
      end

      if from_account.balance < amount
        raise ActiveRecord::RecordInvalid.new(from_account), "Insufficient funds"
      end

      from_account.update!(balance: from_account.balance - amount)
      to_account.update!(balance: to_account.balance + amount)

      Transfer.create!(
        amount: amount,
        date: Time.current,
        from_account: from_account,
        to_account: to_account
      )
    end
  end
end
