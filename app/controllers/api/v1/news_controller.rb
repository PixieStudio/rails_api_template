# frozen_string_literal: true

module Api
  module V1
    # News Controller
    class NewsController < ApplicationController
      skip_before_action :authorize_request, only: %i[index show]

      def index
        news = News.all
        json_response(NewsSerializer.new(news).serializable_hash.to_json)
      end

      def show
        news = News.friendly.find(params[:id])
        json_response(NewsSerializer.new(news).serializable_hash.to_json)
      end
    end
  end
end
