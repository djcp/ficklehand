$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__))
$stdout.sync = true

require 'rubygems'
require 'twitter'
require 'yaml'
require 'ficklehand'

conf = Ficklehand.config
conf.init_twitter_config

num_requests = 0
while(true) do
  num_requests += 1

  if num_requests % 10 == 0
    puts "#{num_requests} API requests"
  end

  mentions = []
  begin
    #mentions = Ficklehand::Fetcher.get_mentions
    max_tweet_id = Ficklehand.db[:decisions_made].max(:original_tweet_id)
    mentions = Twitter.search("to:ficklehand since_id:#{max_tweet_id}").results
    if mentions.any?
      puts 'Got new mentions'
      puts mentions.inspect
    end
    puts 'got mentions'
  rescue Twitter::Error::TooManyRequests => error
    puts "Oops. Too many requests. Reset in: #{error.rate_limit.reset_in}"
    puts "Limit is: #{error.rate_limit.limit}"
    puts "Remaining: #{error.rate_limit.remaining}"
    puts "Reset at: #{error.rate_limit.reset_at}"
    puts "On request # #{num_requests}"
    num_requests = 0

    sleep error.rate_limit.reset_in + 3
  rescue Exception => error
    puts "some other error was thrown:"
    puts error.inspect
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
