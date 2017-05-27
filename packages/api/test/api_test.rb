require_relative '../../../test_helper.rb'
require 'rack/test'

require_relative '../api'

def app
  API::Server
end

describe 'GET /sentiments' do
  include Rack::Test::Methods

  let(:json) { JSON.parse(last_response.body) }

  it 'fetches' do
    Graph::Sentiment.create(name: 'Test', latitude: 46.9479, longitude: 7.4446)

    get '/sentiments'

    assert_equal(json, Graph::Functions.many_json(Graph::Sentiment.all))
  end
end
