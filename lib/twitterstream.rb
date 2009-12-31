$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'net/http'
require 'uri'
require 'rubygems'
require 'json'

module Net
  class HTTPResponse
    def each_line(rs = "\n")
      stream_check
      while line = @socket.readuntil(rs)
        yield line
      end
      self
    end
  end
end

module TwitterStream
  VERSION = '0.0.3'
  
  class Client
    def initialize(username, password)
      @username = username
      @password = password
      self
    end

    def start_stream(uri, params=nil)
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(params) if params
        request.basic_auth(@username, @password)
        http.request(request) do |response|
          response.each_line("\r\n") do |line|
            status = JSON.parse(line) rescue next
            yield status
          end
        end
      end
    end
    
    def sample(params=nil)
      uri = URI.parse("http://stream.twitter.com/1/statuses/sample.json")
      start_stream(uri, params) do |status|
        yield status
      end
    end

    def filter(params=nil)
      uri = URI.parse("http://stream.twitter.com/1/statuses/filter.json")
      start_stream(uri, params) do |status|
        yield status
      end
    end

    def track(track, params=nil)
      uri = URI.parse("http://stream.twitter.com/1/statuses/filter.json")
      p = {'track'=>track}
      p.merge!(params) if params
      start_stream(uri, p) do |status|
        yield status
      end
    end
    
    def follow(follow, params=nil)
      uri = URI.parse("http://stream.twitter.com/1/statuses/filter.json")
      p = {'track'=>track}
      p.merge!(params) if params
      start_stream(uri, p) do |status|
        yield status
      end
    end
  end
end
