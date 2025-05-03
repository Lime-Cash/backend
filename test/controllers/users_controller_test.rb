require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should register a new user" do
    assert_difference("User.count") do
      post register_url, params: {
        name: "Test User",
        email: "testuser@mail.com",
        password: "password",
        password_confirmation: "password"
      }
    end

    assert_response :created
    assert_not_nil response.parsed_body["token"]
    assert_equal 1, User.where(email: "testuser@mail.com").count
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
        email: existing_user.email,
        password: "password123",
        password_confirmation: "password123"
      }
    end

    assert_response :unprocessable_entity
  end
end
