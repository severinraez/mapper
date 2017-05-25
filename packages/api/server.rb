require_package 'http/server'

module API
  class Server < Http::Server
    get('/sentiments') do

      FDSL.with_libs(API::Functions, Graph::Functions) do
        compose(
          validate(
            params,
            [ [:latitude, Float, required: true],
              [:longitude, Float, required: true],
              [:range, Float, required: false] ] ),
          query(
            pass_params(Graph::Sentiment.all, []),
            pass_params(location, :latitude, :longitude),
            pass_params(range, :range) ),
          nodes_json
        ).call
      end
    end

    post('/sentiments') do
      FDSL.with_libs(Web::Functions, FDSL::Functions, API::Render) do
        compose(
          validate(
            params,
            [
              [:name, String, required: true],
              [:latitude, Float, required: true],
              [:longitude, Float, required: true] ] ),
          Sentiments::Functions.create,
          result_json
        ).call
      end
    end
  end
end
