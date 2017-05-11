def require_package(name)
  require_relative 'packages/' + name
end

require 'minitest/around/spec'
require 'minitest/autorun'

require_package 'graph/bootstrap'

dir_path = File.dirname(__FILE__)
config_path = dir_path + '/config.test.yml'
config = YAML.load(File.read(config_path))

Graph::Bootstrap.new(config['db']).run

class Minitest::Spec
  around do |test|
    Neo4j::Transaction.run do |tx|
      test.call
      tx.mark_failed
    end
  end
end
