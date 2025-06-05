class Transaction < ApplicationRecord
  belongs_to :account, class_name: "Account"

  validates :amount, presence: true
  validates :transaction_type, presence: true
  validates :external_service, presence: true
end
