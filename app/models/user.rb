class User < ApplicationRecord
  has_secure_password
  has_one :account

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  # Strong password validation
  validates :password, length: { minimum: 8 }, if: :password_required?
  validates :password, format: {
    with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+\z/,
    message: "must include at least one lowercase letter, one uppercase letter, one number, and one special character"
  }, if: :password_required?

  # Check against common breached passwords
  validate :password_not_breached, if: :password_required?

  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def password_required?
    password.present?
  end

  def password_not_breached
    return unless password.present?

    common_passwords = [
      "password", "123456", "password123", "admin", "qwerty",
      "letmein", "welcome", "monkey", "1234567890", "password1"
    ]

    if common_passwords.include?(password.downcase)
      errors.add(:password, "is too common and has been found in data breaches")
    end
  end
end
