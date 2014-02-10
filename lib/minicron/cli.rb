require 'minicron/version'
require 'pty'
require 'colored'
require 'commander'

include Commander::UI

module Minicron
  class CLI
    def initialize args
      # replace ARGV with the contents of args to aid testability
      ARGV.replace args

      @commander = Commander::Runner.new
    end

    def run
      # basic information for the help menu
      @commander.program :name, 'minicron'
      @commander.program :help, 'Author', 'James White <dev.jameswhite@gmail.com>'
      @commander.program :help, 'License', 'GPL v3'
      @commander.program :version, Minicron::VERSION
      @commander.program :description, 'cli for minicron; a system a to manage and monitor cron jobs'

      # Set the default command to run
      @commander.default_command :help

      # Hide --trace and -t from the help menu, waiting on commander pull request
      # @commander.disable_tracing

      # Add a global option for verbose mode
      @commander.global_option '--verbose', 'Turn on verbose mode'

      # The important part, actually running the command
      @commander.command :run do |c|
        c.syntax = "minicron run 'command -option value'"
        c.description = 'Runs the command passed as an argument.'
        c.option '--mode STRING', String, "How to capture the command output, each 'line' or each 'char'? Default: line"

        c.action do |args, options|
          # Do some validation on the arguments
          if args.length != 1
            raise ArgumentError.new('A command to run is required! See `minicron help run`')
          end

          # Default the mode to char
          options.default :mode => 'line'

          # Record the start time of the command
          start = Time.now.to_f

          # Output some debug info
          if options.verbose
            yield 'started running '.blue
            yield "`#{args.first}`".yellow
            yield " at #{start}".blue
            yield "`#{args.first}`".yellow
            yield " output..\n\n".blue
          end

          # Spawn a process to run the command
          PTY.spawn(args.first) do |stdout, stdin, pid|
            begin
              # Loop until data is no longer being sent to stdout
              while !stdout.eof?
                # One character at a time or one line at a time?
                data = options.mode === 'char' ? stdout.read(1) : stdout.readline()

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
            if options.verbose
              yield "\nfinished running ".green
              yield "`#{args.first}`".yellow
              yield " at #{start}\n".green
              yield 'running '.green
              yield "`#{args.first}`".yellow
              yield " took #{finish - start}s\n".green
              yield "and finished with an exit status code of #{exit_status}\n".green
            end
          end
        end
      end

      # And off we go!
      @commander.run!
    end
  end
end
