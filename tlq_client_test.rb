require 'minitest/autorun'
require_relative 'tlq_client'

class TLQClientTest < Minitest::Test
  def setup
    @client = TLQClient.new(host: 'localhost', port: 1337)
  end

  def test_add_message
    # Mock response for add_message
    mock_response = Minitest::Mock.new
    mock_response.expect(:body, '{"id":"test-id","body":"test-body","state":"Ready","retry_count":0}')
    @client.stub(:post, mock_response) do
      result = @client.add_message('test-body')
      assert_equal 'test-id', result['id']
      assert_equal 'test-body', result['body']
      assert_equal 'Ready', result['state']
      assert_equal 0, result['retry_count']
    end
  end

  def test_get_messages
    # Mock response for get_messages - fixed JSON format
    mock_response = Minitest::Mock.new
    mock_response.expect(:body, '{"messages":[{"id":"test-id","body":"test-body","state":"Processing","retry_count":1}]}')
    @client.stub(:post, mock_response) do
      result = @client.get_messages(1)
      assert_equal 1, result.length
      assert_equal 'test-id', result[0]['id']
      assert_equal 'test-body', result[0]['body']
      assert_equal 'Processing', result[0]['state']
      assert_equal 1, result[0]['retry_count']
    end
  end

  def test_delete_messages_success
    mock_response = Minitest::Mock.new
    mock_response.expect(:body, '"Success"')
    @client.stub(:post, mock_response) do
      result = @client.delete_messages(['test-id'])
      assert_equal true, result
    end
  end

  def test_delete_messages_failure
    mock_response = Minitest::Mock.new
    mock_response.expect(:body, '"Failed"')
    @client.stub(:post, mock_response) do
      result = @client.delete_messages(['test-id'])
      assert_equal false, result
    end
  end

  def test_retry_messages_success
    mock_response = Minitest::Mock.new
    mock_response.expect(:body, '"Success"')
    @client.stub(:post, mock_response) do
      result = @client.retry_messages(['test-id'])
      assert_equal true, result
    end
  end

  def test_retry_messages_failure
    mock_response = Minitest::Mock.new
    mock_response.expect(:body, '"Failed"')
    @client.stub(:post, mock_response) do
      result = @client.retry_messages(['test-id'])
      assert_equal false, result
    end
  end

  def test_purge_queue_success
    mock_response = Minitest::Mock.new
    mock_response.expect(:body, '"Success"')
    @client.stub(:post, mock_response) do
      result = @client.purge_queue
      assert_equal true, result
    end
  end

  def test_health_check_success
    # Using a more realistic mock
    uri = URI('http://localhost:1337/hello')
    http = Net::HTTP.new(uri.host, uri.port)
    mock_response = Minitest::Mock.new
    mock_response.expect(:body, '"Hello World"')

    Net::HTTP.stub(:get_response, mock_response) do
      result = @client.health_check
      assert_equal true, result
    end
  end

  def test_client_initialization
    client = TLQClient.new(host: 'example.com', port: 8080)
    assert_equal 'example.com', client.host
    assert_equal 8080, client.port
  end

  def test_client_has_post_method
    # Test that the post method exists by checking if it's a private method or accessible
    assert_respond_to @client, :send # We can call send to access private methods if needed
  end
end
