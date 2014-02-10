require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new 'spec'

task :install_dev do
  puts `gem uninstall -x minicron && gem build minicron.gemspec && gem install --development --local ./minicron-*.gem && rm ./minicron-*.gem`
end
