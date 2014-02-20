require 'pty'
require 'English'
require 'rainbow/ext/string'
require 'commander'
require 'minicron/version'
require 'minicron/transport'
require 'minicron/transport/client'
require 'minicron/transport/server'

include Commander::UI

module Minicron
  class CLI
    # Sets the basic options for a commander cli instance
    #
    # @param cli [Commander::Runner] a instance of commander runner
    # @option options [Boolean] trace (false) whether or not to enable tracing
    # @return [Commander::Runner] a configured instance of commander runner
    def setup_cli(cli, options)
      # basic information for the help menu
      cli.program :name, 'minicron'
      cli.program :help, 'Author', 'James White <dev.jameswhite+minicron@gmail.com>'
      cli.program :help, 'License', 'GPL v3'
      cli.program :version, Minicron::VERSION
      cli.program :description, 'cli for minicron; a system a to manage and monitor cron jobs'

      # Set the default command to run
      cli.default_command :help

      # Hide --trace and -t from the help menu unless we are told not to
      options[:trace] ? cli.always_trace! : cli.never_trace!

      # Add a global option for verbose mode
      cli.global_option '-V', '--verbose', "Turn on verbose mode. Default: #{Minicron.config[:cli][:verbose]}"

      # Add a global option for passing the path to a config file
      cli.global_option '-c', '--config FILE', 'Set the config file to use'

      cli
    end

    def structured(type, output)
      { :type => type, :output => output }
    end

    # Sets up an instance of commander and runs it based on the argv param
    #
    # @param argv [Array] an array of arguments passed to the cli
    # @option options [Boolean] trace (false) whether or not to enable tracing
    # @yieldparam output [String] output from the cli
    # @raise [ArgumentError] if no arguments are passed to the run cli command
    # i.e when the argv param is ['run']. A second option (the command to execute)
    # should be present in the array
    def run(argv, options = {})
      # Default the options
      options[:trace] ||= false

      # replace ARGV with the contents of argv to aid testability
      ARGV.replace argv

      # Get an instance of commander
      cli = Commander::Runner.new

      # Set some default otions on it
      cli = setup_cli(cli, options)

      # The important part, actually running the command
      cli.command :run do |c|
        c.syntax = "minicron run 'command -option value'"
        c.description = 'Runs the command passed as an argument.'
        c.option '--mode STRING', String, "How to capture the command output, each 'line' or each 'char'? Default: #{Minicron.config[:cli][:mode]}"
        c.option '--dry-run', "Run the command without sending the output to the server.  Default: #{Minicron.config[:cli][:dry_run]}"

        c.action do |args, opts|
          # Check that exactly one argument has been passed
          if args.length != 1
            fail ArgumentError, 'A valid command to run is required! See `minicron help run`'
          end

          # Parse the cli options
          Minicron.parse_cli_config(
            :global => {
              :verbose => opts.verbose
            },
            :cli => {
              :mode => opts.mode,
              :dry_run => opts.dry_run
            }
          )

          unless opts.dry_run
            # Get the Job ID
            job_id = Minicron::Transport.get_job_id(args.first, `hostname -s`.strip)

            # Get a transport instance so we can send data about the job
            transport = Minicron::Transport::Client.new('http://127.0.0.1:9292/faye')
            transport.ensure_em_running
          end

          # Execute the command and yield the output
          run_command(args.first, :mode => Minicron.config[:cli][:mode], :verbose => Minicron.config[:global][:verbose]) do |output|
            # We need to handle the yielded output differently based on it's type
            case output[:type]
            when :status
              transport.publish("job/#{job_id}/status", output[:output]) unless Minicron.config[:cli][:dry_run]
            when :command
              transport.publish("job/#{job_id}/output", output[:output]) unless Minicron.config[:cli][:dry_run]
            end

            yield output[:output] unless output[:type] == :status
          end

          # Block until all the messages have been sent
          transport.ensure_delivery unless Minicron.config[:cli][:dry_run]
        end
      end

      cli.command :server do |c|
        c.syntax = 'minicron server start'
        c.description = 'Starts the minicron server.'
        c.option '--host STRING', String, "The host for the server to listen on. Default: 127.0.0.1"
        c.option '--port STRING', Integer, "How port for the server to listed on. Default: 9292"
        c.option '--path STRING', String, "The path on the host. Default: /faye"

        c.action do |args, opts|
          # Parse the cli options
          Minicron.parse_cli_config(
            :global => {
              :verbose => opts.verbose
            },
            :server => {
              :host => opts.host,
              :port => opts.port,
              :path => opts.path
            }
          )

          # Start the server!
          server = Minicron::Transport::Server.new
          server.start!(
            Minicron.config[:server][:host],
            Minicron.config[:server][:port],
            Minicron.config[:server][:path]
          )
        end
      end

      # And off we go!
      cli.run!
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

      # Spawn a process to run the command
      PTY.spawn(command) do |stdout, stdin, pid|
        # Record the start time of the command
        start = Time.now
        subtract_total = 0

        # yield the start time
        subtract = Time.now
        yield structured :status, "START #{start}"
        subtract_total += Time.now - subtract

        # Output some debug info
        if options[:verbose]
          subtract = Time.now
          yield structured :verbose, '[minicron]'.colour(:magenta)
          yield structured :verbose, ' started running '.colour(:blue) + "`#{command}`".colour(:yellow) + " at #{start}\n\n".colour(:blue)
          subtract_total += Time.now - subtract
        end

        begin
          # Loop until data is no longer being sent to stdout
          until stdout.eof?
            # One character at a time or one line at a time?
            output = options[:mode] == 'char' ? stdout.read(1) : stdout.readline

            subtract = Time.now
            yield structured :command, output
            subtract_total += Time.now - subtract
          end
        # See https://github.com/ruby/ruby/blob/57fb2199059cb55b632d093c2e64c8a3c60acfbb/ext/pty/pty.c#L519
        rescue Errno::EIO
        ensure
          # Force waiting for the process to finish so we can get the exit status
          Process.wait pid
          exit_status = $CHILD_STATUS.exitstatus
        end

        # Record the time the command finished
        finish = Time.now - subtract_total

        # yield the finish time and exit status
        yield structured :status, "FINISH #{finish}"
        yield structured :status, "EXIT #{exit_status}"

        # Output some debug info
        if options[:verbose]
          yield structured :verbose, "\n[minicron]".colour(:magenta)
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
  end
end
