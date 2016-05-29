class TweetsRequest
  def request(term)
    "#{term} #{filters} #{bans}"
  end

  private

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
