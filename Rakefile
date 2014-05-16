require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'sinatra/activerecord/rake'
require 'minicron/constants'
require 'minicron/hub/app'

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

namespace :db do
  # Tell active record where the db dir is
  Sinatra::ActiveRecordTasks.db_dir = Minicron::HUB_PATH + '/db'

  # Parse the file config in /etc/minicron.toml
  Minicron.parse_file_config(nil)

  # Connect to the DB
  Minicron::Hub::App.setup_db
end
