#!/bin/ruby

require 'neo4j'
require 'pp'

dir_path = File.dirname(__FILE__)
config_path = dir_path + '/config.yml'
config = YAML.load(File.read(config_path))

db_config = config['db']
pp db_config
Neo4j::Session.open(:server_db, db_config.fetch('url'),
                    basic_auth: { username: db_config.fetch('username'), password: db_config.fetch('password') })

