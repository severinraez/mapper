#!/bin/ruby

# DEPENDENCIES
require 'neo4j'
require 'pp'
require 'sinatra'
require 'sinatra/param'

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

# As a dsl reminder on how to return a function:
# f.many_json { |nodes| f{ map[json, nodes] } }

# (p, q) -> (a) => p(q(a))
f.compose { |p, q| f { |*args| p[q[*args]] } }
# a -> b
f.json { |obj| obj.to_json }
# (a -> b), [a] -> [b]
f.map { |func, array| array.map(&func) }

# Node -> Hash
f.to_hash { |node| node.as_json(root: false) }
# [Node] => [Hash]
f.many_hash { |nodes| map[to_hash, nodes] }
# [Node] -> String
f.many_json! { compose[json, many_hash] }

set :bind, '0.0.0.0' # Allow access from non-localhost

before do
  response.headers['Access-Control-Allow-Origin'] = '*'

  content_type :json
end

get '/cities' do
  nodes = Graph::City.all
  f.many_json[nodes]

  # ... Graph::City.all.map(&:to_json)
end

post '/cities' do
  param :name, String, required: true
  param :latitude, Float, required: true
  param :longitude, Float, required: true

  name, latitude, longitude = params['name'], params['latitude'], params['longitude']

  node = Graph::City.create(name: name, latitude: latitude, longitude: longitude)

  node.to_json
end
