require "test_helper"

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    # Ensure password is set for fixture user
    @user.update(password: "password123", password_confirmation: "password123")
  end

  test "should login with valid credentials" do
    post login_url, params: { email: @user.email, password: "password123" }

    assert_response :success
    assert_not_nil JSON.parse(@response.body)["token"]
  end

  test "should not login with invalid password" do
    post login_url, params: { email: @user.email, password: "wrongpassword" }

    assert_response :unauthorized
  end

  test "should not login with invalid email" do
    post login_url, params: { email: "nonexistent@example.com", password: "password123" }

    assert_response :unauthorized
  end
end
