#!/bin/ruby

require 'neo4j'
require 'pp'

require_relative 'packages/graph/bootstrap'
require_relative 'packages/graph/city'
require_relative 'packages/fdsl/fdsl'

dir_path = File.dirname(__FILE__)
config_path = dir_path + '/config.yml'
config = YAML.load(File.read(config_path))

Graph::Bootstrap.new(config['db']).run

# create (c:City {name:'Bern', latitude: 46.9479, longitude: 7.4446})

#c = Graph::City.create(name: 'Teststadt', latitude: 46.9479, longitude: 7.4446)

# match (c:City) with c call spatial.addNode('test_layer', c) yield node return count(*)

nodes = Graph::City.all

f = FDSL.new
fi = f # Impure functions

# Node -> String
fi.one { |node| node.to_json }
# [Node] -> String
f.many { |nodes| f{ nodes.map(&_one) } }

pass = f.many(nodes)

pp pass.call