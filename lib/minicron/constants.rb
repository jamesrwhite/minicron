module Minicron
  VERSION = '0.1.0'
  DEFAULT_CONFIG_FILE = '/etc/minicron.toml'
  BASE_PATH = File.expand_path('../../../', __FILE__)
  LIB_PATH = File.expand_path('../../', __FILE__)
end
