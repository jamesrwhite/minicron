# The minicron module
module Minicron
  BINARY_NAME = 'minicron'.freeze
  VERSION = '0.9.7'.freeze
  DEFAULT_CONFIG_FILE = '/etc/minicron.toml'.freeze
  BASE_PATH = File.expand_path('../../../', __FILE__)
  DB_PATH = "#{BASE_PATH}/db".freeze
  MIGRATIONS_PATH = "#{BASE_PATH}/db/migrations".freeze
  LIB_PATH = "#{BASE_PATH}/lib".freeze
  HUB_PATH = "#{BASE_PATH}/lib/minicron/hub".freeze
end
