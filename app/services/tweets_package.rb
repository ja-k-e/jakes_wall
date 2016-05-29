class TweetsPackage
  def initialize(tweets)
    @tweets = tweets
  end

  def package
    tweets = []
    @tweets.each do |tweet|
      next unless tweet.user.followers_count > 100
      color = find_color(tweet)
      image = find_image(tweet)
      tweets << {
        link: "http://twitter.com/#{tweet.user.screen_name}/status/#{tweet.id}",
        author_link: "http://twitter.com/#{tweet.user.screen_name}",
        username: tweet.user.screen_name,
        location: tweet.user.location,
        color: generate_color(color),
        profile_image_url: tweet.user.profile_image_url.to_s,
        image_url: image,
        text: clean_text(tweet, color, image)
      }
    end
    tweets
  end

  private

  def generate_color(color)
    if color.starts_with? 'rgb'
      parsed = parse_rgb(color)
      rgb = Color::RGB.new(parsed[:r], parsed[:g], parsed[:b])
      hsl = rgb.to_hsl
    elsif color.starts_with? '#'
      rgb = Color::RGB.by_css(color)
      hsl = rgb.to_hsl
    else
      parsed = parse_hsl(color)
      hsl = Color::HSL.new(parsed[:h], parsed[:s], parsed[:l])
      rgb = hsl.to_rgb
    end

    { css: rgb.css_rgb, rgb: rgb, hsl: hsl }
  end

  def parse_rgb(color)
    match = color.match(/rgb\( ?(.+), ?(.+) ?, ?(.+) ?\)/)
    { r: match[1].to_i, g: match[2].to_i, b: match[3].to_i }
  end

  def parse_hsl(color)
    match = color.match(/hsl\( ?(\d+) ?, ?(\d+)\%? ?, ?(\d+)\%? ?\)/)
    { h: match[1].to_i, s: match[2].to_i, l: match[3].to_i }
  end

  def find_color(tweet)
    inline = tweet.text.match(/#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})/)
    inline = tweet.text.match(/rgb\( ?\d+ ?, ?\d+ ?, ?\d+ ?\)/) unless inline
    inline = tweet.text.match(/hsl\( ?\d+ ?, ?\d+\%? ?, ?\d+\%? ?\)/) unless inline
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
    text = clean_string(text, color) if color
    text = clean_usernames(text)
    text = clean_links(text)
    text = clean_emoji(text)
    text = clean_bookend_spaces(text)
    text
  end

  def clean_emoji(text)
    Emoji.replace_unicode_moji_with_images(text)
  end

  def clean_string(text, string)
    text = text.gsub(string, '')
    text.gsub('  ', ' ')
  end

  def clean_usernames(text)
    text.gsub(/@[a-zA-Z0-9_]+ ?/, '')
  end

  def clean_links(text)
    text.gsub(/https?:\/\/[^ ]+/, '')
  end

  def clean_bookend_spaces(text)
    text = text.gsub(/\A +/, '')
    text.gsub(/ +\z/, '')
  end
end
