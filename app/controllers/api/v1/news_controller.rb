# frozen_string_literal: true

module Api
  module V1
    # News Controller
    class NewsController < ApplicationController
      skip_before_action :authorize_request, only: %i[index show]
      before_action :set_news, only: %i[show update destroy]

      def index
        news = News.all
        json_response(NewsSerializer.new(news).serializable_hash.to_json)
      end

      def show
        json_response(NewsSerializer.new(@news).serializable_hash.to_json)
      end

      def create
        news = News.create!(news_params)
        json_response(NewsSerializer.new(news).serializable_hash.to_json, :created)
      end

      def update
        @news.update!(news_params)
        json_response(NewsSerializer.new(@news).serializable_hash.to_json)
      end

      def destroy
        @news.destroy!
        json_response(nil, :no_content)
      end

      private

      def set_news
        @news = News.find(params[:id])
      end

      def news_params
        params.require(:news).permit(:title, :body, :user_id, :published)
      end
    end
  end
end
