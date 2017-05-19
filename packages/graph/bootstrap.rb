require 'neo4j'
require 'neo4j-core'
require 'neo4j/core/cypher_session/adaptors/http'

require 'neo4j/core/cypher_session/adaptors/bolt'


module Graph; end

require_relative 'sentiment'

class Graph::Bootstrap
  def initialize(config)
    @config = config
  end

  def run
    Neo4j::Config[:module_handling] = -> (class_name) {
      # Cut away the Graph::
      raise "What's a #{class_name}" unless class_name[0..6] == "Graph::"
      class_name[7..-1]
    }

    Neo4j::ActiveBase.on_establish_session do
      adaptor = Neo4j::Core::CypherSession::Adaptors::Bolt.new(db_url, wrap_level: :proc)
      Neo4j::Core::CypherSession.new(adaptor)
    end

  end

  private

  def db_url
    "bolt://#{config.fetch('username')}:#{config.fetch('password')}@#{config.fetch('host')}:#{config.fetch('port')}"
  end

  private
  attr_accessor :config
end
