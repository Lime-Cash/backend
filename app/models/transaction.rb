class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :external_method

  validates :amount, presence: true
end
