# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-11-26

### Added

- Initial release of TLQ Client gem
- `add_message(body)` - Add a message to the queue
- `get_messages(count)` - Retrieve messages from the queue
- `delete_messages(ids)` - Delete processed messages
- `retry_messages(ids)` - Return messages to the queue
- `purge_queue` - Clear all messages
- `health_check` - Check server status
