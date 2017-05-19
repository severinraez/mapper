def require_package(name)
  require_relative 'packages/' + name
end

require 'minitest/around/spec'
require 'minitest/autorun'

require "minitest/reporters"

require_package 'graph/bootstrap'

module Test
  class BacktraceFilter < MiniTest::BacktraceFilter
    def filter(bt)
      bt = super(bt)
      bt.reject { |line| line =~ /\.rvm/ }
    end
  end

end

Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new, ENV, Test::BacktraceFilter.new)


def establish_db_connection
  dir_path = File.dirname(__FILE__)
  config_path = dir_path + '/config.test.yml'
  config = YAML.load(File.read(config_path))

  Graph::Bootstrap.new(config['db']).run
end

establish_db_connection


class Minitest::Spec
  around do |test|
    Neo4j::ActiveBase.run_transaction do |tx|
      test.call
      tx.mark_failed
    end
  end
end
