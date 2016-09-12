require_relative 'graph_query'

class Process::Sentiment < Process::GraphQuery
  def fetch(params)
    params_from(params)

    has_range

    @result = @range.of(Graph::Sentiment.all)

    returns_json
  end

  def create(params)

    params_from(params)
    param :name, String, required: true
    param :latitude, Float, required: true
    param :longitude, Float, required: true

    @result = Graph::Sentiment.create(name: @name, latitude: @latitude, longitude: @longitude)

    returns_json
  end
end
