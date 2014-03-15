require 'pty'
require 'English'
require 'rainbow/ext/string'
require 'commander'
require 'minicron/constants'
require 'minicron/transport'
require 'minicron/transport/client'
require 'minicron/transport/server'

include Commander::UI

module Minicron
  class CLI
    # Function to the parse the config of the options passed to commands
    #
    # @param opts [Hash] The Commander provided options hash
    def parse_config(opts)
      # Parse the --config file options if it was passed
      Minicron.parse_file_config(opts.config)

      # Parse the cli options
      Minicron.parse_cli_config(
        'global' => {
          'verbose' => opts.verbose
        },
        'cli' => {
          'mode' => opts.mode,
          'dry_run' => opts.dry_run,
          'trace' => opts.trace
        },
        'server' => {
          'scheme' => opts.scheme,
          'host' => opts.host,
          'port' => opts.port,
          'path' => opts.path
        }
      )
    end

    # Used as a helper for yielding command output, returns it in a structured hash
    #
    # @param type [Symbol] The type of command output, currently one of :status, :command and :verbose
    # @param output [String]
    # @return [Hash]
    def structured(type, output)
      { :type => type, :output => output }
    end

    # Sets up an instance of commander and runs it based on the argv param
    #
    # @param argv [Array] an array of arguments passed to the cli
    # @yieldparam output [String] output from the cli
    # @raise [ArgumentError] if no arguments are passed to the run cli command
    # i.e when the argv param is ['run']. A second option (the command to execute)
    # should be present in the array
    def run(argv)
      # replace ARGV with the contents of argv to aid testability
      ARGV.replace(argv)

      # Get an instance of commander
      @cli = Commander::Runner.new

      # Set some default otions on it
      setup_cli

      # Add the run command to the cli
      add_run_cli_command { |output| yield output }

      # Add the server command to the cli
      add_server_cli_command

      # Add the db command to the cli
      add_db_cli_command

      # And off we go!
      @cli.run!
    end

    # Executes a command in a pseudo terminal and yields the output
    #
    # @param command [String] the command to execute e.g 'ls'
    # @option options [String] mode ('line') the method to yield the
    # command output. Either 'line' by line or 'char' by char.
    # @option options [Boolean] verbose whether or not to output extra
    # information for debugging purposes.
    # @yieldparam output [String] output from the command execution
    def run_command(command, options = {})
      # Default the options
      options[:mode] ||= 'line'
      options[:verbose] ||= false

      # Record the start time of the command
      start = Time.now.utc
      subtract_total = 0

      # yield the start time
      subtract = Time.now.utc
      yield structured :status, "START #{start.strftime("%Y-%m-%d %H:%M:%S")}"
      subtract_total += Time.now.utc - subtract

      # Spawn a process to run the command
      begin
        PTY.spawn(command) do |stdout, stdin, pid|

          # Output some debug info
          if options[:verbose]
            subtract = Time.now.utc
            yield structured :verbose, '[minicron]'.colour(:magenta)
            yield structured :verbose, ' started running '.colour(:blue) + "`#{command}`".colour(:yellow) + " at #{start}\n\n".colour(:blue)
            subtract_total += Time.now.utc - subtract
          end

          begin
            # Loop until data is no longer being sent to stdout
            until stdout.eof?
              # One character at a time or one line at a time?
              output = options[:mode] == 'char' ? stdout.read(1) : stdout.readline

              subtract = Time.now.utc
              yield structured :command, output
              subtract_total += Time.now.utc - subtract
            end
          # See https://github.com/ruby/ruby/blob/57fb2199059cb55b632d093c2e64c8a3c60acfbb/ext/pty/pty.c#L519
          rescue Errno::EIO
          ensure
            # Force waiting for the process to finish so we can get the exit status
            Process.wait pid
          end
        end
      rescue Errno::ENOENT
        exit_status = 1

        fail Exception, "Running the command `#{command}` failed, are you sure it exists?"
      ensure
        # Record the time the command finished
        finish = Time.now.utc - subtract_total
        exit_status = $CHILD_STATUS.exitstatus ? $CHILD_STATUS.exitstatus : nil

        # yield the finish time and exit status
        yield structured :status, "FINISH #{finish.strftime("%Y-%m-%d %H:%M:%S")}"
        yield structured :status, "EXIT #{exit_status}"

        # Output some debug info
        if options[:verbose]
          yield structured :verbose, "\n" + "[minicron]".colour(:magenta)
          yield structured :verbose, ' finished running '.colour(:blue) + "`#{command}`".colour(:yellow) + " at #{start}\n".colour(:blue)
          yield structured :verbose, '[minicron]'.colour(:magenta)
          yield structured :verbose, ' running '.colour(:blue) + "`#{command}`".colour(:yellow) + " took #{finish - start}s\n".colour(:blue)
          yield structured :verbose, '[minicron]'.colour(:magenta)
          yield structured :verbose, " `#{command}`".colour(:yellow) + ' finished with an exit status of '.colour(:blue)
          yield structured :verbose, exit_status == 0 ? "#{exit_status}\n".colour(:green) : "#{exit_status}\n".colour(:red)
        end
      end
    end

    # Whether or not coloured output of the rainbox gem is enabled, this is
    # enabled by default
    #
    # @return [Boolean] whether rainbow is enabled or not
    def coloured_output?
      Rainbow.enabled
    end

    # Enable coloured terminal output from the rainbow gem, this is enabled
    # by default
    #
    # @return [Boolean] whether rainbow is enabled or not
    def enable_coloured_output!
      Rainbow.enabled = true
    end

    # Disable coloured terminal output from the rainbow gem, this is enabled
    # by default
    #
    # @return [Boolean] whether rainbow is enabled or not
    def disable_coloured_output!
      Rainbow.enabled = false
    end

    # Sets the basic options for a commander cli instance
    private
    def setup_cli
      # basic information for the help menu
      @cli.program :name, 'minicron'
      @cli.program :help, 'Author', 'James White <dev.jameswhite+minicron@gmail.com>'
      @cli.program :help, 'License', 'GPL v3'
      @cli.program :version, Minicron::VERSION
      @cli.program :description, 'cli for minicron; a system a to manage and monitor cron jobs'

      # Set the default command to run
      @cli.default_command :help

      # Check if --trace was pased or not
      if @cli.instance_variable_get(:@args).include? '--trace'
        Minicron.config['cli']['trace'] = true
      end

      # Add a global option for verbose mode
      @cli.global_option '--verbose', "Turn on verbose mode. Default: #{Minicron.config['cli']['verbose']}" do
        Minicron.config['global']['verbose'] = true
      end

      # Add a global option for passing the path to a config file
      @cli.global_option '--config FILE', 'Set the config file to use'
    end

    # Add the `minicron db` command
    private
    def add_db_cli_command
      @cli.command :db do |c|
        c.syntax = 'minicron db [load|dump]'
        c.description = 'Loads or dumps the minicron database schema.'

        c.action do |args, opts|
          # Check that exactly one argument has been passed
          if args.length != 1
            fail ArgumentError, 'A valid command to run is required! See `minicron help db`'
          end

          # Parse the file and cli config options
          parse_config(opts)

          # These are inlined here because scheme_plus loads the whole of rails -.-
          require 'rake'
          require 'minicron/hub/app'
          require 'sinatra/activerecord/rake'
          require 'schema_plus'

          # Setup the db
          Minicron::Hub::App.setup_db

          # Run the task
          Rake.application['db:schema:' + args.first].invoke
        end
      end
    end

    # Add the `minicron server` command
    private
    def add_server_cli_command
      @cli.command :server do |c|
        c.syntax = 'minicron server'
        c.description = 'Starts the minicron server.'
        c.option '--host STRING', String, "The host for the server to listen on. Default: #{Minicron.config['server']['host']}"
        c.option '--port STRING', Integer, "How port for the server to listed on. Default: #{Minicron.config['server']['port']}"
        c.option '--path STRING', String, "The path on the host. Default: #{Minicron.config['server']['path']}"
        c.option '--connect_timeout INTEGER', Integer, "Default: #{Minicron.config['server']['connect_timeout']}"
        c.option '--inactivity_timeout INTEGER', Integer, "Default: #{Minicron.config['server']['inactivity_timeout']}"

        c.action do |args, opts|
          # Parse the file and @cli config options
          parse_config(opts)

          # Start the server!
          server = Minicron::Transport::Server.new
          server.start!(
            Minicron.config['server']['host'],
            Minicron.config['server']['port'],
            Minicron.config['server']['path']
          )
        end
      end
    end

    # Add the `minicron run [command]` command
    # @yieldparam output [String] output from the cli
    private
    def add_run_cli_command
      # Add the run command to the cli
      @cli.command :run do |c|
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
          parse_config(opts)

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

              # Get the fully qualified domain name of the currnet host
              fqdn = `hostname -f`.strip

              # Get the short hostname of the current host
              hostname = `hostname -s`.strip

              # Get the md5 hash for the job
              job_hash = Minicron::Transport.get_job_hash(args.first, fqdn)

              # Fire up eventmachine
              faye.ensure_em_running

              # Setup the job on the server
              execution_id = faye.setup(job_hash, args.first, fqdn, hostname)

              # Wait until we get the execution id
              faye.ensure_delivery
            end

            # Execute the command and yield the output
            run_command(args.first, :mode => Minicron.config['cli']['mode'], :verbose => Minicron.config['global']['verbose']) do |output|
              # We need to handle the yielded output differently based on it's type
              case output[:type]
              when :status
                unless Minicron.config['cli']['dry_run']
                  faye.send(:job_hash => job_hash, :execution_id => execution_id, :type => :status, :message => output[:output])
                end
              when :command
                unless Minicron.config['cli']['dry_run']
                  faye.send(:job_hash => job_hash, :execution_id => execution_id, :type => :output, :message => output[:output])
                end
              end

              yield output[:output] unless output[:type] == :status
            end
          rescue Exception => e
            # Send the exception message to the server and yield it
            unless Minicron.config['cli']['dry_run']
              faye.send(:job_hash => job_hash, :execution_id => execution_id, :type => :output, :message => e.message)
            end

            fail e
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
  end
end
