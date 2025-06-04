class TransactionsController < ApplicationController
  def deposit_bank
    cbu = params[:cbu]
    amount = params[:amount].to_f

    user_id = current_user.id

    service = Bank::DepositService.new(cbu: cbu, user_id: user_id, amount: amount)

    result = service.call

    if result[:success]
      render json: {
        success: true,
        transaction: result[:transaction],
        bank_response: result[:bank_response]
      }, status: :ok
    else
      render json: { success: false, error: result[:error] }, status: :unprocessable_entity
    end
  end

  def withdraw_bank
    cbu = params[:cbu]
    amount = params[:amount].to_f

    user_id = current_user.id

    service = Bank::WithdrawService.new(cbu: cbu, user_id: user_id, amount: amount)

    result = service.call

    if result[:success]
      render json: {
        success: true,
        transaction: result[:transaction],
        bank_response: result[:bank_response]
      }, status: :ok
    else
      render json: { success: false, error: result[:error] }, status: :unprocessable_entity
    end
  end
end
