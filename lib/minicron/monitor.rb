require 'active_record'
require 'parse-cron'
require 'minicron/hub/models/schedule'
require 'minicron/hub/models/execution'
require 'minicron/alert'

module Minicron
  # Used to monitor the executions in the database and look for any failures
  # or missed executions based on the schedules minicron knows about
  class Monitor
    def initialize
      @active = false

      # Kill the thread when exceptions arne't caught so we can see the message
      # TODO: should this be removed?
      Thread.abort_on_exception = true
    end

    # Establishes a database connection
    def setup_db
      case Minicron.config['database']['type']
      when 'mysql'
        # Establish a database connection
        ActiveRecord::Base.establish_connection({
          :adapter => 'mysql2',
          :host => Minicron.config['database']['host'],
          :database => Minicron.config['database']['database'],
          :username => Minicron.config['database']['username'],
          :password => Minicron.config['database']['password']
        })
      else
        raise Exception, "The database #{Minicron.config['database']['type']} is not supported"
      end
    end

    # Starts the execution monitor in a new thread
    def start!
      # Activate the monitor
      @active = true

      # Establish a database connection
      setup_db

      # Start a thread for the monitor
      @thread = Thread.new do
        # Delay the start of the monitor loop for a moniter so we don't immediately
        # send an alert for a job the system wasn't 'up' for
        sleep 60

        # While the monitor is active run it in a loop ~every minute
        while @active do
          # Get all the schedules
          schedules = Minicron::Hub::Schedule.all

          # Loop every schedule we know about
          schedules.each do |schedule|
            monitor(schedule)
          end

          sleep 60
        end
      end
    end

    # Stops the execution monitor
    def stop!
      @active = false
      @thread.join
    end

    # Is the execution monitor running?
    def running?
      @active
    end

    private

    # Handle the monitoring of a cron schedule
    #
    # @param schedule [Minicron::Hub::Schedule]
    def monitor(schedule)
      # Get an instance of the alert class
      alert = Minicron::Alert.new

      # Parse the cron expression
      cron = CronParser.new(schedule.formatted)

      # Find the time the cron was last expected to run
      expected_at = cron.last(Time.now.utc)

      # We need to wait until after a minute past the expected run time
      if Time.now.utc > (expected_at + 60)
        # Check if this execution was created inside a minute window
        # starting when it was expected to run
        check = Minicron::Hub::Execution.exists?(
          :created_at => expected_at..(expected_at + 60),
          :job_id => schedule.job_id
        )

        # If the check failed
        unless check
          alert.send_all(
            :kind => 'miss',
            :schedule_id => schedule.id,
            :expected_at => expected_at,
            :job_id => schedule.job_id,
            :expected_at => expected_at
          )
        end
      end
    end
  end
end
