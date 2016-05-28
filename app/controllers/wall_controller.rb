class WallController < ApplicationController
  before_action :twitter_client

  def index
    search = TweetsRequest.new.request
    puts search
    tweets = @twitter.search(search, result_type: 'recent').take(20)
    @tweets = TweetsPackage.new(tweets).package
    render json: @tweets
  end
end
