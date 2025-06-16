require_relative "api/base"
require_relative "api/real"
require_relative "api/mock"

module Bank
  class BankClient
    class << self
      attr_writer :implementation

      def implementation
        @implementation ||= if Rails.env.test?
          Bank::Api::Mock
        else
          Bank::Api::Real
        end
      end

      def deposit(cbu:, amount:)
        implementation.deposit(cbu: cbu, amount: amount)
      end

      def withdraw(cbu:, amount:)
        implementation.withdraw(cbu: cbu, amount: amount)
      end
    end
  end
end
