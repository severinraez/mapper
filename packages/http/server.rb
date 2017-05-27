require 'sinatra'

module Http; end

class Http::Server < Sinatra::Base
  configure do
    set :bind, '0.0.0.0' # Allow access from non-localhost
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'

    content_type :json
  end
end
