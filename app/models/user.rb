class User < ApplicationRecord
  has_secure_password
  has_one :account

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
