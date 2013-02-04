module Ficklehand
  class Fetcher
    def self.get_mentions
      Twitter.mentions_timeline
    end
  end
end
