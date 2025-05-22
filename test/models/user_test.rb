require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(email: "test@example.com", name: "Test User", password: "password123")
    assert user.valid?
  end

  test "requires email" do
    user = User.new(name: "Test User", password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "email must be unique" do
    existing = users(:one)
    duplicate = User.new(email: existing.email, name: "Another User", password: "password123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "has account association" do
    user = users(:one)
    assert_respond_to user, :account
  end

  test "authenticates with correct password" do
    user = User.create(email: "new@example.com", name: "New User", password: "password123")
    assert user.authenticate("password123")
    assert_not user.authenticate("wrong")
  end

  test "email should be case insensitive" do
    existing = users(:one)
    duplicate = User.new(email: existing.email.to_s.upcase,  name: "New User", password: "password123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end
end
