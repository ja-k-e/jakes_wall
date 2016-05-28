class WallController < ApplicationController
  before_action :twitter_client

  def index
    tweets = @twitter.search('@jake_albaugh -filter:retweets', result_type: 'recent').take(20)
    # tweets = @twitter.search('pineapplejim123 cute -filter:retweets', result_type: 'recent').take(20)
    @tweets = Tweets.new(tweets).package
    render json: @tweets
  end
end
