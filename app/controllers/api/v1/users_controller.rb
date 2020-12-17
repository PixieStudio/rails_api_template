# frozen_string_literal: true

class Api::V1::UsersController < ApplicationController
  skip_before_action :authorize_request, only: :create

  # POST /signup
  # return authenticated token upon signup
  def create
    user = User.create!(user_params)
    # Profil.create!(user_id: user.id)
    auth_token = AuthenticateUser.new(user.email, user.password).call
    response = { message: Message.account_created, auth_token: auth_token }
    json_response(response, :created)
  end

  def show
    @user = User.find(params[:id])
    json_response(@user.username)
  end

  def check; end

  private

  def user_params
    params.permit(
      :username,
      :email,
      :password,
      :password_confirmation
    )
  end
end
