autoload :Minicron,            'minicron'
autoload :Insidious,           'insidious'
autoload :Rake,                'rake'

module Sinatra
  autoload :ActiveRecordTasks, 'sinatra/activerecord/rake'
end

module Minicron
  autoload :Transport,         'minicron/transport'

  module Transport
    autoload :Client,          'minicron/transport/client'
    autoload :Server,          'minicron/transport/server'
  end

  module Hub
    autoload :App,             'minicron/hub/app'
  end

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
              fail ArgumentError, 'A valid command to run is required! See `minicron help db`'
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
          c.option '--debug', "Enable debug mode. Default: #{Minicron.config['server']['debug']}"

          c.action do |args, opts|
            # Parse the file and cli config options
            Minicron::CLI.parse_config(opts)

            # If we get no arguments then default the action to start
            action = args.first.nil? ? 'start' : args.first

            # Get an instance of insidious and set the pid file
            insidious = Insidious.new(
              :pid_file => '/tmp/minicron.pid',
              :daemonize => Minicron.config['server']['debug'] == false
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
                Minicron.config['server']['path']
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
              fail ArgumentError, 'Invalid action, expected [start|stop|status]. See `minicron help server`'
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
          c.option '--mode STRING', String, "How to capture the command output, each 'line' or each 'char'? Default: #{Minicron.config['cli']['mode']}"
          c.option '--dry-run', "Run the command without sending the output to the server.  Default: #{Minicron.config['cli']['dry_run']}"

          c.action do |args, opts|
            # Check that exactly one argument has been passed
            if args.length != 1
              fail ArgumentError, 'A valid command to run is required! See `minicron help run`'
            end

            # Parse the file and cli config options
            Minicron::CLI.parse_config(opts)

            begin
              # Set up the job and get the job and execution ids
              unless Minicron.config['cli']['dry_run']
                # Get a faye instance so we can send data about the job
                faye = Minicron::Transport::Client.new(
                  Minicron.config['client']['scheme'],
                  Minicron.config['client']['host'],
                  Minicron.config['client']['port'],
                  Minicron.config['client']['path']
                )

                # Set up the job and get the execution and job ids back from the server
                # The execution number is also returned but it's only used by the frontend
                ids = setup_job(args.first, faye)
              end
            rescue Exception => e
              raise Exception, "Unable to setup job, reason: #{e.message}"

              # Ensure that all messages are delivered and that we
              unless Minicron.config['cli']['dry_run']
                faye.tidy_up
              end
            end

            begin
              # Execute the command and yield the output
              Minicron::CLI.run_command(args.first, :mode => Minicron.config['cli']['mode'], :verbose => Minicron.config['verbose']) do |output|
                # We need to handle the yielded output differently based on it's type
                case output[:type]
                when :status
                  unless Minicron.config['cli']['dry_run']
                    faye.send(:job_id => ids[:job_id], :execution_id => ids[:execution_id], :type => :status, :message => output[:output])
                  end
                when :command
                  unless Minicron.config['cli']['dry_run']
                    faye.send(:job_id => ids[:job_id], :execution_id => ids[:execution_id], :type => :output, :message => output[:output])
                  end
                end

                yield output[:output] unless output[:type] == :status
              end
            rescue Exception => e
              # Send the exception message to the server and yield it
              unless Minicron.config['cli']['dry_run']
                faye.send(:job_id => ids[:job_id], :execution_id => ids[:execution_id], :type => :output, :message => e.message)
              end

              raise Exception, e
            ensure
              # Ensure that all messages are delivered and that we
              unless Minicron.config['cli']['dry_run']
                faye.ensure_delivery
                faye.tidy_up
              end
            end
          end
        end
      end

      private

      # Setup a job by sending the SETUP command to the server
      #
      # @param command [String] the job command
      # @param faye a faye client instance
      # @return [Hash] the job_id and execution_id
      def self.setup_job(command, faye)
        # Get the fully qualified domain name of the currnet host
        fqdn = Minicron.get_fqdn

        # Get the md5 hash for the job
        job_hash = Minicron::Transport.get_job_hash(command, fqdn)

        # Fire up eventmachine
        faye.ensure_em_running

        # Setup the job on the server
        ids = faye.setup(
          :job_hash => job_hash,
          :user => Minicron.get_user,
          :command => command,
          :fqdn => fqdn,
          :hostname => Minicron.get_hostname
        )

        # Wait until we get the execution id
        faye.ensure_delivery

        # Return the ids
        ids
      end
    end
  end
end
