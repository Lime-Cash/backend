class AccountsController < ApplicationController
  def balance
    begin
      balance = AccountService.get_balance_by_user(@current_user)

      balance_value = balance.to_s("F")
      render json: { balance: balance_value }, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      Rails.logger.error("Unexpected error in AccountsController#my_balance: #{e.class} - #{e.message}")
      render json: { error: "An unexpected error occurred. Please contact support." }, status: :internal_server_error
    end
  end

  def activity
    activity = AccountService.get_activity(@current_user)
    render json: activity
  end
end
