$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'net/http'
require 'uri'
require 'rubygems'
require 'json'
require 'oauth'

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

class TwitterStream
  VERSION = '0.1.1'
  @@urls = {
    'sample' => URI.parse("http://stream.twitter.com/1/statuses/sample.json"),
    'filter' => URI.parse("http://stream.twitter.com/1/statuses/filter.json"),
    'userstreams' => URI.parse('https://userstream.twitter.com/2/user.json?replies=all'),
  }
  
  def initialize(params={ })
    if params[:username] && params[:password]
      @username = params[:username]
      @password = params[:password]
    else
      @consumer = OAuth::Consumer.new(params[:consumer_token], params[:consumer_secret])
      @access = OAuth::Token.new(params[:access_token], params[:access_secret])
    end
    self
  end
  
  def sample(params=nil)
    raise ArgumentError, "params is not hash" unless params.nil? || params.kind_of?(Hash)
    start_stream('sample', params) do |status|
      yield status
    end
  end
  
  def filter(params=nil)
    raise ArgumentError, "params is not hash" unless params.nil? || params.kind_of?(Hash)
    start_stream('filter', params) do |status|
      yield status
    end
  end
  
  def track(track, params=nil)
    raise ArgumentError, "track is not array or string" unless track.kind_of?(Array) || track.kind_of?(String)
    raise ArgumentError, "params is not hash" unless params.nil? || params.kind_of?(Hash)
    
    p = { 'track' => track.kind_of?(Array) ? track.map{|x| raise ArgumentError, "track item is not string or integer!" unless x.kind_of?(String) || x.kind_of?(Integer); x.kind_of?(Integer) ? x.to_s : x }.join(",") : track }
    
    p.merge!('filter',params) if params
    start_stream('filter', p) do |status|
      yield status
    end
  end
  
  def follow(follow, params=nil)
    raise ArgumentError, "follow is not array or string" unless follow.kind_of?(Array) || follow.kind_of?(String)
    raise ArgumentError, "params is not hash" unless params.nil? || params.kind_of?(Hash)
    
    p = { 'follow' => follow.kind_of?(Array) ? follow.join(",") : follow }
    p.merge!(params) if params
    
    start_stream('filter', p) do |status|
      yield status
    end
  end
  
  def userstreams(params=nil)
    raise ArgumentError, "params is not hash" unless params.nil? || params.kind_of?(Hash)
    start_stream('userstreams', params) do |status|
      yield status
    end
  end
  
  private
  
  def start_stream(url, params=nil)
    raise ArgumentError, "params is not hash" unless params.nil? || params.kind_of?(Hash)
    raise ArgumentError, "url is not String or URI!" unless url.kind_of?(URI) || url.kind_of?(String)
    
    if url.kind_of?(URI)
      uri = url
    elsif url.kind_of?(String)
      if @@urls[url]
        uri = @@urls[url]
      elsif /^https?:/ =~ url
        uri = URI.parse(url)
      else
        raise ArgumentError, "@@urls['#{url}'] not found"
      end
    end
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.host == "userstream.twitter.com"
    http.start
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(params) if params
    if @username && @password
      request.basic_auth(@username, @password)
    else
      request.oauth!(http, @consumer, @access)
    end

    begin
      http.request(request) do |response|
        response.each_line("\r\n") do |line|
          j = JSON.parse(line) rescue next
          yield j
        end
      end
    ensure
      http.finish
    end
  end
end
