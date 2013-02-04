module Ficklehand
  class TweetParser

    DELIMITER_REGEX = /(or|\|)/i
    CHOICE_DELIMITER_REGEX = /(\s+or\s+)|\|/i
    REMOVE_USER_REGEX = /@[^\s]+/

    def initialize(tweet)
      @tweet_text = tweet.text.clone
    end

    def decisions
      @decisions ||=
        begin
          remove_users!
          find_decisions
        end
    end

    def decideable?
      ! decisions.nil?
    end

    private

    def remove_users!
      @tweet_text.gsub!(REMOVE_USER_REGEX,'')
      @tweet_text
    end

    def find_decisions
      decisions = @tweet_text.split(CHOICE_DELIMITER_REGEX).reject do |part| 
        part.match(DELIMITER_REGEX)
      end.collect{|decision| decision.strip.gsub(/\?$/,'')}

      if decisions.length == 1 || decisions == []
        nil
      else
        decisions
      end
    end

  end
end
