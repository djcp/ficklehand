$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))
$stdout.sync = true

require 'rubygems'
require 'twitter'
require 'yaml'
require 'ficklehand'

conf = Ficklehand.config
conf.init_twitter_config
MAX_ATTEMPTS = 3

while(true) do
  puts "\n#{Time.now}"

  num_attempts = 0
  begin
    num_attempts += 1
    mentions = Ficklehand::Fetcher.get_mentions
  rescue Twitter::Error::TooManyRequests => error
    if num_attempts <= MAX_ATTEMPTS
      sleep error.rate_limit.reset_in
      mentions = Ficklehand::Fetcher.get_mentions
    else
      raise
    end
  end

  mentions.each do |mention|
    parsed_tweet = Ficklehand::TweetParser.new(mention)

    if parsed_tweet.decideable?
      sent_decision = Ficklehand.db[:decisions_made].where(original_tweet_id: mention.id)
      if sent_decision.count == 0

        decision = parsed_tweet.decisions.sample
        decision_tweet = Ficklehand::Responder.send_decision(
          mention.id,
          mention.from_user,
          decision
        )

        Ficklehand.db[:decisions_made].insert(
          user: mention.from_user,
          original_tweet: mention.text,
          original_tweet_id: mention.id,
          decision_tweet: decision_tweet,
          tweet_time: mention.created_at,
          responded_at: Time.now
        )
        puts "\nSent: #{decision_tweet}"
        puts "in response to: #{mention.text}"
      else
        puts "Already responded"
      end

    else
      user = mention.from_user
      help_sent = Ficklehand.db[:help_sent].where(user: user)
      if help_sent.count == 0
        Ficklehand::Responder.send_help(mention.id, user)
        Ficklehand.db[:help_sent].insert(user: user)
        puts "\nSending help to #{user}"
      else
        puts "Already sent help to #{user}. Not sending"
      end
    end
  end

  sleep conf.loop_delay
end
