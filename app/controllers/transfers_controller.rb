class TransfersController < ApplicationController
  before_action :authenticate_request

  def create
    recipient_email = params[:email].to_s.downcase
    amount = params[:amount].to_f

    sender = current_user
    recipient = User.find_by(email: recipient_email)

    if recipient.nil?
      render json: { error: "Recipient not found" }, status: :not_found
      return
    end

    if recipient == sender
      render json: { error: "Can't send money to yourself" }, status: :bad_request
      return
    end

    if amount <= 0
      render json: { error: "Amount must be positive" }, status: :unprocessable_entity
      return
    end

    begin
      TransfersService.transfer(
        from: sender.account.id,
        to: recipient.account.id,
        amount: amount
      )
      render json: { message: "Transfer successful" }, status: :created
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def index
  end
end
