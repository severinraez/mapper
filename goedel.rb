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
require_package 'fdsl/fdsl'

# CONFIGURATION
# Load config into file.
dir_path = File.dirname(__FILE__)
config_path = dir_path + '/config.yml'
config = YAML.load(File.read(config_path))

Graph::Bootstrap.new(config['db']).run

# NOTES
# create (c:Sentiment {name:'Bern', latitude: 46.9479, longitude: 7.4446})

#c = Graph::Sentiment.create(name: 'Teststadt', latitude: 46.9479, longitude: 7.4446)

# match (c:Sentiment) with c call spatial.addNode('test_layer', c) yield node return count(*)

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

# FLOW TRAITS
# Should be helper methods
def has_range
  @range = Graph::Query::Range.new(params[:range])
end

def returns_json(type)
  @result =
    case type
    when :many
      f.many_json[@result]
    when :one
      f.json[@result]
    end
  raise "Unknown type #{type.inspect}"
end

def persists_and_renders
  @result=f.json[@result]
end

# SHADOW SINATRA HELPERS
# 
sinatra_get=method(:get)

def get *args, &block
  sinatra_get *args do
    yield

    render @result
  end
end

get '/sentiments' do
  has_range

  @result = fi.inject(Graph::Sentiment.all, &@range.mutate)

  returns_json(:many)
end

post '/sentiments' do
  param :name, String, required: true
  param :latitude, Float, required: true
  param :longitude, Float, required: true

  name, latitude, longitude = params['name'], params['latitude'], params['longitude']

  @result = Graph::Sentiment.create(name: name, latitude: latitude, longitude: longitude)

  persists_and_renders
end
