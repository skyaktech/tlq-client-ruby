require 'json'
require 'net/http'
require 'uri'

class TLQClient
  attr_reader :host, :port, :base_uri

  def initialize(host: 'localhost', port: 1337)
    @host = host
    @port = port
    @base_uri = "http://#{@host}:#{@port}"
  end

  # Add a message to the queue
  def add_message(body)
    response = post('/add', { body: body })
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise "Failed to parse response: #{e.message}"
  rescue StandardError => e
    raise "HTTP request failed: #{e.message}"
  end

  # Get messages from the queue
  def get_messages(count = 1)
    response = post('/get', { count: count })
    parsed = JSON.parse(response.body)
    Array(parsed['messages'] || parsed) # Handle both array and single message responses
  rescue JSON::ParserError => e
    raise "Failed to parse response: #{e.message}"
  rescue StandardError => e
    raise "HTTP request failed: #{e.message}"
  end

  # Delete messages from the queue
  def delete_messages(ids)
    response = post('/delete', { ids: Array(ids) })
    response.body == '"Success"'
  rescue StandardError => e
    raise "HTTP request failed: #{e.message}"
  end

  # Retry messages (return to queue)
  def retry_messages(ids)
    response = post('/retry', { ids: Array(ids) })
    response.body == '"Success"'
  rescue StandardError => e
    raise "HTTP request failed: #{e.message}"
  end

  # Purge all messages from the queue
  def purge_queue
    response = post('/purge', {})
    response.body == '"Success"'
  rescue StandardError => e
    raise "HTTP request failed: #{e.message}"
  end

  # Check server health
  def health_check
    uri = URI("#{@base_uri}/hello")
    response = Net::HTTP.get_response(uri)
    response.body == '"Hello World"'
  rescue StandardError => e
    raise "Health check failed: #{e.message}"
  end

  private

  def post(path, data)
    uri = URI("#{@base_uri}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = JSON.generate(data)
    http.request(request)
  end
end
