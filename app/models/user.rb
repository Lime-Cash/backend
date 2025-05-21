class User < ApplicationRecord
  has_secure_password
  has_one :account

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
