class WallController < ApplicationController
  before_action :twitter_client

  def index
    search = TweetsRequest.new.request('@jakes_wall')
    tweets = Twitter::REST::Request.new(
      @twitter, :get,
      "https://api.twitter.com/1.1/search/tweets.json?q=#{URI.escape(search)}&result_type=mixed")
    tweets = tweets.perform

    @tweets = TweetsPackage.new(tweets, @twitter).package
    render json: @tweets
  end
end
