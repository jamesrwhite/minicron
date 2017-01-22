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
    end

    # Starts the execution monitor in a new thread
    def start!
      # Activate the monitor
      @active = true

      # Connect to the database
      Minicron.establish_db_connection(
        Minicron.config['server']['database'],
        Minicron.config['verbose']
      )

      # Set the start time of the monitir
      @start_time = Time.now.utc

      # Start a thread for the monitor
      @thread = Thread.new do
        # While the monitor is active run it in a loop ~every minute
        while @active
          # Get all the schedules
          schedules = Minicron::Hub::Schedule.all

          # Loop every schedule we know about
          schedules.each do |schedule|
            begin
              # TODO: is it possible to monitor on boot schedules some other way?
              monitor(schedule) unless schedule.special == '@reboot'
            rescue Exception => e
              if Minicron.config['debug']
                puts e.message
                puts e.backtrace
              end
            end
          end

          sleep 59
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
      # Parse the cron expression
      cron = CronParser.new(schedule.formatted)

      # Find the time the cron was last expected to run with a 30 second pre buffer
      # and a 30 second post buffer (in addition to the 60 already in place) incase
      # jobs run early/late to allow for clock sync differences between client/hub
      expected_at = cron.last(Time.now.utc) - 30
      expected_by = expected_at + 30 + 60 + 30 # pre buffer + minute wait + post buffer

      # We only need to check jobs that are expected after the monitor start time
      # and jobs that have passed their expected by time and the time the schedule
      # was last updated isn't before when it was expected, i.e we aren't checking for something
      # that should have happened earlier in the day.
      if expected_at > @start_time && Time.now.utc > expected_by && expected_by > schedule.updated_at
        # Check if this execution was created inside a minute window
        # starting when it was expected to run
        check = Minicron::Hub::Execution.exists?(
          created_at: expected_at..expected_by,
          job_id: schedule.job_id
        )

        # If the check failed
        unless check
          Minicron::Alert.send_all(
            kind: 'miss',
            schedule_id: schedule.id,
            expected_at: expected_at,
            job_id: schedule.job_id
          )
        end
      end
    end
  end
end
