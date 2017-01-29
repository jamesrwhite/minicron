# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

VERSION = "1.0.0".freeze

Gem::Specification.new do |spec|
  spec.name                  = 'minicron'
  spec.version               = VERSION
  spec.authors               = ['James White']
  spec.email                 = ['dev.jameswhite+minicron@gmail.com']
  spec.summary               = 'A system to make it easier to manage and monitor cron jobs'
  spec.homepage              = 'https://github.com/jamesrwhite/minicron'
  spec.license               = 'GPL-3.0'
  spec.post_install_message  = 'Thanks for installing minicron!'

  spec.require_paths = ['lib']
  spec.files         = Dir['Rakefile', 'README.md', 'LICENSE', '{bin,lib,db,spec}/**/*']
  spec.test_files    = Dir['{spec}/**/*']
  spec.executables << 'minicron'

  spec.add_runtime_dependency 'rainbow', '~> 2.2'
  spec.add_runtime_dependency 'commander', '~> 4.4'
  spec.add_runtime_dependency 'thin', '~> 1.7'
  spec.add_runtime_dependency 'toml-rb', '~> 0.3', '>= 0.3.8'
  spec.add_runtime_dependency 'sinatra', '~> 1.4', '>= 1.4.4'
  spec.add_runtime_dependency 'erubis', '~> 2.7'
  spec.add_runtime_dependency 'activerecord', '~> 5.0'
  spec.add_runtime_dependency 'sinatra-assetpack', '0.3.3' # TODO: replace this with something else
  spec.add_runtime_dependency 'sass', '~> 3.2', '>= 3.2.14'
  spec.add_runtime_dependency 'parse-cron', '~> 0.1', '>= 0.1.4'
  spec.add_runtime_dependency 'mail', '~> 2.6'
  spec.add_runtime_dependency 'twilio-ruby', '~> 4.13'
  spec.add_runtime_dependency 'pagerduty', '~> 2.1'
  spec.add_runtime_dependency 'insidious', '~> 0.3'
  spec.add_runtime_dependency 'escape', '0.0.4'
  spec.add_runtime_dependency 'sqlite3', '~> 1.3'
  spec.add_runtime_dependency 'aws-sdk', '~> 2.7'
  spec.add_runtime_dependency 'net-http-persistent', '~> 3.0'
  spec.add_runtime_dependency 'sinatra-contrib', '~> 1.4'
  spec.add_runtime_dependency 'ansi-to-html', '0.0.3'
  spec.add_runtime_dependency 'mysql2', '~> 0.4'
  spec.add_runtime_dependency 'pg', '~> 0.19'
  spec.add_runtime_dependency 'activesupport', '~> 5.0'
  spec.add_runtime_dependency 'sinatra-flash', '0.3.0'
  spec.add_runtime_dependency 'cron2english', '~> 0.1'
  spec.add_runtime_dependency 'slack-notifier', '~> 1.5'
  spec.add_runtime_dependency 'json', '~> 2.0'
  spec.add_runtime_dependency 'warden', '~> 1.2'
  spec.add_runtime_dependency 'scrypt', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.8'
  spec.add_development_dependency 'better_errors', '~> 2.1'
  spec.add_development_dependency 'binding_of_caller', '0.7.3.pre1'
  spec.add_development_dependency 'pry', '~> 0.10.1'
  spec.add_development_dependency 'pry-byebug', '~> 3.1'
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-shell', '~> 0.7'
end
