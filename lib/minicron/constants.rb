# The minicron module
module Minicron
  BINARY_NAME = 'minicron'.freeze
  VERSION = '1.0.0'.freeze
  DEFAULT_CONFIG_FILE = '/etc/minicron.toml'.freeze
  BASE_PATH = File.expand_path('../../../', __FILE__)
  DB_PATH = "#{BASE_PATH}/db".freeze
  MIGRATIONS_PATH = "#{BASE_PATH}/db/migrations".freeze
  LIB_PATH = "#{BASE_PATH}/lib".freeze
  REQUIRE_PATH = "#{BASE_PATH}/lib/minicron/".freeze
  HUB_PATH = "#{BASE_PATH}/lib/minicron/hub".freeze
end
