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

      # Kill the thread when exceptions arne't caught, TODO: should this be removed?
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

    # What to do when a cron didn't run when it was expected to do
    #
    # @param cron a CronParser instance
    # @param schedule [Minicron::Hub::Schedule] a schedule instance
    def handle_missed_schedule(cron, schedule)
      alert = Minicron::Alert.new
      alert.send(:email, 'Yo, stuff be broken.')
    end

    # Starts the execution monitor in a new thread
    def start!
      # Activate the monitor
      @active = true

      # Start a thread for the monitor
      @thread = Thread.new do
        # Establish a database connection
        setup_db

        # While the monitor is active run it in a loop ~every second
        while @active do
          # Get all the schedules
          schedules = Minicron::Hub::Schedule.all

          # Loop every schedule we know about
          schedules.each do |schedule|
            # Parse the cron expression
            cron = CronParser.new(schedule.formatted)

            # Find the time the cron was last expected to run
            last_expected = cron.last(Time.now.utc)

            p "Expected #{schedule.id} to run at #{last_expected}"

            # Check if this execution was created inside a minute window
            # starting when it was expected to run
            check = Minicron::Hub::Execution.exists?(
              :created_at => last_expected..(last_expected + 60),
              :job_id => schedule.job_id
            )

            # If the check failed
            if check == false
              p 'Handling missed schedule..'
              handle_missed_schedule(cron, schedule)
            end
          end

          sleep 5
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
  end
end
