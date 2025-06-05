class AccountService
  def self.get_balance_by_user(user)
    account = user.account
    raise ActiveRecord::RecordNotFound, "Account not found for user" unless account

    account.balance
  end

  def self.get_activity(user)
    account = user.account
    raise ActiveRecord::RecordNotFound, "Account not found for user" unless account

    transactions = account.transactions.map do |t|
      {
        type: "transaction",
        id: t.id,
        amount: t.amount,
        transaction_type: t.transaction_type,
        external_service: t.external_service,
        created_at: t.created_at
      }
    end

    outgoing = account.outgoing_transfers.map do |t|
      {
        type: "transfer_sent",
        id: t.id,
        amount: t.amount,
        to_account: t.to_account&.user&.email,
        created_at: t.created_at
      }
    end

    incoming = account.incoming_transfers.map do |t|
      {
        type: "transfer_received",
        id: t.id,
        amount: t.amount,
        from_account: t.from_account&.user&.email,
        created_at: t.created_at
      }
    end

    (transactions + outgoing + incoming).sort_by { |t|  t[:created_at] }.reverse
  end
end
