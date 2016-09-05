#!/bin/ruby

# DEPENDENCIES
require 'pp'

def require_package(name)
  require_relative 'packages/' + name
end

require_package 'graph/bootstrap'
require_package 'fdsl/fdsl'
require_package 'process/index'
require_package 'http/server'

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

Server = Class.new(Http::Server) do
  @@sentiments = Process::Sentiment.new(f, fi)

  add_route :get, :sentiments, @@sentiments.method(:fetch)
  add_route :post, :sentiments, @@sentiments.method(:create)
end

Server.run!
