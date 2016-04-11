# The minicron module
module Minicron
  BINARY_NAME = 'minicron'
  VERSION = '0.9.4'
  DEFAULT_CONFIG_FILE = '/etc/minicron.toml'
  BASE_PATH = File.expand_path('../../../', __FILE__)
  DB_PATH = "#{BASE_PATH}/db"
  MIGRATIONS_PATH = "#{BASE_PATH}/db/migrations"
  LIB_PATH = "#{BASE_PATH}/lib"
  HUB_PATH = "#{BASE_PATH}/lib/minicron/hub"
end
