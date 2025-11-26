#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/tlq_client'

# Initialize client
client = TLQClient.new(host: 'localhost', port: 1337)

# Add a message
message = client.add_message("Process this task")
puts "Added message with ID: #{message['id']}"

# Get messages
messages = client.get_messages(5)
puts "Retrieved #{messages.length} messages"

# Process messages (example)
messages.each do |msg|
  begin
    # Process message here
    puts "Processing: #{msg['body']}"

    # On success, delete the message
    client.delete_messages(msg['id'])
  rescue => e
    # On failure, retry the message
    client.retry_messages(msg['id'])
  end
end

# Purge queue (use with caution)
client.purge_queue if ENV['PURGE_QUEUE'] == 'true'

# Check health
puts "Server healthy: #{client.health_check}"
