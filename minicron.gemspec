# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minicron/constants'

Gem::Specification.new do |spec|
  spec.name                  = 'minicron'
  spec.version               = Minicron::VERSION
  spec.authors               = ['James White']
  spec.email                 = ['dev.jameswhite+minicron@gmail.com']
  spec.summary               = 'cli for minicron; a system a to manage and monitor cron jobs'
  spec.description           = %{
    The minicron cli is part of the minicron system that aims to make it easier
    to manage and monitor cron jobs.

    For more info see the project README on GitHub.
  }
  spec.homepage              = 'https://github.com/jamesrwhite/minicron'
  spec.license               = 'GPL-3.0'
  spec.required_ruby_version = '>= 1.9.3'
  spec.post_install_message  = 'Thanks for installing minicron!'

  spec.require_paths = ['lib']
  spec.files         = Dir['Rakefile', 'README.md', 'LICENSE', '{bin,lib,spec}/**/*']
  spec.test_files    = Dir['{spec}/**/*']
  spec.executables  << 'minicron'

  spec.add_runtime_dependency 'rainbow', '~> 2.0'
  spec.add_runtime_dependency 'commander', '~> 4.1', '>= 4.1.6'
  spec.add_runtime_dependency 'thin', '~> 1.6', '>= 1.6.1'
  spec.add_runtime_dependency 'faye', '~> 1.0', '>= 1.0.1'
  spec.add_runtime_dependency 'eventmachine', '~> 1.0', '>= 1.0.3'
  spec.add_runtime_dependency 'toml-rb', '~> 0.1', '>= 0.1.4'
  spec.add_runtime_dependency 'sinatra', '~> 1.4', '>= 1.4.4'
  spec.add_runtime_dependency 'erubis', '~> 2.7'
  spec.add_runtime_dependency 'activerecord', '~> 4.0', '>= 4.0.3'
  spec.add_runtime_dependency 'sinatra-activerecord', '~> 1.3'
  spec.add_runtime_dependency 'sinatra-assetpack', '~> 0.3', '>= 0.3.2'
  spec.add_runtime_dependency 'sass', '~> 3.2', '>= 3.2.14'
  spec.add_runtime_dependency 'oj', '~> 2.6'
  spec.add_runtime_dependency 'sshkey', '~> 1.6', '>= 1.6.1'
  spec.add_runtime_dependency 'net-ssh', '~> 2.8'

  # Databases we want to support
  spec.add_runtime_dependency 'mysql2', '~> 0.3', '>= 0.3.15'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'rspec', '~> 2'
  spec.add_development_dependency 'simplecov', '~> 0.8'
end
