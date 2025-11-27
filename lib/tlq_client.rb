# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require_relative 'tlq_client/version'

# A client library for communicating with a TLQ (Tiny Little Queue) server.
#
# TLQClient provides a simple interface for message queue operations including
# adding, retrieving, deleting, and retrying messages.
#
# @example Basic usage
#   client = TLQClient.new(host: 'localhost', port: 1337)
#
#   # Add a message
#   message = client.add_message("Hello, TLQ!")
#
#   # Retrieve messages
#   messages = client.get_messages(5)
#
#   # Process and delete
#   ids = messages.map { |m| m['id'] }
#   client.delete_messages(ids)
#
# @see https://github.com/robinbakker/tiny-little-queue TLQ Server
class TLQClient
  # @return [String] the hostname of the TLQ server
  attr_reader :host

  # @return [Integer] the port number of the TLQ server
  attr_reader :port

  # @return [String] the base URI for API requests
  attr_reader :base_uri

  # Creates a new TLQClient instance.
  #
  # @param host [String] the hostname of the TLQ server (default: 'localhost')
  # @param port [Integer] the port number of the TLQ server (default: 1337)
  #
  # @example Connect to default server
  #   client = TLQClient.new
  #
  # @example Connect to custom server
  #   client = TLQClient.new(host: 'tlq.skyak.tech', port: 8080)
  def initialize(host: 'localhost', port: 1337)
    @host = host
    @port = port
    @base_uri = "http://#{@host}:#{@port}"
  end

  # Adds a message to the queue.
  #
  # @param body [String, Hash, Array] the message body to add to the queue.
  #   Can be a string or any JSON-serializable object.
  #
  # @return [Hash] the created message object containing 'id', 'body', and metadata
  #
  # @raise [RuntimeError] if the server response cannot be parsed as JSON
  # @raise [RuntimeError] if the HTTP request fails
  #
  # @example Add a simple string message
  #   message = client.add_message("Hello, World!")
  #   puts message['id']  # => "abc123"
  #
  # @example Add a hash message
  #   message = client.add_message({ event: 'user_signup', user_id: 42 })
  def add_message(body)
    response = post('/add', { body: body })
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise "Failed to parse response: #{e.message}"
  rescue StandardError => e
    raise "HTTP request failed: #{e.message}"
  end

  # Retrieves messages from the queue.
  #
  # Messages are leased to the client and must be either deleted (to acknowledge
  # successful processing) or retried (to return them to the queue).
  #
  # @param count [Integer] the number of messages to retrieve (default: 1)
  #
  # @return [Array<Hash>] an array of message objects, each containing 'id' and 'body'
  #
  # @raise [RuntimeError] if the server response cannot be parsed as JSON
  # @raise [RuntimeError] if the HTTP request fails
  #
  # @example Get a single message
  #   messages = client.get_messages
  #   message = messages.first
  #   puts message['body']
  #
  # @example Get multiple messages
  #   messages = client.get_messages(10)
  #   messages.each { |m| process(m) }
  def get_messages(count = 1)
    response = post('/get', { count: count })
    parsed = JSON.parse(response.body)
    parsed.is_a?(Array) ? parsed : Array(parsed['messages'] || parsed)
  rescue JSON::ParserError => e
    raise "Failed to parse response: #{e.message}"
  rescue StandardError => e
    raise "HTTP request failed: #{e.message}"
  end

  # Deletes messages from the queue permanently.
  #
  # Use this method to acknowledge successful processing of messages.
  # Once deleted, messages cannot be recovered.
  #
  # @param ids [String, Array<String>] a single message ID or array of message IDs to delete
  #
  # @return [Boolean] true if the deletion was successful
  #
  # @raise [RuntimeError] if the HTTP request fails
  #
  # @example Delete a single message
  #   client.delete_messages("abc123")
  #
  # @example Delete multiple messages
  #   client.delete_messages(["abc123", "def456", "ghi789"])
  def delete_messages(ids)
    response = post('/delete', { ids: Array(ids) })
    response.body == '"Success"'
  rescue StandardError => e
    raise "HTTP request failed: #{e.message}"
  end

  # Returns messages to the queue for reprocessing.
  #
  # Use this method when message processing fails and you want to retry later.
  # The messages will be returned to the queue and can be retrieved again.
  #
  # @param ids [String, Array<String>] a single message ID or array of message IDs to retry
  #
  # @return [Boolean] true if the retry was successful
  #
  # @raise [RuntimeError] if the HTTP request fails
  #
  # @example Retry a single message
  #   client.retry_messages("abc123")
  #
  # @example Retry multiple messages
  #   client.retry_messages(["abc123", "def456"])
  def retry_messages(ids)
    response = post('/retry', { ids: Array(ids) })
    response.body == '"Success"'
  rescue StandardError => e
    raise "HTTP request failed: #{e.message}"
  end

  # Purges all messages from the queue.
  #
  # @note This operation is irreversible. All messages will be permanently deleted.
  #
  # @return [Boolean] true if the purge was successful
  #
  # @raise [RuntimeError] if the HTTP request fails
  #
  # @example Clear the queue
  #   client.purge_queue
  def purge_queue
    response = post('/purge', {})
    response.body == '"Success"'
  rescue StandardError => e
    raise "HTTP request failed: #{e.message}"
  end

  # Checks if the TLQ server is reachable and responding.
  #
  # @return [Boolean] true if the server is healthy and responding
  #
  # @raise [RuntimeError] if the health check request fails
  #
  # @example Check server status
  #   if client.health_check
  #     puts "Server is running"
  #   end
  def health_check
    uri = URI("#{@base_uri}/hello")
    response = Net::HTTP.get_response(uri)
    response.body == '"Hello World"'
  rescue StandardError => e
    raise "Health check failed: #{e.message}"
  end

  private

  # Sends a POST request to the TLQ server.
  #
  # @param path [String] the API endpoint path
  # @param data [Hash] the request body data to send as JSON
  #
  # @return [Net::HTTPResponse] the HTTP response object
  #
  # @api private
  def post(path, data)
    uri = URI("#{@base_uri}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = JSON.generate(data)
    http.request(request)
  end
end
