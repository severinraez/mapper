require_package 'http/server'
require_relative 'functions'

module API
  class Server < Http::Server
    get('/sentiments') do
      pp params
      FDSL.with_libs(API::Functions, Graph::Functions) do
        pipeline(
          sanitize_params(
            params,
            [ [:latitude, Float, required: true],
              [:longitude, Float, required: true],
              [:range, Float, required: false] ] ),
          params_pipeline(
            [ Graph::Sentiment.method(:all) ],
            [ filter_location_, :latitude, :longitude ],
            [ filter_range_, :range ]
          ),
          nodes_json_
        )
      end
    end

    post('/sentiments') do
      FDSL.with_libs(Web::Functions, FDSL::Functions, API::Render) do
        compose(
          sanitize_params(
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
