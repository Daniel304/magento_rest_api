require 'oauth'
require 'uri'
require 'cgi'
require 'openssl'
require 'base64'
require 'net/http'
require 'json'
require 'yaml'

require "magento_rest_api/version"

module MagentoRestApi
  # This Gem will enable you to communicate to the rest api of magento 1.9.x
  # You first need to authenticate this app to your magento by running the command
  # % authenticate
  #
  # Example:
  # % irb
  #   >> keys = {"consumer_key"=>"your_consumer_key", "consumer_secret"=>"your_consumer_secret", "token"=>"your_token", "token_secret"=>"your_token_secret"}
  #   >> json_response = MagentoRestApi::connect('GET','https://www.brickfever.nl/api/rest/products/200', keys)
  #   => #<Net::HTTPOK 200 OK readbody=true>

  def self.generate_nonce(size=6)
    Base64.encode64(OpenSSL::Random.random_bytes(size)).gsub(/\W/, '')
  end

  def self.url_encode(string)
    CGI::escape(string)
  end

  def self.params(consumer_key, token)
    params = {
      'oauth_consumer_key'        => consumer_key,
      'oauth_nonce'               => generate_nonce,
      'oauth_signature_method'    => 'HMAC-SHA1',
      'oauth_token'               => token,
      'oauth_version'             => '1.0',
      'oauth_timestamp'           => Time.now.to_i.to_s
    }
  end

  def self.signature_base_string(method, uri, params)
    encoded_params = url_encode("oauth_consumer_key=#{params['oauth_consumer_key']}&oauth_nonce=#{params['oauth_nonce']}&oauth_signature_method=#{params['oauth_signature_method']}&oauth_timestamp=#{params['oauth_timestamp']}&oauth_token=#{params['oauth_token']}&oauth_version=#{params['oauth_version']}")
    encoded = method + '&' + url_encode(uri) + '&' + encoded_params
  end

  def self.sign(key, base_string)
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.digest(digest, key, base_string)
    Base64.encode64(hmac).chomp.gsub(/\n/, '')
  end

  def self.create_header(params)
    header = "OAuth "
    params.each do |k, v|
      header += "#{k}=\"#{v}\","
    end
    header.slice(0..-2)
  end

  def self.request_data(header, uri, method, post_data=nil)
    uri                   = URI(uri)
    http                  = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl          = true
    http.verify_mode      = OpenSSL::SSL::VERIFY_NONE
    if method == 'POST'
      resp, data = http.post(uri.path, post_data, { 'Authorization' => header, "Content-Type" => "application/json; charset=utf-8" })
    elsif method == 'PUT'
      request = Net::HTTP::Put.new(uri.path)
      headers = { 'Authorization' => header, "Content-Type" => "application/json" }
      headers.keys.each do |key|
        request[key] = headers[key]
      end
      request.body = post_data
      resp, data = http.request(request)
    else
      resp, data = http.get(uri.path, { 'Authorization' => header, "Content-Type" => "application/json; charset=utf-8" })
    end
    resp
  end

  def self.prepare_access_token(keys)
    consumer = OAuth::Consumer.new(keys['consumer_key'], keys['consumer_secret'], { :site => "https://api.bricklink.com", :scheme => :header })
    token_hash = { :oauth_token => keys['token'], :oauth_token_secret => keys['token_secret'] }
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
    return access_token
  end

  def self.connect(method, uri, keys, post_data=nil)
    params = params(keys['consumer_key'], keys['token'] )
    signature_base_string = signature_base_string(method, uri.to_s, params)
    signing_key = keys['consumer_secret'] + '&' + keys['token_secret']
    params['oauth_signature'] = url_encode(sign(signing_key, signature_base_string))
    header_string = create_header(params)
    json_response = request_data(header_string, uri, method, post_data)
  end
end
