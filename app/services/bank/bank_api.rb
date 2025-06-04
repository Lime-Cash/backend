require "httparty"

module Bank
  class BankApiError < StandardError; end

  class BankApi
    include HTTParty

    base_uri ENV.fetch("BANK_API_URL", "http://localhost:3001")

    def self.deposit(cbu:, amount:)
      response = post("/deposit", body: { cbu: cbu, amount: amount }.to_json, headers: headers)
      handle_response(response)
    end

    def self.withdraw(cbu:, amount:)
      response = post("/withdraw", body: { cbu: cbu, amount: amount }.to_json, headers: headers)
      handle_response(response)
    end

    def self.headers
      { "Content-Type" => "application/json" }
    end

    def self.handle_response(response)
      if response.success?
        response.parsed_response
      else
        raise BankApiError, response.parsed_response["error"] || "Unknown error"
      end
    end
  end
end
