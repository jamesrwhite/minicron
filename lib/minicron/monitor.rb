autoload :ActiveRecord, 'sinatra/activerecord'
autoload :CronParser,   'parse-cron'

require 'minicron/hub/models/schedule'
require 'minicron/hub/models/execution'

module Minicron
  autoload :Alert,      'minicron/alert'

  # Used to monitor the executions in the database and look for any failures
  # or missed executions based on the schedules minicron knows about
  class Monitor
    def initialize
      @active = false
    end

    # Establishes a database connection
    def setup_db
      case Minicron.config['database']['type']
      when 'mysql'
        # Establish a database connection
        ActiveRecord::Base.establish_connection(
          :adapter => 'mysql2',
          :host => Minicron.config['database']['host'],
          :database => Minicron.config['database']['database'],
          :username => Minicron.config['database']['username'],
          :password => Minicron.config['database']['password']
        )
      when 'sqlite'
        # Calculate the realtive path to the db because sqlite or activerecord is
        # weird and doesn't seem to handle abs paths correctly
        root = Pathname.new(Dir.pwd)
        db = Pathname.new(Minicron::HUB_PATH + '/db')
        db_rel_path = db.relative_path_from(root)

       ActiveRecord::Base.establish_connection(
          :adapter => 'sqlite3',
          :database => "#{db_rel_path}/minicron.sqlite3" # TODO: Allow configuring this but default to this value
        )
      else
        fail Exception, "The database #{Minicron.config['database']['type']} is not supported"
      end

      # Enable ActiveRecord logging if in verbose mode
      ActiveRecord::Base.logger = Minicron.config['verbose'] ? Logger.new(STDOUT) : nil
    end

    # Starts the execution monitor in a new thread
    def start!
      # Activate the monitor
      @active = true

      # Establish a database connection
      setup_db

      # Set the start time of the monitir
      @start_time = Time.now

      # Start a thread for the monitor
      @thread = Thread.new do
        # While the monitor is active run it in a loop ~every minute
        while @active
          # Get all the schedules
          schedules = Minicron::Hub::Schedule.all

          # Loop every schedule we know about
          schedules.each do |schedule|
            begin
              monitor(schedule)
            rescue Exception => e
              if Minicron.config['trace']
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
      # Get an instance of the alert class
      alert = Minicron::Alert.new

      # Parse the cron expression
      cron = CronParser.new(schedule.formatted)

      # Find the time the cron was last expected to run
      expected_at = cron.last(Time.now)
      expected_by = expected_at + 60

      # We only need to check jobs that are expected to under the monitor start time
      # and jobs that have passed their expected by time
      if expected_at > @start_time && Time.now > expected_by
        # Check if this execution was created inside a minute window
        # starting when it was expected to run
        check = Minicron::Hub::Execution.exists?(
          :created_at => expected_at..expected_by,
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
