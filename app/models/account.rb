class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions
  has_many :outgoing_transfers, class_name: "Transfer", foreign_key: "from_account_id"
  has_many :incoming_transfers, class_name: "Transfer", foreign_key: "to_account_id"
  has_and_belongs_to_many :external_methods

  validates :balance, presence: true, numericality: { greater_than_or_equal: 0 }
  validates :user_id, uniqueness: true

  def deposit(amount)
    raise ArgumentError, "Amount must be positive" unless amount.positive?

    self.balance += amount
  end

  def withdraw(amount)
    raise ArgumentError, "Amount must be positive" unless amount.positive?
    raise StandardError, "Insufficient funds" if amount > balance

    self.balance -= amount
  end
end
