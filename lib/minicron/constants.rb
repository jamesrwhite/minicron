# The minicron module
module Minicron
<<<<<<< HEAD
  VERSION = '0.7.9'
=======
  BINARY_NAME = 'minicron'
  VERSION = '0.8.3'
>>>>>>> upstream/master
  DEFAULT_CONFIG_FILE = '/etc/minicron.toml'
  BASE_PATH = File.expand_path('../../../', __FILE__)
  LIB_PATH = File.expand_path('../../', __FILE__)
  HUB_PATH = File.expand_path('../../minicron/hub', __FILE__)
end
