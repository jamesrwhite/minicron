require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.verbose = true
  t.rspec_opts = '--color --order random'
end

# Tasks for the 'Hub' i.e the rails app
namespace :hub do
  # Add your own tasks in files placed in lib/tasks ending in .rake,
  # for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

  require './lib/minicron/hub/config/application'

  Hub::Application.load_tasks
end
