# frozen_string_literal: true

module Api
  module V1
    # Users Controller
    class UsersController < ApplicationController
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
        @user = if current_user.admin?
                  User.find(params[:id])
                else
                  current_user
                end
        json_response(@user)
      end

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
  end
end
