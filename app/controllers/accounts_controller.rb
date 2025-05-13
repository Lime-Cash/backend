class AccountsController < ApplicationController
  def index
  end

  def balance
    begin
      balance = AccountService.get_balance(params[:account_id])
      render json: { balance: balance }, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: e.message }, status: :not_found
    rescue NoMethodError => e
      render json: { error: "Internal service error: #{e.message}" }, status: :internal_server_error
    end
  end

  def create
  end

  def update
  end

  def destroy
  end
end
