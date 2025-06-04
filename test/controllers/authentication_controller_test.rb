require "test_helper"

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    # Ensure password is set for fixture user with strong password
    @user.update(password: "Password123!", password_confirmation: "Password123!")
  end

  test "should login with valid credentials" do
    post login_url, params: { email: @user.email, password: "Password123!" }

    assert_response :success
    assert_not_nil JSON.parse(@response.body)["token"]
  end

  test "should not login with invalid password" do
    post login_url, params: { email: @user.email, password: "wrongpassword" }

    assert_response :unauthorized
  end

  test "should not login with invalid email" do
    post login_url, params: { email: "nonexistent@example.com", password: "Password123!" }

    assert_response :unauthorized
  end

  test "should not login with blank email" do
    post login_url, params: { email: "", password: "Password123!" }

    assert_response :unauthorized
    response_body = JSON.parse(@response.body)
    assert_equal "Invalid email or password", response_body["error"]
  end

  test "should not login with blank password" do
    post login_url, params: { email: @user.email, password: "" }

    assert_response :unauthorized
    response_body = JSON.parse(@response.body)
    assert_equal "Invalid email or password", response_body["error"]
  end

  test "should handle email case insensitivity" do
    post login_url, params: { email: @user.email.upcase, password: "Password123!" }

    assert_response :success
    assert_not_nil JSON.parse(@response.body)["token"]
  end
end
