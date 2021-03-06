module Ficklehand
  class Responder

    def self.send_help(status_id, user)
      Twitter.update("@#{user} Plz separate choices with \"OR\" or the \"|\". Info here: http://blog.collispuro.com/blog/2013/02/06/at-ficklehand-a-twitter-bot-to-help-you-make-meaningless-decisions/", in_reply_to_status_id: status_id)
    end

    def self.send_decision(status_id, user, decision)
      tweet = "@#{user} I decide: #{decision}"
      Twitter.update(tweet[0..139], in_reply_to_status_id: status_id)
      tweet
    end

  end
end
