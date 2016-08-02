module Graph; end

class Graph::Bootstrap
  def initialize(config)
    @config = config
  end

  def run
    Neo4j::Config[:module_handling] = -> (class_name) {
      # Cut away the Graph::o
      raise "What's a #{class_name}" unless class_name[0..6] == "Graph::"
      class_name[7..-1]
    }

    Neo4j::Session.open(:server_db, config.fetch('url'),
                        basic_auth: { username:
                                        config.fetch('username'),
                                      password:
                                        config.fetch('password') })
  end

  private
  attr_accessor :config
end
