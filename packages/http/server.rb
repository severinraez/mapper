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

  # adds a route
  def self.add_route(http_method, path, process)
    sinatra_method = method(http_method)
    path = Array(path)

    url_fragment = "/#{path.map(&:to_s).join('/')}"

    sinatra_method.call(url_fragment) do
      process.call(params)
    end
  end
end
