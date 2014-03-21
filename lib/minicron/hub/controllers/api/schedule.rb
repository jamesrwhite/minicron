require 'minicron/transport/ssh'
require 'minicron/cron'

class Minicron::Hub::App
  # Get all schedules
  # TODO: Add offset/limit
  get '/api/schedules' do
    content_type :json
    schedules = Minicron::Hub::Schedule.all.order(:id => :asc)
                                       .includes({ :job => [:executions, :schedules] })

    ScheduleSerializer.new(schedules).serialize.to_json
  end

  # Get a single schedule by it ID
  get '/api/schedules/:id' do
    content_type :json
    schedule = Minicron::Hub::Schedule.includes({ :job => [:executions, :schedules] }).find(params[:id])
    ScheduleSerializer.new(schedule).serialize.to_json
  end

  # Create a new schedule
  post '/api/schedules' do
    content_type :json
    begin
      # Load the JSON body
      request_body = Oj.load(request.body)

      # First we need to check a schedule like this doesn't already exist
      exists = Minicron::Hub::Schedule.exists?(
        :schedule => request_body['schedule']['schedule'],
        :job_id => request_body['schedule']['job']
      )

      if exists
        raise Exception, "The schedule #{request_body['schedule']['schedule']} already exists for this job"
      end

      Minicron::Hub::Schedule.transaction do
        # Create the new schedule
        schedule = Minicron::Hub::Schedule.create(
          :schedule => request_body['schedule']['schedule'],
          :job_id => request_body['schedule']['job']
        )

        # Get the job and host for the schedule
        job = Minicron::Hub::Job.includes(:host).find(schedule.job_id)

        # Get an ssh instance
        ssh = Minicron::Transport::SSH.new(
          :host => job.host.host,
          :port => job.host.port,
          :private_key => "~/.ssh/minicron_host_#{job.host.id}_rsa"
        )

        # Get an instance of the cron class
        cron = Minicron::Cron.new(ssh)

        # Add the schedule to the crontab
        cron.add_schedule(job, schedule.schedule)

        # And finally save it
        schedule.save!

        # Return the new schedule
        ScheduleSerializer.new(schedule).serialize.to_json
      end
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end

  # Update an existing schedule
  put '/api/schedules/:id' do
    content_type :json
    begin
      # Load the JSON body
      request_body = Oj.load(request.body)

      Minicron::Hub::Schedule.transaction do
        # Find the schedule
        schedule = Minicron::Hub::Schedule.includes({ :job => :host }).find(params[:id])

        # Get an ssh instance
        ssh = Minicron::Transport::SSH.new(
          :host => schedule.job.host.host,
          :port => schedule.job.host.port,
          :private_key => "~/.ssh/minicron_host_#{schedule.job.host.id}_rsa"
        )

        # Get an instance of the cron class
        cron = Minicron::Cron.new(ssh)

        # Update the schedule
        cron.update_schedule(
          schedule.job,
          schedule.schedule,
          request_body['schedule']['schedule']
        )

        # And finally save it
        schedule.schedule = request_body['schedule']['schedule']
        schedule.save!

        # Return the new schedule
        ScheduleSerializer.new(schedule).serialize.to_json
      end
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end

  # Delete an existing schedule
  delete '/api/schedules/:id' do
    content_type :json
    begin
      Minicron::Hub::Schedule.transaction do
        # Find the schedule
        schedule = Minicron::Hub::Schedule.includes({ :job => :host }).find(params[:id])

        # Try and delete the schedule
        Minicron::Hub::Schedule.destroy(params[:id])

        # Get an ssh instance
        ssh = Minicron::Transport::SSH.new(
          :host => schedule.job.host.host,
          :port => schedule.job.host.port,
          :private_key => "~/.ssh/minicron_host_#{schedule.job.host.id}_rsa"
        )

        # Get an instance of the cron class
        cron = Minicron::Cron.new(ssh)

        # Delete the schedule from the crontab
        cron.delete_schedule(schedule.job, schedule.schedule)

        # This is what ember expects as the response
        status 204
      end
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end
end
