require 'insidious'
require 'rake'
require 'active_record'
require_relative '../../minicron'
require Minicron::REQUIRE_PATH + 'transport'
require Minicron::REQUIRE_PATH + 'transport/server'

module Minicron
  module CLI
    class Commands
      # Add the `minicron db` command
      def self.add_db_cli_command(cli)
        cli.command :db do |c|
          c.syntax = 'minicron db [setup|migrate|version]'
          c.description = 'Sets up the minicron database schema.'

          c.action do |args, opts|
            # Check that exactly one argument has been passed
            if args.length != 1
              raise Minicron::ArgumentError, 'A valid command to run is required! See `minicron help db`'
            end

            # Parse the file and cli config options
            Minicron::CLI.parse_config(opts)

            # Display all the infos please
            ActiveRecord::Migration.verbose = true

            # Adjust the task name for some more friendly tasks
            case args.first
            when 'setup'
              # Remove the database name from the config in case it doesn't exist yet
              Minicron.establish_db_connection(
                Minicron.config['server']['database'].merge('database' => nil),
                Minicron.config['verbose']
              )

              begin
                ActiveRecord::Base.connection.create_database(
                  Minicron.config['server']['database']['database'],
                  charset: 'utf8'
                )
              rescue
              end

              # Then create the initial schema based on schema.rb
              ActiveRecord::Tasks::DatabaseTasks.load_schema(
                Minicron.get_activerecord_db_config(Minicron.config['server']['database']),
                ActiveRecord::Base.schema_format,
                "#{Minicron::DB_PATH}/schema.rb"
              )

              # Open a new connection to our shiny new database now we know it's there for sure
              Minicron.establish_db_connection(
                Minicron.config['server']['database'],
                Minicron.config['verbose']
              )

              # Then run any migrations
              ActiveRecord::Migrator.migrate(Minicron::MIGRATIONS_PATH)
            when 'migrate'
              # Connect to the database
              Minicron.establish_db_connection(
                Minicron.config['server']['database'],
                Minicron.config['verbose']
              )

              # Run any pending migrations
              ActiveRecord::Migrator.migrate(Minicron::MIGRATIONS_PATH)
            when 'version'
              # Connect to the database
              Minicron.establish_db_connection(
                Minicron.config['server']['database'],
                Minicron.config['verbose']
              )

              # Print our the schema version
              puts ActiveRecord::Migrator.current_version
            else
              raise Minicron::ArgumentError, "Unknown argument #{args.first}. See `minicron help db`"
            end
          end
        end
      end

      # Add the `minicron server` command
      def self.add_server_cli_command(cli)
        cli.command :server do |c|
          c.syntax = 'minicron server [start|stop|restart|status]'
          c.description = 'Controls the minicron server.'
          c.option '--host STRING', String, "The host for the server to listen on. Default: #{Minicron.config['server']['host']}"
          c.option '--port STRING', Integer, "How port for the server to listed on. Default: #{Minicron.config['server']['port']}"
          c.option '--path STRING', String, "The path on the host. Default: #{Minicron.config['server']['path']}"
          c.option '--pid_file STRING', String, "The path for daemon's PID file. Default: #{Minicron.config['server']['pid_file']}"

          c.action do |args, opts|
            # Parse the file and cli config options
            Minicron::CLI.parse_config(opts)

            # If we get no arguments then default the action to start
            action = args.first.nil? ? 'start' : args.first

            # Get an instance of insidious and set the pid file
            insidious = Insidious.new(
              pid_file: Minicron.config['server']['pid_file'],
              daemonize: Minicron.config['debug'] == false
            )

            case action
            when 'start'
              insidious.start! do
                # Start the server!
                Minicron::Transport::Server.start!(
                  Minicron.config['server']['host'],
                  Minicron.config['server']['port'],
                  Minicron.config['server']['path']
                )

                # Run the execution monitor (this runs in a separate thread)
                monitor = Minicron::Monitor.new
                monitor.start!
              end
            when 'stop'
              insidious.stop!
            when 'restart'
              insidious.restart! do
                # Run the execution monitor (this runs in a separate thread)
                monitor = Minicron::Monitor.new
                monitor.start!

                # Start the server!
                Minicron::Transport::Server.start!(
                  Minicron.config['server']['host'],
                  Minicron.config['server']['port'],
                  Minicron.config['server']['path']
                )
              end
            when 'status'
              if insidious.running?
                puts 'minicron is running'
              else
                puts 'minicron is not running'
              end
            else
              raise Minicron::ArgumentError, 'Invalid action, expected [start|stop|restart|status]. See `minicron help server`'
            end
          end
        end
      end

      # Add the `minicron config` command
      # @yieldparam output [String] output from the cli
      def self.add_config_cli_command(cli)
        # Add the config command to the cli
        cli.command :config do |c|
          c.syntax = "minicron config"
          c.description = 'Prints out the config minicron is using'

          c.action do |args, opts|
            # Parse the file and cli config options
            Minicron::CLI.parse_config(opts)

            puts JSON.pretty_generate(Minicron.config)
          end
        end
      end
    end
  end
end
