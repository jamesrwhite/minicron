require 'minicron/constants'
require 'active_record'
require 'toml'
require 'stringio'
require 'active_support/core_ext/time'

# @author James White <dev.jameswhite+minicron@gmail.com>
module Minicron
  # Exception classes
  class Error < StandardError; end
  class ArgumentError < Error; end
  class ConfigError < Error; end
  class DatabaseError < Error; end
  class CommandError < Error; end
  class CronError < Error; end
  class ValidationError < Error; end
  class ClientError < Error; end
  class AuthError < Error; end

  # Default configuration, this can be overriden
  @config = {
    'verbose' => false,
    'debug' => false,
    'client' => {
      'server' => {
        'scheme' => 'http',
        'host' => '0.0.0.0',
        'username' => nil,
        'password' => nil,
        'port' => 9292,
        'path' => '/',
        'connect_timeout' => 5,
        'inactivity_timeout' => 5
      },
      'cli' => {
        'mode' => 'line',
        'dry_run' => false
      }
    },
    'server' => {
      'host' => '0.0.0.0',
      'port' => 9292,
      'path' => '/',
      'pid_file' => '/tmp/minicron.pid',
      'timezone' => 'UTC',
      'session' => {
        'name' => 'minicron.session',
        'domain' => '0.0.0.0',
        'path' => '/',
        'ttl' => 86_400,
        'secret' => 'change_me'
      },
      'database' => {
        'type' => 'sqlite'
      }
    },
    'alerts' => {
      'email' => {
        'enabled' => false,
        'smtp' => {
          'address' => 'localhost',
          'port' => 25,
          'domain' => 'localhost.localdomain',
          'user_name' => nil,
          'password' => nil,
          'authentication' => nil,
          'enable_starttls_auto' => true
        }
      },
      'sms' => {
        'enabled' => false
      },
      'pagerduty' => {
        'enabled' => false
      },
      'aws_sns' => {
        'enabled' => false
      },
      'slack' => {
        'enabled' => false
      }
    }
  }

  class << self
    attr_accessor :config
  end

  # Parse the given config file and update the config hash
  #
  # @param file_path [String]
  def self.parse_file_config(file_path)
    file_path ||= Minicron::DEFAULT_CONFIG_FILE

    begin
      @config = TOML.load_file(file_path)
    rescue Errno::ENOENT
      # Fail if the file doesn't exist unless it's the default config file
      if file_path != DEFAULT_CONFIG_FILE
        raise Minicron::ConfigError, "Unable to the load the file '#{file_path}', are you sure it exists?"
      end
    rescue Errno::EACCES
      raise Minicron::ConfigError, "Unable to the read the file '#{file_path}', check it has the right permissions"
    rescue TOML::ParseError
      raise Minicron::ConfigError, "An error occured parsing the config file '#{file_path}', please check it uses valid TOML syntax"
    end
  end

  # Parses the config options from the given hash that matches the expected
  # config format in Minicron.config
  def self.parse_config_hash(options = {}, config = @config)
    options.each do |key, value|
      config[key] = {} if config[key].nil?
      if value.respond_to?(:each)
        parse_config_hash(value, config[key])
      elsif !value.nil?
        config[key] = value
      end
    end
  end

  # Helper function to capture STDOUT and/or STDERR
  # adapted from http://stackoverflow.com/a/11349621/483271
  #
  # @option options [Symbol] type (:both) what to capture: :stdout, :stderr or :both
  # @return [StringIO] if the type was set to :stdout or :stderr
  # @return [Hash] containg both the StringIO instances if the type was set to :both
  def self.capture_output(options = {})
    # Default options
    options[:type] ||= :both

    # Make copies of the origin STDOUT/STDERR
    original_stdout = $stdout
    original_stderr = $stderr

    # Which are we handling?
    case options[:type]
    when :stdout
      $stdout = stdout = StringIO.new
    when :stderr
      $stderr = stderr = StringIO.new
    when :both
      $stderr = $stdout = stdout = stderr = StringIO.new
    else
      raise ArgumentError, 'The type must be one of [stdout, stderr, both]'
    end

    # Yield to the code block to do whatever it has to do
    begin
      yield
    # Whatever happens make sure we reset STDOUT/STDERR
    ensure
      $stdout = original_stdout
      $stderr = original_stderr
    end

    # What are we going to return?
    case options[:type]
    when :stdout
      stdout
    when :stderr
      stderr
    else
      {
        stdout: stdout,
        stderr: stderr
      }
    end
  end

  # Get the system fully qualified domain name
  #
  # @return [String]
  def self.get_fqdn
    `hostname -f`.strip
  end

  # Get the system short hostname
  #
  # @return [String]
  def self.get_hostname
    `hostname -s`.strip
  end

  # Get the user minicron is being run as
  #
  # @return [String]
  def self.get_user
    `whoami`.strip
  end

  # Get the database adapter for the database type
  #
  # @param type [String] database type
  # @return type [String] adapter
  def self.get_db_adapter(type)
    case type
    when 'mysql'
      'mysql2'
    when 'postgresql'
      'postgresql'
    when 'sqlite'
      'sqlite3'
    else
      raise Minicron::DatabaseError, "The database #{type} is not supported"
    end
  end

  # Get the activerecord config hash for the databaes
  #
  # @param type [Hash] database config
  # @return type [String] activerecord database config
  def self.get_activerecord_db_config(config)
    case config['type']
    when /mysql|postgresql/
      {
        adapter: Minicron.get_db_adapter(config['type']),
        host: config['host'],
        database: config['database'],
        username: config['username'],
        password: config['password'],
        reconnect: true
      }
    when 'sqlite'
      # Calculate the realtive path to the db because sqlite or activerecord is
      # weird and doesn't seem to handle abs paths correctly
      root = Pathname.new(Dir.pwd)
      db = Pathname.new(Minicron::BASE_PATH + '/db')
      db_rel_path = db.relative_path_from(root)

      {
        adapter: Minicron.get_db_adapter(config['type']),
        database: "#{db_rel_path}/minicron.sqlite3" # TODO: Allow configuring this but default to this value
      }
    else
      raise Minicron::DatabaseError, "The database #{config['type']} is not supported"
    end
  end

  # Get the activerecord config hash for the databaes
  #
  # @param type [Hash] database config
  def self.establish_db_connection(config, verbose = false)
    # Get the activerecord formatted config
    ar_config = get_activerecord_db_config(config)

    # Connect to the database
    ActiveRecord::Base.establish_connection(ar_config)

    # Enable ActiveRecord logging if in verbose mode
    ActiveRecord::Base.logger = verbose ? Logger.new(STDOUT) : nil
  end

  # Returns a time in the configured server display timezone
  #
  # @param type [Time]
  # @return type [Time]
  def self.time(time)
    unless time.nil?
      return time.in_time_zone(Minicron.config['server']['timezone'])
    end

    time
  end
end
