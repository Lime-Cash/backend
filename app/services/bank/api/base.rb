module Bank
  module Api
    class Base
      def self.deposit(cbu:, amount:)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def self.withdraw(cbu:, amount:)
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
end
