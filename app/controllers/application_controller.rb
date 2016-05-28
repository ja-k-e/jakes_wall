class ApplicationController < ActionController::API
  private

  def twitter_client
    @twitter = Twitter::REST::Client.new(
      consumer_key:    Rails.application.secrets.twitter_key,
      consumer_secret: Rails.application.secrets.twitter_secret)
  end
end
