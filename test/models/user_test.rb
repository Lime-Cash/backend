require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with strong password" do
    user = User.new(email: "test@example.com", name: "Test User", password: "Password123!")
    assert user.valid?
  end

  test "requires email" do
    user = User.new(name: "Test User", password: "Password123!")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "email must be unique" do
    existing = users(:one)
    duplicate = User.new(email: existing.email, name: "Another User", password: "Password123!")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "has account association" do
    user = users(:one)
    assert_respond_to user, :account
  end

  test "authenticates with correct password" do
    user = User.create!(email: "new@example.com", name: "New User", password: "Password123!")
    assert user.authenticate("Password123!")
    assert_not user.authenticate("wrong")
  end

  test "email should be case insensitive" do
    existing = users(:one)
    duplicate = User.new(email: existing.email.to_s.upcase, name: "New User", password: "Password123!")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  # Password validation tests
  test "password must be at least 8 characters" do
    user = User.new(email: "test@example.com", name: "Test User", password: "Short1!")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "password must contain lowercase letter" do
    user = User.new(email: "test@example.com", name: "Test User", password: "PASSWORD123!")
    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one lowercase letter, one uppercase letter, one number, and one special character"
  end

  test "password must contain uppercase letter" do
    user = User.new(email: "test@example.com", name: "Test User", password: "password123!")
    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one lowercase letter, one uppercase letter, one number, and one special character"
  end

  test "password must contain number" do
    user = User.new(email: "test@example.com", name: "Test User", password: "Password!")
    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one lowercase letter, one uppercase letter, one number, and one special character"
  end

  test "password must contain special character" do
    user = User.new(email: "test@example.com", name: "Test User", password: "Password123")
    assert_not user.valid?
    assert_includes user.errors[:password], "must include at least one lowercase letter, one uppercase letter, one number, and one special character"
  end

  test "password validation only runs when password is present" do
    user = User.new(email: "test@example.com", name: "Test User")
    # Should not validate password complexity when it's not being set
    user.valid?
    # Password field should have presence error, but not complexity errors
    assert user.errors[:password].include?("can't be blank")
    assert_not user.errors[:password].any? { |error| error.include?("must include at least one") }
    assert_not user.errors[:password].any? { |error| error.include?("is too common") }
  end

  # Common password tests
  test "rejects common password 'password'" do
    user = User.new(email: "test@example.com", name: "Test User", password: "Password123!")
    user.password = "password"
    assert_not user.valid?
    assert_includes user.errors[:password], "is too common and has been found in data breaches"
  end

  test "rejects common password '123456'" do
    user = User.new(email: "test@example.com", name: "Test User", password: "123456")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too common and has been found in data breaches"
  end

  test "rejects common password 'password123'" do
    user = User.new(email: "test@example.com", name: "Test User", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too common and has been found in data breaches"
  end

  test "rejects common password 'admin'" do
    user = User.new(email: "test@example.com", name: "Test User", password: "admin")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too common and has been found in data breaches"
  end

  test "rejects common password 'qwerty'" do
    user = User.new(email: "test@example.com", name: "Test User", password: "qwerty")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too common and has been found in data breaches"
  end

  test "accepts strong unique password" do
    user = User.new(email: "test@example.com", name: "Test User", password: "MyStr0ng!Passw0rd")
    assert user.valid?
  end

  test "password validation is case insensitive for common passwords" do
    user = User.new(email: "test@example.com", name: "Test User", password: "PASSWORD")
    assert_not user.valid?
    assert_includes user.errors[:password], "is too common and has been found in data breaches"
  end

  test "accepts various special characters" do
    special_chars = ['@', '$', '!', '%', '*', '?', '&']
    
    special_chars.each do |char|
      user = User.new(email: "test#{char}@example.com", name: "Test User", password: "Password123#{char}")
      assert user.valid?, "Should accept password with special character: #{char}"
    end
  end
end
