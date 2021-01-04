module Api
  module V1
    module Admin
      class UsersController < ApplicationController
        def index
          @user = User.all
          json_response(@user)
        end
      end
    end
  end
end
