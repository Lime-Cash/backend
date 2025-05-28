require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    # Ensure password is set for fixture user with strong password
    @user.update(password: "Password123!", password_confirmation: "Password123!")
  end

  test "should register a new user with strong password" do
    assert_difference("User.count") do
      post register_url, params: {
        name: "Test User",
        email: "testuser@mail.com",
        password: "Password123!",
        password_confirmation: "Password123!"
      }
    end

    assert_response :created
    assert_not_nil response.parsed_body["token"]
    assert_equal 1, User.where(email: "testuser@mail.com").count
  end

  test "should not register with weak password" do
    assert_no_difference("User.count") do
      post register_url, params: {
        name: "Test User",
        email: "testuser@mail.com",
        password: "weak"
      }
    end

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_includes response_body["error"], "Password is too short (minimum is 8 characters)"
  end

  test "should not register with password missing uppercase" do
    assert_no_difference("User.count") do
      post register_url, params: {
        name: "Test User",
        email: "testuser@mail.com",
        password: "password123!"
      }
    end

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_includes response_body["error"].join(" "), "must include at least one lowercase letter, one uppercase letter, one number, and one special character"
  end

  test "should not register with password missing lowercase" do
    assert_no_difference("User.count") do
      post register_url, params: {
        name: "Test User",
        email: "testuser@mail.com",
        password: "PASSWORD123!"
      }
    end

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_includes response_body["error"].join(" "), "must include at least one lowercase letter, one uppercase letter, one number, and one special character"
  end

  test "should not register with password missing number" do
    assert_no_difference("User.count") do
      post register_url, params: {
        name: "Test User",
        email: "testuser@mail.com",
        password: "Password!"
      }
    end

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_includes response_body["error"].join(" "), "must include at least one lowercase letter, one uppercase letter, one number, and one special character"
  end

  test "should not register with password missing special character" do
    assert_no_difference("User.count") do
      post register_url, params: {
        name: "Test User",
        email: "testuser@mail.com",
        password: "Password123"
      }
    end

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_includes response_body["error"].join(" "), "must include at least one lowercase letter, one uppercase letter, one number, and one special character"
  end

  test "should not register with common password" do
    assert_no_difference("User.count") do
      post register_url, params: {
        name: "Test User",
        email: "testuser@mail.com",
        password: "password123"
      }
    end

    assert_response :unprocessable_entity
    response_body = JSON.parse(@response.body)
    assert_includes response_body["error"].join(" "), "is too common and has been found in data breaches"
  end

  test "should not register with invalid data" do
    assert_no_difference("User.count") do
      post register_url, params: {
        email: "invalid",
        password: "short"
      }
    end

    assert_response :unprocessable_entity
  end

  test "should not register duplicate email" do
    existing_user = users(:one)

    assert_no_difference("User.count") do
      post register_url, params: {
        name: "Test User",
        email: existing_user.email,
        password: "Password123!",
        password_confirmation: "Password123!"
      }
    end

    assert_response :unprocessable_entity
  end

  test "should login with valid credentials" do
    post login_url, params: { email: @user.email, password: "Password123!" }

    assert_response :success
    assert_not_nil JSON.parse(@response.body)["token"]
  end
end
