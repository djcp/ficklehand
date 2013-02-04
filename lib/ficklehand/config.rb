module Ficklehand
  class Config
    attr_reader :consumer_key, :consumer_secret, :oauth_token, :oauth_token_secret, :loop_delay, :users_to_remove

    def initialize(config_file)
      @consumer_key = ENV['CONSUMER_KEY']
      @consumer_secret = ENV['CONSUMER_SECRET']
      @oauth_token = ENV['OAUTH_TOKEN']
      @oauth_token_secret = ENV['OAUTH_TOKEN_SECRET']
      @loop_delay = ENV['LOOP_DELAY']
      @users_to_remove = ENV['USERS_TO_REMOVE'] || []
    end

    def init_twitter_config
      Twitter.configure do |twitter|
        twitter.consumer_key = consumer_key
        twitter.consumer_secret = consumer_secret
        twitter.oauth_token = oauth_token
        twitter.oauth_token_secret = oauth_token_secret
      end
    end

  end
end
