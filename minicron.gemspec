# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minicron/version'

Gem::Specification.new do |spec|
  spec.name          = 'minicron'
  spec.version       = Minicron::VERSION
  spec.authors       = ['James White']
  spec.email         = ['dev.jameswhite@gmail.com']
  spec.summary       = %q{cli for minicron; a system a to manage and monitor cron jobs}
  spec.homepage      = 'https://github.com/jamesrwhite/minicron/tree/master/cli'
  spec.license       = 'GPL-3.0'
  spec.executables  << 'minicron'

  spec.files         = ['lib/minicron.rb', 'lib/minicron/cli.rb', 'lib/minicron/version.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.2'

  spec.add_runtime_dependency 'colored', '~> 1.2'
  spec.add_runtime_dependency 'commander', '~> 4.1'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 10.1'
  spec.add_development_dependency 'rspec', '~> 2'
end
