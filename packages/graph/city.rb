module Graph; end

class Graph::City
  include Neo4j::ActiveNode

  property :name
  property :latitude, type: Float
  property :longitude, type: Float

  validates :name, presence: true
end
