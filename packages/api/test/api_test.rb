require_relative '../../../test_helper.rb'
require 'rack/test'

require_relative '../api'

class API::ServerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    API::Server
  end

  def test_get_sentiments
    get '/sentiments'

    assert_equal(json, Graph::Functions.many_json(Graph::Sentiment.all))
  end

  def json
    JSON.parse(last_response.body)
  end
end
