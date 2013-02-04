require 'spec_helper'

describe Ficklehand::TweetParser do

  context 'non-decideable tweet' do
    ['foo bar baz', '@foo bar blee', ''].each do|tweet_text|
      it 'should return nil' do
        expect(tweet_decisions(tweet_text)).to be_nil
      end
    end
  end

  context 'decideable tweets' do
    it '#decideable? should return true' do
      expect(
        described_class.new(TweetFake.new('foo OR bar'))
      ).to be_decideable
    end

    ['@ficklehand @foobar bleep OR bar', 
      '@ficklehand foodity bleep barp | choice two',
      'turtlebucket helper or attack shovel @FICKLEHAND'
    ].each do|tweet_text|
      it 'should return choices' do
        expect(tweet_decisions(tweet_text).size).to be > 1
      end
    end

    it 'parses decisions correctly' do
      expect(tweet_decisions('@foo bar OR baz?')).to eq ['bar', 'baz']
      expect(tweet_decisions('@foo bar|baz')).to eq ['bar', 'baz']
      expect(tweet_decisions('bar | baz @foo @bsss')).to eq ['bar', 'baz']
      expect(tweet_decisions('#blee bar OR baz #ddd')).to eq ['#blee bar', 'baz #ddd']
      expect(tweet_decisions('foo | bar | blarp')).to eq ['foo', 'bar', 'blarp']
    end

  end

  def tweet_decisions(tweet_text)
    described_class.new(TweetFake.new(tweet_text)).decisions
  end

  class TweetFake
    attr_reader :text
    def initialize(text)
      @text = text
    end
  end

end
