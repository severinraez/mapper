def require_package(name)
  require_relative 'packages/' + name
end

require 'minitest/autorun'
require 'graph/bootstrap'

dir_path = File.dirname(__FILE__)
config_path = dir_path + '/config.test.yml'
Graph::Bootstrap.new(config['db']).run

class Minitest::Spec
  DatabaseCleaner.strategy = :transaction

  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end
end
