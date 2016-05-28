class TweetsRequest
  def request
    "#{mention} #{filters} #{bans}"
  end

  private

  def mention
    '@jake_albaugh'
  end

  def filters
    %w(
      -filter:retweets
    ).join(' ')
  end

  def bans
    %w(
      -bitch
      -fuck
      -shit
    ).join(' ')
  end
end
