class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions
  has_many :outgoing_transfers, class_name: 'Transfer', foreign_key: 'from_account_id'
  has_many :incoming_transfers, class_name: 'Transfer', foreign_key: 'to_account_id'
  has_and_belongs_to_many :external_methods

  validates :balance, presence: true, numericality: true
  validates :user_id, uniqueness: true
end
