#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'pty'
require 'colored'
require 'commander/import'

VERSION = '0.1.0'

# basic information for the help menu
program :name, 'minicron'
program :help, 'Author', 'James White <dev.jameswhite@gmail.com>'
program :help, 'License', 'GPL v3'
program :version, VERSION
program :description, 'cli for minicron; a system a to manage and monitor cron jobs'

# Set the default command to run
default_command :help

# Hide --trace and -t from the help menu
Commander::Runner.instance.disable_tracing

# The important part, actually running the command
command :run do |c|
  c.syntax = "minicron run 'command -option value'"
  c.description = 'Runs the command passed as an argument.'

  c.action do |args, options|
    # Do some validation on the arguments
    raise ArgumentError.new('A command to run is required! See `minicron help run`') unless args.length === 1

    # Record the start time of the command
    start = Time.now.to_f

    # Output some debug info, TODO: hide this behind a -v option
    print 'started running '.blue
    print "`#{args.first}`".yellow
    puts " at #{start}".blue
    print "`#{args.first}`".yellow
    puts ' output..'.blue
    puts

    # Spawn a process to run the command
    PTY.spawn(args.first) do |stdout, stdin, pid|
      # Loop until data is no longer being sent to stdout
      while !stdout.eof?
        # TODO: allow switching between read modes
        data = stdout.read(1) # One character at a time
        # data = stdout.readline() # One line at a time

        # Print it back out, TODO: hide this behind a -v option
        print data
        STDOUT.flush
      end

      # Force waiting for the process to finish
      Process.wait(pid)

      # Record the time the command finished
      finish = Time.now.to_f

      # Output some debug info, TODO: hide this behind a -v option
      puts
      print 'finished running '.green
      print "`#{args.first}`".yellow
      puts " at #{start}".green
      print 'running '.green
      print "`#{args.first}`".yellow
      puts " took #{finish - start}s".green
      puts "and finished with an exit status code of #{$?.exitstatus}".green
    end
  end
end
