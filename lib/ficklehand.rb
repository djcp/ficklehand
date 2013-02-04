require 'sequel'
require 'ficklehand/config'
require 'ficklehand/fetcher'
require 'ficklehand/tweet_parser'
require 'ficklehand/responder'

module Ficklehand
  def self.config(config_file = './config.yml')
    @config ||= Config.new config_file
  end

  def self.db
    @db ||= Sequel.connect(ENV['DATABASE_URL'])
  end

  def self.init_database
    self.db.create_table? :help_sent do
      String :user, index: {unique: true}
    end
    self.db.create_table? :decisions_made do
      String :user
      String :original_tweet
      Bignum :original_tweet_id, index: {unique: true}
      String :decision_tweet
      Time :tweet_time
      Time :responded_at
    end
  end

end
