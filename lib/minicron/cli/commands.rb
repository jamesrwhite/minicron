require 'minicron'
require 'insidious'
require 'rake'
require 'sinatra/activerecord/rake'
require 'minicron/transport'
require 'minicron/transport/client'
require 'minicron/transport/server'
require 'minicron/hub/app'

module Minicron
  module CLI
    class Commands
      # Add the `minicron db` command
      def self.add_db_cli_command(cli)
        cli.command :db do |c|
          c.syntax = 'minicron db [setup]'
          c.description = 'Sets up the minicron database schema.'

          c.action do |args, opts|
            # Check that exactly one argument has been passed
            if args.length != 1
              raise Minicron::ArgumentError, 'A valid command to run is required! See `minicron help db`'
            end

            # Parse the file and cli config options
            Minicron::CLI.parse_config(opts)

            # Setup the db
            Minicron::Hub::App.setup_db

            # Tell activerecord where the db folder is, it assumes it is in db/
            Sinatra::ActiveRecordTasks.db_dir = Minicron::HUB_PATH + '/db'

            # Adjust the task name
            task = args.first == 'setup' ? 'load' : args.first

            # Run the task
            Rake.application['db:schema:' + task].invoke
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
              :pid_file => Minicron.config['server']['pid_file'],
              :daemonize => Minicron.config['debug'] == false
            )

            case action
            when 'start'
              insidious.start! do
                # Run the execution monitor (this runs in a separate thread)
                monitor = Minicron::Monitor.new
                monitor.start!

                # Start the server!
                Minicron::Transport::Server.start!(
                  Minicron.config['server']['host'],
                  Minicron.config['server']['port'],
                  Minicron.config['server']['path'],
                )
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
              raise Minicron::ArgumentError, 'Invalid action, expected [start|stop|status]. See `minicron help server`'
            end
          end
        end
      end

      # Add the `minicron run [command]` command
      # @yieldparam output [String] output from the cli
      def self.add_run_cli_command(cli)
        # Add the run command to the cli
        cli.command :run do |c|
          c.syntax = "minicron run 'command -option value'"
          c.description = 'Runs the command passed as an argument.'
          c.option '--mode STRING', String, "How to capture the command output, each 'line' or each 'char'? Default: #{Minicron.config['client']['cli']['mode']}"
          c.option '--dry-run', "Run the command without sending the output to the server.  Default: #{Minicron.config['client']['cli']['dry_run']}"

          c.action do |args, opts|
            # Check that exactly one argument has been passed
            if args.length != 1
              raise Minicron::ArgumentError, 'A valid command to run is required! See `minicron help run`'
            end

            # Parse the file and cli config options
            Minicron::CLI.parse_config(opts)

            # Set up the job and get the job and execution ids
            unless Minicron.config['client']['cli']['dry_run']
              # Get a client instance so we can send data about the job
              client = Minicron::Transport::Client.new(
                Minicron.config['client']['server']['scheme'],
                Minicron.config['client']['server']['host'],
                Minicron.config['client']['server']['port'],
                Minicron.config['client']['server']['path']
              )

              # Get the command to run
              command = args.first

              # Get the fully qualified domain name of the current host
              fqdn = Minicron.get_fqdn

              # Get the md5 hash for the job
              job_hash = Minicron::Transport.get_job_hash(command, fqdn)

              # Initialise the job and get the execution and job ids back from the server
              # The execution number is also returned but it's only used by the frontend
              job = client.init(
                job_hash,
                Minicron.get_user,
                command,
                fqdn,
                Minicron.get_hostname,
                Time.now.utc.to_i
              )
            end

            begin
              # Execute the command and yield the output
              Minicron::CLI.run_command(args.first, :mode => Minicron.config['client']['cli']['mode'], :verbose => Minicron.config['verbose']) do |output|
                # We need to handle the yielded output differently based on it's type
                case output[:type]
                when :start
                  unless Minicron.config['client']['cli']['dry_run']
                    client.start(
                      job[:job_id],
                      job[:execution_id],
                      output[:output]
                    )
                  end
                when :finish
                  unless Minicron.config['client']['cli']['dry_run']
                    client.finish(
                      job[:job_id],
                      job[:execution_id],
                      output[:output]
                    )
                  end
                when :exit
                  unless Minicron.config['client']['cli']['dry_run']
                    client.exit(
                      job[:job_id],
                      job[:execution_id],
                      output[:output]
                    )
                  end
                when :output
                  unless Minicron.config['client']['cli']['dry_run']
                    client.output(
                      job[:job_id],
                      job[:execution_id],
                      output[:output]
                    )
                  end
                end

                # Yield the output unless it's a status message
                yield output[:output] unless [:start, :finish, :exit].include?(output[:type])
              end
            rescue Exception => e
              # Send the exception message to the server and yield it
              unless Minicron.config['client']['cli']['dry_run']
                client.output(
                  job[:job_id],
                  job[:execution_id],
                  e.message
                )
              end

              raise Minicron::CommandError, e
            end
          end
        end
      end
    end
  end
end
