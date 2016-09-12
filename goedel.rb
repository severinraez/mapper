#!/bin/ruby

# DEPENDENCIES
require 'pp'

def require_package(name)
  require_relative 'packages/' + name
end

require_package 'graph/bootstrap'
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
Server = Class.new(Http::Server) do
  @@sentiments = Process::Sentiment.new

  add_route :get, :sentiments, @@sentiments.method(:fetch)
  add_route :post, :sentiments, @@sentiments.method(:create)
end

Server.run!
