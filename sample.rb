require "./lib/twitterstream"

abort 'usage: username password' if ARGV.length < 2

ts = TwitterStream.new({ :username => ARGV[0], :password =>ARGV[1] })

puts "sample"
i = 0
ts.sample do |status|
  next unless status['text']
    break if i > 5
    i += 1
    user = status['user']
    puts "#{user['screen_name']}: #{status['text']}"
end

puts "userstreams"
i = 0
ts.userstreams do |status|
  next unless status['text']
    break if i > 5
    i += 1
    user = status['user']
    puts "#{user['screen_name']}: #{status['text']}"
end

puts "track ary"
i = 0
ts.track(['bit','ly']) do |status| # or ts.track("bit,ly")
    break if i > 5
    i += 1
    user = status['user']
    puts "#{user['screen_name']}: #{status['text']}"
end

puts "track str"
i = 0
ts.track('bit,ly') do |status| # or ts.track("bit,ly")
    break if i > 5
    i += 1
    user = status['user']
    puts "#{user['screen_name']}: #{status['text']}"
end

puts "follow ary"
i = 0
ts.follow([5161091,66137185]) do |status| # or ts.track("5161091,66137185") or ts.track(["5161091",66137185])
    break if i >= 1
    i += 1
    user = status['user']
    puts "#{user['screen_name']}: #{status['text']}"
end

puts "follow str"
i = 0
ts.follow("5161091,66137185") do |status| # or ts.track("5161091,66137185") or ts.track(["5161091",66137185])
    break if i >= 1
    i += 1
    user = status['user']
    puts "#{user['screen_name']}: #{status['text']}"
end

puts "follow ary in str and int"
i = 0
ts.follow(["5161091",66137185]) do |status| # or ts.track("5161091,66137185") or ts.track(["5161091",66137185])
    break if i >= 1
    i += 1
    user = status['user']
    puts "#{user['screen_name']}: #{status['text']}"
end

