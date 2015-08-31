# The minicron module
module Minicron
  BINARY_NAME = 'minicron'
  VERSION = '0.8.0'
  TRAVELING_RUBY_VERSION = "20150715-2.2.2"
  DEFAULT_CONFIG_FILE = '/etc/minicron.toml'
  BASE_PATH = File.expand_path('../../../', __FILE__)
  LIB_PATH = File.expand_path('../../', __FILE__)
  HUB_PATH = File.expand_path('../../minicron/hub', __FILE__)
end
