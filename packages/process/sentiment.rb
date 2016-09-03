require_relative 'graph_query'

class Process::Sentiment < Process::GraphQuery
  def fetch(params)

    has_range

    @result = fi.inject(Graph::Sentiment.all, &@range.mutate)

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
