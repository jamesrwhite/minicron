require 'minicron/version'
require 'pty'
require 'colored'
require 'commander'

include Commander::UI

module Minicron
  class CLI
    def run argv, options = {}
      # Default the options
      options[:trace] ||= false

      # replace ARGV with the contents of arv to aid testability
      ARGV.replace argv

      # Get an instance of commander
      cli = Commander::Runner.new

      # basic information for the help menu
      cli.program :name, 'minicron'
      cli.program :help, 'Author', 'James White <dev.jameswhite@gmail.com>'
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
          # Do some validation on the arguments
          if args.length != 1
            raise ArgumentError.new('A command to run is required! See `minicron help run`')
          end

          # Default the mode to char
          opts.default mode: 'line'

          # Execute the command and yield the output
          run_command args.first, mode: opts.mode, verbose: opts.verbose do |output|
            yield output
          end
        end
      end

      # And off we go!
      cli.run!
    end

    def run_command command, options = {}
      # Default the options
      options[:mode] ||= 'line'
      options[:verbose] ||= false

      # Record the start time of the command
      start = Time.now.to_f

      # Output some debug info
      if options[:verbose]
        yield 'started running '.blue
	yield "`#{command}`".yellow
        yield " at #{start}".blue
	yield "`#{command}`".yellow
        yield " output..\n\n".blue
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
        finish = Time.now.to_f

        # Output some debug info
        if options[:verbose]
          yield "\nfinished running ".green
          yield "`#{command}`".yellow
          yield " at #{start}\n".green
          yield 'running '.green
          yield "`#{command}`".yellow
          yield " took #{finish - start}s\n".green
          yield "and finished with an exit status code of #{exit_status}\n".green
        end
      end
    end
  end
end
