require 'rake/testtask'

require 'neo4j'
require 'neo4j-core'
load 'neo4j/tasks/migration.rake'

Rake::TestTask.new do |t|
  # t.libs << "test"
  t.test_files = FileList['packages/**/test/*_test.rb']
  t.verbose = false
end
