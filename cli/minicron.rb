#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'pty'
require 'colored'

# Were we passed a command to run?, TODO: migrate to using a solid cli gem
if ARGV.first
  # Record the start time of the command
  start = Time.now.to_f

  # Output some debug info, TODO: hide this behind a -v option
  print 'started running '.blue
  print "`#{ARGV.first}`".yellow
  puts " at #{start}".blue
  print "`#{ARGV.first}`".yellow
  puts ' output..'.blue
  puts

  # Spawn a process to run the command
  PTY.spawn(ARGV.first) do |stdout, stdin, pid|
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
    print "`#{ARGV.first}`".yellow
    puts " at #{start}".green
    print 'running '.green
    print "`#{ARGV.first}`".yellow
    puts " took #{finish - start}s".green
    puts "and finished with an exit status code of #{$?.exitstatus}".green
  end
else
  # TODO: Add version number and license info
  puts '         _      _                 '
  puts '  __ _  (_)__  (_)__________  ___ '
  puts ' /  \' \/ / _ \/ / __/ __/ _ \/ _ \\'
  puts '/_/_/_/_/_//_/_/\__/_/  \___/_//_/'
  puts '                                  '
end
