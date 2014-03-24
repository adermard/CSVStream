require "bundler/gem_tasks"
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |i|
  i.test_files = FileList['test/test_*.rb']
  i.verbose = true
end