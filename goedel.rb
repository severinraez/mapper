#!/bin/ruby

# DEPENDENCIES
require 'neo4j'
require 'pp'
require 'sinatra'

def require_package(name)
  require_relative 'packages/' + name
end

require_package 'graph/bootstrap'
require_package 'graph/city'
require_package 'fdsl/fdsl'

# CONFIGURATION
dir_path = File.dirname(__FILE__)
config_path = dir_path + '/config.yml'
config = YAML.load(File.read(config_path))

Graph::Bootstrap.new(config['db']).run

# NOTES
# create (c:City {name:'Bern', latitude: 46.9479, longitude: 7.4446})

#c = Graph::City.create(name: 'Teststadt', latitude: 46.9479, longitude: 7.4446)

# match (c:City) with c call spatial.addNode('test_layer', c) yield node return count(*)

# MISSION
f = FDSL.new
fi = f # Impure functions

# Node -> String
fi.one { |node| node.to_json }
# [Node] -> String
f.many { |nodes| f{ nodes.map(&_one) } }

get '/cities' do
  nodes = Graph::City.all
  f.many(nodes).call
end
