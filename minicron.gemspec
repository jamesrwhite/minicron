# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minicron/constants'

Gem::Specification.new do |spec|
  spec.name                  = 'minicron'
  spec.version               = Minicron::VERSION
  spec.authors               = ['James White']
  spec.email                 = ['dev.jameswhite+minicron@gmail.com']
  spec.summary               = 'A system to make it easier to manage and monitor cron jobs'
  spec.homepage              = 'https://github.com/jamesrwhite/minicron'
  spec.license               = 'GPL-3.0'
  spec.post_install_message  = 'Thanks for installing minicron!'

  spec.require_paths = ['lib']
  spec.files         = Dir['Rakefile', 'README.md', 'LICENSE', '{bin,lib,spec}/**/*']
  spec.test_files    = Dir['{spec}/**/*']
  spec.executables  << 'minicron'

  spec.required_ruby_version = '>= 1.9.3'
  spec.requirements << 'libsqlite3-dev or sqlite-devel (sqlite3 dependencies for debian/ubuntu and redhat/centos/fedora respectively)'
  spec.requirements << 'ruby-dev (you may need this to be able to install eventmachine)'
  spec.requirements << 'build-essential (you may need this to be able to install eventmachine)'

  spec.add_runtime_dependency 'rainbow', '~> 2.0'
  spec.add_runtime_dependency 'commander', '~> 4.2'
  spec.add_runtime_dependency 'thin', '~> 1.6', '>= 1.6.1'
  spec.add_runtime_dependency 'faye', '~> 1.0', '>= 1.0.1'
  spec.add_runtime_dependency 'eventmachine', '~> 1.0', '>= 1.0.3'
  spec.add_runtime_dependency 'toml-rb', '~> 0.1', '>= 0.1.4'
  spec.add_runtime_dependency 'sinatra', '~> 1.4', '>= 1.4.4'
  spec.add_runtime_dependency 'erubis', '~> 2.7'
  spec.add_runtime_dependency 'activerecord', '~> 4.0', '>= 4.0.3'
  spec.add_runtime_dependency 'sinatra-activerecord', '~> 1.7'
  spec.add_runtime_dependency 'sinatra-assetpack', '~> 0.3', '>= 0.3.2'
  spec.add_runtime_dependency 'sass', '~> 3.2', '>= 3.2.14'
  spec.add_runtime_dependency 'oj', '~> 2.6'
  spec.add_runtime_dependency 'sshkey', '~> 1.6', '>= 1.6.1'
  spec.add_runtime_dependency 'net-ssh', '~> 2.8'
  spec.add_runtime_dependency 'parse-cron', '~> 0.1', '>= 0.1.4'
  spec.add_runtime_dependency 'mail', '~> 2.5', '>= 2.5.4'
  spec.add_runtime_dependency 'twilio-ruby', '~> 3.1', '>= 3.11.5'
  spec.add_runtime_dependency 'pagerduty', '~> 1.3', '>= 1.3.4'
  spec.add_runtime_dependency 'insidious', '~> 0.3'
  spec.add_runtime_dependency 'escape', '0.0.4'
  spec.add_runtime_dependency 'sqlite3', '~> 1.3', '>= 1.3.8'
  spec.add_runtime_dependency 'em-http-request', '~> 1.1'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.8'
end
