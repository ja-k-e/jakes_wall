class Tweets
  def initialize(tweets)
    @tweets = tweets
  end

  def package
    tweets = []
    @tweets.each do |tweet|
      color = find_color(tweet)
      image = find_image(tweet)
      tweets << {
        link: "http://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}",
        username: tweet.user.screen_name,
        location: tweet.user.location,
        color: color,
        profile_image_url: tweet.user.profile_image_url.to_s,
        image_url: image,
        text: clean_text(tweet, color, image)
      }
    end
    tweets
  end

  private

  def find_color(tweet)
    inline = tweet.text.match(/#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})/)
    inline = tweet.text.match(/rgba?\( ?\d+ ?, ?\d+ ?, ?\d+ ?\)/) unless inline
    inline = tweet.text.match(/hsla?\( ?\d+ ?, ?\d+ ?, ?\d+ ?\)/) unless inline
    return "##{tweet.user.profile_link_color}" unless inline
    inline[0]
  end

  def find_image(tweet)
    return tweet.media[0].media_url.to_s if tweet.media.present?
    inline = tweet.text.match(/https?:\/\/[^ ]+\.(jpg|gif|png)/)
    return nil unless inline
    inline[0]
  end

  def clean_text(tweet, color, image)
    text = tweet.text
    text = clean_emoji(text)
    text = clean_string(text, color) if color
    text = clean_string(text, image) if image
    text
  end

  def clean_emoji(text)
    Emoji.replace_unicode_moji_with_images(text)
  end

  def clean_string(text, string)
    text.gsub(string, '')
    text.gsub('  ', ' ')
  end
end
