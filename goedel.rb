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

  get('/sentiments') do

    FDSL.with_libs(Web::Functions, FDSL::Functions) do
      compose(
        validate(
          params,
          ( [:latitude, Float, required: true],
            [:longitude, Float, required: true],
            [:range, Float, required: false] ) ),
        query(
          pass_params(Graph::Sentiment.all, []),
          pass_params(location, :latitude, :longitude),
          pass_params(range, :range) ),
        nodes_json
      ).call
    end
  end

  post('/sentiments') do
    f.compose[
      Web::Functions.validate[
        params,
        [
          [:name, String, required: true],
          [:latitude, Float, required: true],
          [:longitude, Float, required: true]
        ] ],
      Sentiments::Functions.create,
      API::Render.result_json
    ][]
  end
end

Server.run!
