require 'rails_helper'

describe TweetsPackage do
  before(:each) do
    @twitter = Twitter::REST::Client.new(
      consumer_key:    Rails.application.secrets.twitter_key,
      consumer_secret: Rails.application.secrets.twitter_secret)
  end

  describe 'finds' do
    it 'an image in the tweet media' do
      stub_media = { media_url: 'http://goose.com/media.jpg' }
      tweet = stub_tweet(
        text: 'http://goose.com/text.jpg',
        media: [stub_media])
      result = tweets_package([tweet])
      expect(result[0][:media_url]).to eq('http://goose.com/media.jpg')
    end

    it 'an image in the tweet text' do
      tweet = stub_tweet(
        text: 'http://goose.com/text.jpg')
      result = tweets_package([tweet])
      expect(result[0][:media_url]).to eq('http://goose.com/text.jpg')
    end

    it 'the first hex color in the tweet text' do
      tweet = stub_tweet(
        text: 'a great color is #FF0000')
      result = tweets_package([tweet])
      expect(result[0][:text]).to eq('a great color is')
      expect(result[0][:color][:css]).to eq('rgb(100.00%, 0.00%, 0.00%)')
    end

    it 'the first rgb color in the tweet text' do
      tweet = stub_tweet(
        text: 'a great color is rgb(255, 0, 0)')
      result = tweets_package([tweet])
      expect(result[0][:color][:css]).to eq('rgb(100.00%, 0.00%, 0.00%)')
    end

    it 'the first hsl color in the tweet text' do
      tweet = stub_tweet(
        text: 'a great color is hsl(0, 100, 50)')
      result = tweets_package([tweet])
      expect(result[0][:color][:css]).to eq('rgb(100.00%, 0.00%, 0.00%)')
    end

    it 'tweets from users with over 100 followers only' do
      tweet1 = stub_tweet(followers_count: 100)
      tweet2 = stub_tweet(followers_count: 101)
      result = tweets_package([tweet1, tweet2])
      expect(result.count).to eq(1)
    end
  end

  describe 'cleans' do
    it 'found image in the tweet text from the text' do
      tweet = stub_tweet(
        text: 'http://goose.com/text.jpg some text')
      result = tweets_package([tweet])
      expect(result[0][:media_url]).to eq('http://goose.com/text.jpg')
      expect(result[0][:text]).to eq('some text')
    end

    it 'excess whitespace from the text' do
      tweet = stub_tweet(
        text: '    some text   ')
      result = tweets_package([tweet])
      expect(result[0][:text]).to eq('some text')
    end

    it 'usernames from the text' do
      tweet = stub_tweet(
        text: '@steven is great said @dan')
      result = tweets_package([tweet])
      expect(result[0][:text]).to eq('is great said')
    end

    it 'links from the text' do
      tweet = stub_tweet(
        text: 'http://dude.co is great according to https://something.org')
      result = tweets_package([tweet])
      expect(result[0][:text]).to eq('is great according to')
    end

    it 'swaps image for emoji' do
      tweet = stub_tweet(
        text: 'hey! 😃')
      result = tweets_package([tweet])
      expect(result[0][:text]).to eq(
        'hey! <img alt="😃" class="emoji" src="/assets/emoji/smiley.png">')
    end
  end

  def tweets_package(arr)
    TweetsPackage.new({ statuses: arr }, @twitter).package
  end

  def stub_tweet(params)
    {
      id:    params[:id] || rand(9_999_999),
      media: params[:media] || [],
      text:  params[:text] || 'tweet text',
      user:  stub_user(params),
      entities: {}
    }
  end

  def stub_user(params)
    {
      location:           params[:location] || 'chicago',
      profile_media_url:  params[:profile_media_url] || 'profile.jpg',
      profile_link_color: params[:profile_link_color] || 'FFBB00',
      screen_name:        params[:screen_name] || '@ju_ju',
      followers_count:    params[:followers_count] || 101
    }
  end
end
