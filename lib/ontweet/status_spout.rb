require 'red_storm'
require 'twitter'
require 'jruby/synchronized'

class StatusSpout < RedStorm::DSL::Spout
  tweets = ThreadSafe::Array.new

  on_send do
    tweets.shift unless tweets.empty?
  end

  on_init do
    client = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = ENV['CONSUMER_KEY']
      config.consumer_secret     = ENV['CONSUMER_SECRET']
      config.access_token        = ENV['ACCESS_TOKEN']
      config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
    end

    Thread.new {
      client.filter(:track => ENV['KEYWORD'] || "horse") do |tweet|
        begin
          tweets.push(tweet.text)
        rescue => e
          puts "pooped #{e}"
        end
      end
    }
  end
end
