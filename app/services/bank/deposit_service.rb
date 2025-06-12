module Bank
  class DepositService
    attr_reader :cbu, :user_id, :amount

    def initialize(cbu:, user_id:, amount:)
      @cbu = cbu
      @user_id = user_id
      @amount = amount
    end

    def call
      validate_inputs!

      user = find_user!
      account = user.account || raise(StandardError, "User does not have an account")

      bank_response = BankApi.withdraw(cbu: cbu, amount: amount)

      account.deposit(amount)
      account.save!

      transaction = account.transactions.create!(
        amount: amount,
        transaction_type: "deposit",
        external_service: "bank",
        date: Time.current
      )

      {
        success: true,
        transaction: transaction,
        bank_response: bank_response
      }
    rescue StandardError => e
      {
        success: false,
        error: e.message
      }
    end

    private

    def validate_inputs!
      raise ArgumentError, "CBU cannot be blank" if cbu.blank?
      raise ArgumentError, "User ID cannot be blank" if user_id.blank?
      raise ArgumentError, "Amount must be positive" unless amount.positive?
    end

    def find_user!
      User.find(user_id)
    rescue ActiveRecord::RecordNotFound
      raise StandardError, "User not found"
    end
  end
end
