require './lib/twitterstream.rb'

abort 'usage: consumer_token consumer_secret access_token access_secret' if ARGV.length < 4

tw = TwitterStream.new({ :consumer_token => ARGV[0],
                         :consumer_secret => ARGV[1],
                         :access_token => ARGV[2],
                         :access_secret => ARGV[3] })
i = 0
tw.sample do |status|
  next unless status['text']
  break if i > 5
  i += 1
  user = status['user']
  puts "#{user['screen_name']}: #{status['text']}"
end

i = 0
tw.chirpuserstreams do |status|
  next unless status['text']
  break if i > 5
  i += 1
  user = status['user']
  puts "#{user['screen_name']}: #{status['text']}"
end
