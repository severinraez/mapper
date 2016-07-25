#!/bin/ruby

require 'neo4j'
require 'pp'
require_relative 'packages/graph/city'

dir_path = File.dirname(__FILE__)
config_path = dir_path + '/config.yml'
config = YAML.load(File.read(config_path))

db_config = config['db']

Neo4j::Config['module_handling'] = -> (class_name) {
  # Cut away the Graph::
  raise "What's a #{class_name}" unless class_name[0..6] == "Graph::"
  class_name[7..-1]
}

Neo4j::Session.open(:server_db, db_config.fetch('url'),
                    basic_auth: { username: db_config.fetch('username'), password: db_config.fetch('password') })

# create (c:City {name:'Bern', latitude: 46.9479, longitude: 7.4446})

#c = Graph::City.create(name: 'Teststadt', latitude: 46.9479, longitude: 7.4446)

# match (c:City) with c call spatial.addNode('test_layer', c) yield node return count(*)

nodes = Graph::City.all

class FDSL
  # DATA TYPES

  # Side effects free function
  class Function < Proc
  end

  # Function with side effects
  class ImpureFunction < Function; end

  # SYNTAX

  def f(&block)
    puts 'f called'
    Function.new(&block)
  end

  def f!(&block)
    ImpureFunction.new(&block)
  end

  def run(&block)
  end

  # HELPERS
  def method_missing(name, *method_args, &block)
    metaclass.send :define_method, name do |*args|
      val = instance_exec(*args, &block)
      val
    end

    metaclass.send :define_method, :"_#{name}" do |*args|
      raise 'No arguments expected for a reference' unless args.empty?
      method(name)
    end
  end

  def metaclass
    class << self; self; end
  end

  class BoundEval
    def initialize(binding, dsl)
      @binding = binding
      @dsl = dsl
    end

    def method_missing(name, *args, &block)
      @dsl.method name, *args, &block
    end
  end
end

f = FDSL.new
fi = f # I

# Node -> String
fi.one { |node| node.to_json }
# [Node] -> String
f.many { |nodes| f{ nodes.map(&_one) } }

pass = f.many(nodes)

pp pass.call
