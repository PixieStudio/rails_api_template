# frozen_string_literal: true

class Api::V1::PasswordsController < ApplicationController
  skip_before_action :authorize_request, only: %i[forgot reset]

  def forgot
    # check if email is present
    return render json: { error: 'Veuillez indiquer un email.' } if params[:email].blank?

    user = User.find_by(email: params[:email]) # if present find user by email

    if user.present?
      user.generate_password_token! # generate pass token
      UserMailer.password_reset_email(user).deliver_now
      render json: { status: 'ok', token: user.reset_password_token }, status: :ok
    else
      render json: { error: ['Email inconnu.'] }, status: :not_found
    end
  end

  def reset
    token = params[:token].to_s

    return render json: { error: 'Token not present' } if params[:email].blank?

    user = User.find_by(reset_password_token: token)

    if user.present? && user.password_token_valid?
      if user.reset_password!(params[:password])
        auth_token = AuthenticateUser.new(user.email, user.password).call
        render json: { status: 'ok', auth_token: auth_token }, status: :ok
      else
        render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: ['Lien invalide ou expiré. Veuillez en générer un nouveau.'] }, status: :not_found
    end
  end
end
