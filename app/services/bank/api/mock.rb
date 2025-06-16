module Bank
  module Api
    class Mock < Base
      class << self
        attr_accessor :valid_cbus, :balances, :calls

        def reset!
          @valid_cbus = [ "1234567890123456789012" ]
          @balances = {}
          @calls = { deposit: [], withdraw: [] }
        end

        def deposit(cbu:, amount:)
          calls[:deposit] << { cbu: cbu, amount: amount }

          unless valid_cbus.include?(cbu)
            raise BankApiError, "Invalid CBU"
          end

          unless amount.positive?
            raise BankApiError, "Amount must be positive"
          end

          @balances[cbu] ||= 0
          @balances[cbu] += amount

          { "success" => true, "cbu" => cbu, "amount" => amount, "balance" => @balances[cbu] }
        end

        def withdraw(cbu:, amount:)
          calls[:withdraw] << { cbu: cbu, amount: amount }

          unless valid_cbus.include?(cbu)
            raise BankApiError, "Invalid CBU"
          end

          unless amount.positive?
            raise BankApiError, "Amount must be positive"
          end

          @balances[cbu] ||= 1000

          if @balances[cbu] < amount
            raise BankApiError, "Insufficient funds"
          end

          @balances[cbu] -= amount

          { "success" => true, "cbu" => cbu, "amount" => amount, "balance" => @balances[cbu] }
        end
      end

      reset!
    end
  end
end
