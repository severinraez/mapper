require 'minitest/autorun'
require 'rack/test'

require_relative '../server'

class Http::ServerTest < Minitest::Test
  include Rack::Test::Methods

  class DummyServer < Http::Server
    add_route :get, :foo, ->( params ) { params.inspect }
  end

  def app
    DummyServer
  end

  def test_get_foo
    get '/foo', param: 'value'

    assert_equal({ 'param' => 'value'}.inspect, last_response.body)
  end
end
