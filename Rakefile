require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

# rspec tests
desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.verbose = true
  t.rspec_opts = '--color --order random'
end

# Show a list of tasks by default
task :default do
  puts `rake --tasks`
end
