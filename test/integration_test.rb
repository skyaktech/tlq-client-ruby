# frozen_string_literal: true

# Integration test - requires running TLQ server on localhost:1337
# Run with: bundle exec ruby test/integration_test.rb

require_relative '../lib/tlq_client'

client = TLQClient.new

puts "=== TLQ Client Integration Test ==="
puts

# 1. Health check
puts "1. Health check (GET /hello)"
result = client.health_check
puts "   Response: #{result}"
puts "   Expected: true"
puts "   Status: #{result == true ? "✓ PASS" : "✗ FAIL"}"
puts

# 2. Purge queue (start clean)
puts "2. Purge queue (POST /purge)"
result = client.purge_queue
puts "   Response: #{result}"
puts "   Expected: true"
puts "   Status: #{result == true ? "✓ PASS" : "✗ FAIL"}"
puts

# 3. Add message
puts "3. Add message (POST /add)"
msg = client.add_message("Test message body")
puts "   Response: #{msg}"
puts "   Has id: #{msg["id"] ? "✓" : "✗"}"
puts "   Has body: #{msg["body"] == "Test message body" ? "✓" : "✗"}"
puts "   State Ready: #{msg["state"] == "Ready" ? "✓" : "✗"}"
puts "   retry_count 0: #{msg["retry_count"] == 0 ? "✓" : "✗"}"
pass = msg["id"] && msg["body"] == "Test message body" && msg["state"] == "Ready" && msg["retry_count"] == 0
puts "   Status: #{pass ? "✓ PASS" : "✗ FAIL"}"
puts

# 4. Get messages
puts "4. Get messages (POST /get)"
messages = client.get_messages(1)
puts "   Response: #{messages}"
puts "   Is array: #{messages.is_a?(Array) ? "✓" : "✗"}"
puts "   Has 1 message: #{messages.length == 1 ? "✓" : "✗"}"
puts "   State Processing: #{messages[0]["state"] == "Processing" ? "✓" : "✗"}"
pass = messages.is_a?(Array) && messages.length == 1 && messages[0]["state"] == "Processing"
puts "   Status: #{pass ? "✓ PASS" : "✗ FAIL"}"
msg_id = messages[0]["id"]
puts

# 5. Retry message
puts "5. Retry message (POST /retry)"
result = client.retry_messages(msg_id)
puts "   Response: #{result}"
puts "   Expected: true"
puts "   Status: #{result == true ? "✓ PASS" : "✗ FAIL"}"

# Verify retry_count incremented
messages = client.get_messages(1)
puts "   After retry - retry_count: #{messages[0]["retry_count"]}"
puts "   retry_count incremented: #{messages[0]["retry_count"] == 1 ? "✓ PASS" : "✗ FAIL"}"
puts

# 6. Delete message
puts "6. Delete message (POST /delete)"
result = client.delete_messages(msg_id)
puts "   Response: #{result}"
puts "   Expected: true"
puts "   Status: #{result == true ? "✓ PASS" : "✗ FAIL"}"

# Verify message deleted
messages = client.get_messages(1)
puts "   Queue empty after delete: #{messages.empty? ? "✓ PASS" : "✗ FAIL"}"
puts

puts "=== All tests complete ==="
