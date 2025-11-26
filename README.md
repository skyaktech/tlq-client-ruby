# TLQ Client

Ruby client for [TLQ (Tiny Little Queue)](https://tinylittlequeue.app/) message queue service.

## Installation

Add to your Gemfile:

```ruby
gem 'tlq-client'
```

Then run:

```bash
bundle install
```

Or install directly:

```bash
gem install tlq-client
```

## Usage

```ruby
require 'tlq_client'

# Initialize client (defaults to localhost:1337)
client = TLQClient.new
# or with custom host/port
client = TLQClient.new(host: 'queue.example.com', port: 8080)

# Add messages to the queue
message = client.add_message("Process order #123")
puts message['id']  # => "019ac13f-3286-7f00-bcb7-c86fe88798b4"

# Get messages (default: 1, max configurable on server)
messages = client.get_messages(10)

# Process messages
messages.each do |msg|
  begin
    # Your processing logic here
    process(msg['body'])

    # Success - delete the message
    client.delete_messages(msg['id'])
  rescue => e
    # Failed - return to queue for retry
    client.retry_messages(msg['id'])
  end
end

# Batch operations
ids = messages.map { |m| m['id'] }
client.delete_messages(ids)  # Delete multiple
client.retry_messages(ids)   # Retry multiple

# Health check
client.health_check  # => true

# Purge all messages (use with caution!)
client.purge_queue
```

## API Reference

### `TLQClient.new(host: 'localhost', port: 1337)`

Creates a new client instance.

### `add_message(body) → Hash`

Adds a message to the queue. Returns the message object:

```ruby
{
  'id' => 'uuid-v7',
  'body' => 'your message',
  'state' => 'Ready',
  'retry_count' => 0
}
```

### `get_messages(count = 1) → Array`

Retrieves messages from the queue. Messages transition to "Processing" state and become invisible to other consumers.

### `delete_messages(ids) → Boolean`

Permanently removes messages from the queue. Accepts a single ID or array of IDs.

### `retry_messages(ids) → Boolean`

Returns messages to the queue for reprocessing. Increments `retry_count`. Accepts a single ID or array of IDs.

### `purge_queue → Boolean`

Removes all messages from the queue. Cannot be undone.

### `health_check → Boolean`

Returns `true` if the TLQ server is reachable.

## Requirements

- Ruby >= 2.6
- Running [TLQ server](https://github.com/skyaktech/tlq)

## Development

```bash
# Install dependencies
bundle install

# Run unit tests
bundle exec rake test

# Run integration tests (requires TLQ server)
bundle exec rake integration

# Run all tests
bundle exec rake test_all
```

## Other Client Libraries

- [Go](https://github.com/skyaktech/tlq-client-go)
- [Node.js](https://github.com/skyaktech/tlq-client-node)
- [Python](https://github.com/skyaktech/tlq-client-py)
- [Rust](https://github.com/skyaktech/tlq-client-rust)

## License

MIT
