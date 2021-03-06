# frozen_string_literal: true

# Application Controller
class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler

  before_action :authorize_request
  attr_reader :current_user

  private

  def authorize_request
    @current_user = AuthorizeApiRequest.new(request.headers).call[:user]
  end

  def is_admin!
    if current_user&.admin
    else
      json_response({ message: 'Non autorisé' }, :unauthorized)
    end
  end
end
