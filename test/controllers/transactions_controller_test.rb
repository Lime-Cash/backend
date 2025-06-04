require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update(password: "Password123!", password_confirmation: "Password123!")
    @account = accounts(:one)

    # Generate JWT token for authentication
    payload = { user_id: @user.id }
    @token = JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
    @auth_headers = { "Authorization" => "Bearer #{@token}" }
  end

  # Authentication tests
  test "should require authentication for deposit_bank" do
    post deposit_bank_url, params: { cbu: "1234567890123456789012", amount: 100.0 }

    assert_response :unauthorized
  end

  test "should require authentication for withdraw_bank" do
    post withdraw_bank_url, params: { cbu: "1234567890123456789012", amount: 100.0 }

    assert_response :unauthorized
  end

  test "should reject invalid JWT token for deposit_bank" do
    invalid_headers = { "Authorization" => "Bearer invalid_token" }

    post deposit_bank_url,
         params: { cbu: "1234567890123456789012", amount: 100.0 },
         headers: invalid_headers

    assert_response :unauthorized
  end

  test "should reject invalid JWT token for withdraw_bank" do
    invalid_headers = { "Authorization" => "Bearer invalid_token" }

    post withdraw_bank_url,
         params: { cbu: "1234567890123456789012", amount: 100.0 },
         headers: invalid_headers

    assert_response :unauthorized
  end

  # deposit_bank tests
  test "should successfully process bank deposit" do
    initial_balance = @account.balance

    post deposit_bank_url,
         params: { cbu: "1234567890123456789012", amount: 100.0 },
         headers: @auth_headers

    assert_response :success
    response_body = JSON.parse(@response.body)
    assert response_body["success"]
    assert_not_nil response_body["transaction"]
    assert_not_nil response_body["bank_response"]
    assert_equal "100.0", response_body["transaction"]["amount"]

    # Verify account balance was updated using real service logic
    @account.reload
    assert_equal initial_balance + 100.0, @account.balance
  end

  test "should handle deposit with blank CBU" do
    post deposit_bank_url,
         params: { cbu: "", amount: 100.0 },
         headers: @auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "CBU cannot be blank", response_body["error"]
  end

  test "should handle deposit with nil CBU" do
    post deposit_bank_url,
         params: { amount: 100.0 },
         headers: @auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "CBU cannot be blank", response_body["error"]
  end

  test "should handle deposit with negative amount" do
    post deposit_bank_url,
         params: { cbu: "1234567890123456789012", amount: -100.0 },
         headers: @auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "Amount must be positive", response_body["error"]
  end

  test "should handle deposit with zero amount" do
    post deposit_bank_url,
         params: { cbu: "1234567890123456789012", amount: 0 },
         headers: @auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "Amount must be positive", response_body["error"]
  end

  test "should handle deposit with missing amount parameter" do
    post deposit_bank_url,
         params: { cbu: "1234567890123456789012" },
         headers: @auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "Amount must be positive", response_body["error"]
  end

  test "should convert string amount to float for deposit" do
    initial_balance = @account.balance

    post deposit_bank_url,
         params: { cbu: "1234567890123456789012", amount: "150.50" },
         headers: @auth_headers

    assert_response :success
    response_body = JSON.parse(@response.body)
    assert response_body["success"]
    assert_equal "150.5", response_body["transaction"]["amount"]

    # Verify real service logic updated the balance correctly
    @account.reload
    assert_equal initial_balance + 150.5, @account.balance
  end

  test "should handle deposit when user not found" do
    # Create invalid token with non-existent user ID
    invalid_payload = { user_id: 99999 }
    invalid_token = JWT.encode(invalid_payload, Rails.application.credentials.secret_key_base, "HS256")
    invalid_auth_headers = { "Authorization" => "Bearer #{invalid_token}" }

    post deposit_bank_url,
         params: { cbu: "1234567890123456789012", amount: 100.0 },
         headers: invalid_auth_headers

    assert_response :unauthorized
  end

  # withdraw_bank tests
  test "should successfully process bank withdrawal" do
    # Set account balance to have enough funds
    @account.update(balance: 200.0)
    initial_balance = @account.balance

    post withdraw_bank_url,
         params: { cbu: "1234567890123456789012", amount: 50.0 },
         headers: @auth_headers

    assert_response :success
    response_body = JSON.parse(@response.body)
    assert response_body["success"]
    assert_not_nil response_body["transaction"]
    assert_not_nil response_body["bank_response"]
    assert_equal "-50.0", response_body["transaction"]["amount"]

    # Verify account balance was updated using real service logic
    @account.reload
    assert_equal initial_balance - 50.0, @account.balance
  end

  test "should handle withdrawal with insufficient balance" do
    # Set account balance lower than withdrawal amount
    @account.update(balance: 10.0)

    post withdraw_bank_url,
         params: { cbu: "1234567890123456789012", amount: 50.0 },
         headers: @auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "Insufficient funds", response_body["error"]
  end

  test "should handle withdrawal with blank CBU" do
    post withdraw_bank_url,
         params: { cbu: "", amount: 50.0 },
         headers: @auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "CBU cannot be blank", response_body["error"]
  end

  test "should handle withdrawal with nil CBU" do
    post withdraw_bank_url,
         params: { amount: 50.0 },
         headers: @auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "CBU cannot be blank", response_body["error"]
  end

  test "should handle withdrawal with negative amount" do
    post withdraw_bank_url,
         params: { cbu: "1234567890123456789012", amount: -50.0 },
         headers: @auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "Amount must be positive", response_body["error"]
  end

  test "should handle withdrawal with zero amount" do
    post withdraw_bank_url,
         params: { cbu: "1234567890123456789012", amount: 0 },
         headers: @auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "Amount must be positive", response_body["error"]
  end

  test "should handle withdrawal with missing amount parameter" do
    post withdraw_bank_url,
         params: { cbu: "1234567890123456789012" },
         headers: @auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "Amount must be positive", response_body["error"]
  end

  test "should convert string amount to float for withdrawal" do
    @account.update(balance: 200.0)
    initial_balance = @account.balance

    post withdraw_bank_url,
         params: { cbu: "1234567890123456789012", amount: "75.25" },
         headers: @auth_headers

    assert_response :success
    response_body = JSON.parse(@response.body)
    assert response_body["success"]
    assert_equal "-75.25", response_body["transaction"]["amount"]

    # Verify real service logic updated the balance correctly
    @account.reload
    assert_equal initial_balance - 75.25, @account.balance
  end

  test "should handle withdrawal when user not found" do
    # Create invalid token with non-existent user ID
    invalid_payload = { user_id: 99999 }
    invalid_token = JWT.encode(invalid_payload, Rails.application.credentials.secret_key_base, "HS256")
    invalid_auth_headers = { "Authorization" => "Bearer #{invalid_token}" }

    post withdraw_bank_url,
         params: { cbu: "1234567890123456789012", amount: 50.0 },
         headers: invalid_auth_headers

    assert_response :unauthorized
  end

  # Edge cases and error handling
  test "should handle deposit when account does not exist" do
    # Create a user without an account
    user_without_account = User.create!(
      email: "noaccountuser@example.com",
      name: "No Account User",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    payload = { user_id: user_without_account.id }
    token = JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
    auth_headers = { "Authorization" => "Bearer #{token}" }

    post deposit_bank_url,
         params: { cbu: "1234567890123456789012", amount: 100.0 },
         headers: auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "User does not have an account", response_body["error"]
  end

  test "should handle withdrawal when account does not exist" do
    # Create a user without an account
    user_without_account = User.create!(
      email: "noaccountuser2@example.com",
      name: "No Account User 2",
      password: "Password123!",
      password_confirmation: "Password123!"
    )

    payload = { user_id: user_without_account.id }
    token = JWT.encode(payload, Rails.application.credentials.secret_key_base, "HS256")
    auth_headers = { "Authorization" => "Bearer #{token}" }

    post withdraw_bank_url,
         params: { cbu: "1234567890123456789012", amount: 50.0 },
         headers: auth_headers

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_not response_body["success"]
    assert_equal "User does not have an account", response_body["error"]
  end

  private

  def assert_response_one_of(expected_responses)
    assert_includes expected_responses, @response.status.to_s.to_sym
  end
end
