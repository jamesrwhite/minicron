require 'bundler/gem_tasks'

task :install_dev do
  puts `gem uninstall -x minicron && gem build minicron.gemspec && gem install --local ./minicron-*.gem && rm ./minicron-*.gem`
end
