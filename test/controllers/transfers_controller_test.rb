require "test_helper"

class TransfersControllerTest < ActionDispatch::IntegrationTest
  def auth_headers(user)
    secret = Rails.application.credentials.secret_key_base
    token = JWT.encode({ user_id: user.id }, secret)
    {
      "Authorization" => "Bearer #{token}",
      "Content-Type" => "application/json"
    }
  end

  def setup
    @sender = users(:one)
    @recipient = users(:two)
  end

  test "successful transfer returns 201 and updates balances" do
    headers = auth_headers(@sender)

    post transfers_url,
         params: { email: @recipient.email, amount: 50 },
         headers: headers,
         as: :json

    assert_response :created

    assert_equal @sender.account.reload.balance, 50.0
    assert_equal @recipient.account.reload.balance, 250.0
  end

  test "fails if recipient not found" do
    headers = auth_headers(@sender)

    post transfers_url,
         params: { email: "noexiste@example.com", amount: 10 },
         headers: headers,
         as: :json

    assert_response :not_found
    assert_includes JSON.parse(response.body)["error"], "Recipient not found"
  end

  test "fails with invalid (negative) amount" do
    headers = auth_headers(@sender)

    post transfers_url,
         params: { email: @recipient.email, amount: -10 },
         headers: headers,
         as: :json

    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)["error"], "Amount must be positive"
  end

  test "fails with missing params" do
    headers = auth_headers(@sender)

    post transfers_url,
         params: { amount: 10 }, # falta email
         headers: headers,
         as: :json

    assert_response :not_found
  end

  test "fails with insufficient funds" do
    headers = auth_headers(@sender)

    post transfers_url,
         params: { email: @recipient.email, amount: 5000 },
         headers: headers,
         as: :json

    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)["error"], "Insufficient"
  end

  test "fails if no auth token" do
    post transfers_url,
         params: { email: @recipient.email, amount: 50 },
         as: :json

    assert_response :unauthorized
    assert_includes JSON.parse(response.body)["error"], "Nil JSON web token"
  end

  test "cant send money to same user" do
    headers = auth_headers(@sender)

    post transfer_url,
      params: { email: @sender.email, amount: 50 },
      headers: headers,
      as: :json

    assert_response :bad_request
    assert_includes JSON.parse(response.body)["error"], "yourself"
  end
end
