require "test_helper"

class ExternalMethodTest < ActiveSupport::TestCase
  test "valid external method" do
    method = ExternalMethod.new(name: "Credit Card", description: "Visa/Mastercard")
    assert method.valid?
  end

  test "requires name" do
    method = ExternalMethod.new(description: "Payment description")
    assert_not method.valid?
  end

  test "has accounts association" do
    method = external_methods(:one)
    assert_respond_to method, :accounts
  end
end