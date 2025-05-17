class ExternalMethod < ApplicationRecord
  has_and_belongs_to_many :accounts
  has_many :transactions

  # Add validations
  validates :name, presence: true
end
