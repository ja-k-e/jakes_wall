require 'rails_helper'

describe TweetsPackage do
  before(:each) do
  end

  describe 'finds' do
    it 'an image in the tweet media' do
      stub_media = StubMedia.new(media_url: 'http://goose.com/media.jpg')
      tweet = stub_tweet(
        text: 'http://goose.com/text.jpg',
        media: [stub_media])
      result = TweetsPackage.new([tweet]).package
      expect(result[0][:image_url]).to eq('http://goose.com/media.jpg')
    end

    it 'an image in the tweet text' do
      tweet = stub_tweet(
        text: 'http://goose.com/text.jpg')
      result = TweetsPackage.new([tweet]).package
      expect(result[0][:image_url]).to eq('http://goose.com/text.jpg')
    end

    it 'the first hex color in the tweet text' do
      tweet = stub_tweet(
        text: 'a great color is #FF0000')
      result = TweetsPackage.new([tweet]).package
      expect(result[0][:text]).to eq('a great color is')
      expect(result[0][:color][:css]).to eq('rgb(100.00%, 0.00%, 0.00%)')
    end

    it 'the first rgb color in the tweet text' do
      tweet = stub_tweet(
        text: 'a great color is rgb(255, 0, 0)')
      result = TweetsPackage.new([tweet]).package
      expect(result[0][:color][:css]).to eq('rgb(100.00%, 0.00%, 0.00%)')
    end

    it 'the first hsl color in the tweet text' do
      tweet = stub_tweet(
        text: 'a great color is hsl(0, 100, 50)')
      result = TweetsPackage.new([tweet]).package
      expect(result[0][:color][:css]).to eq('rgb(100.00%, 0.00%, 0.00%)')
    end
  end

  describe 'cleans' do
    it 'found image in the tweet text from the text' do
      tweet = stub_tweet(
        text: 'http://goose.com/text.jpg some text')
      result = TweetsPackage.new([tweet]).package
      expect(result[0][:image_url]).to eq('http://goose.com/text.jpg')
      expect(result[0][:text]).to eq('some text')
    end

    it 'excess whitespace from the text' do
      tweet = stub_tweet(
        text: '    some text   ')
      result = TweetsPackage.new([tweet]).package
      expect(result[0][:text]).to eq('some text')
    end

    it 'usernames from the text' do
      tweet = stub_tweet(
        text: '@steven is great said @dan')
      result = TweetsPackage.new([tweet]).package
      expect(result[0][:text]).to eq('is great said')
    end

    it 'links from the text' do
      tweet = stub_tweet(
        text: 'http://dude.co is great according to https://something.org')
      result = TweetsPackage.new([tweet]).package
      expect(result[0][:text]).to eq('is great according to')
    end

    it 'swaps image for emoji' do
      tweet = stub_tweet(
        text: 'hey! 😃')
      result = TweetsPackage.new([tweet]).package
      expect(result[0][:text]).to eq(
        'hey! <img alt="😃" class="emoji" src="/assets/emoji/smiley.png">')
    end
  end

  def stub_tweet(params)
    StubTweet.new(
      id:    params[:id] || rand(9_999_999),
      media: params[:media] || [],
      text:  params[:text] || 'tweet text',
      user:  stub_user(params)
    )
  end

  def stub_user(params)
    StubUser.new(
      location:           params[:location] || 'chicago',
      profile_image_url:  params[:profile_image_url] || 'profile.jpg',
      profile_link_color: params[:profile_link_color] || 'FFBB00',
      screen_name:        params[:screen_name] || '@ju_ju'
    )
  end
end

class StubTweet
  attr_accessor :id, :media, :user, :text

  def initialize(h)
    h.each { |k, v| send("#{k}=", v) }
  end
end

class StubUser
  attr_accessor :location, :profile_image_url, :profile_link_color, :screen_name

  def initialize(h)
    h.each { |k, v| send("#{k}=", v) }
  end
end

class StubMedia
  attr_accessor :media_url

  def initialize(h)
    h.each { |k, v| send("#{k}=", v) }
  end
end
