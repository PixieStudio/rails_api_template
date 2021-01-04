module Api
  module V1
    module Admin
      class ApplicationController < ApplicationController
        before_action :is_admin!
      end
    end
  end
end
