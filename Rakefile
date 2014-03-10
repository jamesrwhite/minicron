require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'sinatra/activerecord/rake'
require 'minicron/hub/app'

Rake::TaskManager.record_task_metadata = true

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.verbose = true
  t.rspec_opts = '--color --order random'
end

task :default do
  puts `rake --tasks`
end
