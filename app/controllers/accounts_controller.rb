class AccountsController < ApplicationController
  def index
  end

  def balance
    begin
      balance = AccountService.get_balance(params[:account_id])
      render json: { balance: balance }, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue StandardError => e
      Rails.logger.error("Unexpected error in AccountsController#balance: #{e.class} - #{e.message}")
      render json: { error: "An unexpected error occurred. Please contact support." }, status: :internal_server_error
    end
  end

  def create
  end

  def update
  end

  def destroy
  end
end
