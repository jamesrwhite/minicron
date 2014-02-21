# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minicron/version'

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
  spec.homepage              = 'https://github.com/jamesrwhite/minicron/tree/master/cli'
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

  # Rails
    spec.add_runtime_dependency 'rails', '~> 4.0', '>= 4.0.3'
    # Use sqlite3 as the database for Active Record
    spec.add_runtime_dependency 'sqlite3'
    # Use SCSS for stylesheets
    spec.add_runtime_dependency 'sass-rails', '~> 4.0.0'
    # Use Uglifier as compressor for JavaScript assets
    spec.add_runtime_dependency 'uglifier', '>= 1.3.0'
    # Use jquery as the JavaScript library
    spec.add_runtime_dependency 'jquery-rails'
    # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
    spec.add_runtime_dependency 'turbolinks'
    # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
    spec.add_runtime_dependency 'jbuilder', '~> 1.2'
    # Use ActiveModel has_secure_password
    spec.add_runtime_dependency 'bcrypt-ruby', '~> 3.1.2'
  # End Rails

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'rspec', '~> 2'
  spec.add_development_dependency 'simplecov', '~> 0.8'
  spec.add_development_dependency 'webmock', '~> 1.7', '>= 1.7.3'
end
