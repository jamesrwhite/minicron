require 'minicron/version'
require 'pty'
require 'rainbow/ext/string'
require 'commander'

include Commander::UI

module Minicron
  # @author James White <dev.jameswhite+minicron@gmail.com>
  class CLI
    # Sets up an instance of commander and runs it based on the argv param
    #
    # @param argv [Array] an array of arguments passed to the cli
    # @option options [Boolean] trace (false) whether or not to enable tracing
    # @yieldparam output [String] output from the cli
    # @raise [ArgumentError] if no arguments are passed to the run cli command
    # i.e when the argv param is ['run']. A second option (the command to execute)
    # should be present in the array
    def run argv, options = {}
      # Default the options
      options[:trace] ||= false

      # replace ARGV with the contents of arv to aid testability
      ARGV.replace argv

      # Get an instance of commander
      cli = Commander::Runner.new

      # basic information for the help menu
      cli.program :name, 'minicron'
      cli.program :help, 'Author', 'James White <dev.jameswhite+minicron@gmail.com>'
      cli.program :help, 'License', 'GPL v3'
      cli.program :version, Minicron::VERSION
      cli.program :description, 'cli for minicron; a system a to manage and monitor cron jobs'

      # Set the default command to run
      cli.default_command :help

      # Hide --trace and -t from the help menu unless we are told not to
      if options[:trace] then cli.always_trace! else cli.never_trace! end

      # Add a global option for verbose mode
      cli.global_option '--verbose', 'Turn on verbose mode'

      # The important part, actually running the command
      cli.command :run do |c|
        c.syntax = "minicron run 'command -option value'"
        c.description = 'Runs the command passed as an argument.'
        c.option '--mode STRING', String, "How to capture the command output, each 'line' or each 'char'? Default: line"

        c.action do |args, opts|
          # Check that exactly one argument has been passed
          if args.length != 1
            raise ArgumentError.new('A valid command to run is required! See `minicron help run`')
          end

          # Default the mode to char
          opts.default mode: 'line'

          # Execute the command and yield the output
          run_command args.first, :mode => opts.mode, :verbose => opts.verbose do |output|
            yield output
          end
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
    def run_command command, options = {}
      # Default the options
      options[:mode] ||= 'line'
      options[:verbose] ||= false

      # Record the start time of the command
      start = Time.now

      # Output some debug info
      if options[:verbose]
        yield '[minicron]'.colour(:magenta)
        yield ' started running '.colour(:blue) + "`#{command}`".colour(:yellow) + " at #{start}\n\n".colour(:blue)
      end

      # Spawn a process to run the command
      PTY.spawn(command) do |stdout, stdin, pid|
        begin
          # Loop until data is no longer being sent to stdout
          while !stdout.eof?
            # One character at a time or one line at a time?
            data = options[:mode] === 'char' ? stdout.read(1) : stdout.readline()

            # Print it back out
            yield data
          end
        # See https://github.com/ruby/ruby/blob/57fb2199059cb55b632d093c2e64c8a3c60acfbb/ext/pty/pty.c#L519
        rescue Errno::EIO
        ensure
          # Force waiting for the process to finish so we can get the exit status
          Process.wait pid
          exit_status = $?.exitstatus
        end

        # Record the time the command finished
        finish = Time.now

        # Output some debug info
        if options[:verbose]
          yield "\n[minicron]".colour(:magenta)
          yield " finished running ".colour(:blue) + "`#{command}`".colour(:yellow) + " at #{start}\n".colour(:blue)
          yield '[minicron]'.colour(:magenta)
          yield ' running '.colour(:blue) + "`#{command}`".colour(:yellow) + " took #{finish - start}s\n".colour(:blue)
          yield '[minicron]'.colour(:magenta)
          yield " `#{command}`".colour(:yellow) + " finished with an exit status of ".colour(:blue)
          yield exit_status == 0 ? "#{exit_status}\n".colour(:green) : "#{exit_status}\n".colour(:red)
        end
      end
    end
  end
end
