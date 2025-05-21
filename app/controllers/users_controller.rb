class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [ :create ]

  def create
    @user = User.new(user_params)

    if @user.save
      @user.create_account(balance: 100)

      token = JWT.encode({ user_id: @user.id }, Rails.application.credentials.secret_key_base)
      render json: { token: token }, status: :created
    else
      render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password)
  end
end
