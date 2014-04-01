require 'minicron/transport/ssh'
require 'minicron/cron'

class Minicron::Hub::App
  # Get all schedules
  # TODO: Add offset/limit
  get '/api/schedules' do
    content_type :json

    if params[:ids]
      schedules = Minicron::Hub::Schedule.where(:id => params[:ids])
                                         .order(:id => :asc)
                                         .includes({ :job => [:executions, :schedules] })
    else
      schedules = Minicron::Hub::Schedule.all.order(:id => :asc)
                                         .includes({ :job => [:executions, :schedules] })
    end

    Minicron::Hub::ScheduleSerializer.new(schedules).serialize.to_json
  end

  # Get a single schedule by it ID
  get '/api/schedules/:id' do
    content_type :json
    schedule = Minicron::Hub::Schedule.includes({ :job => [:executions, :schedules] }).find(params[:id])
    Minicron::Hub::ScheduleSerializer.new(schedule).serialize.to_json
  end

  # Create a new schedule
  post '/api/schedules' do
    content_type :json
    begin
      # Load the JSON body
      request_body = Oj.load(request.body)

      # First we need to check a schedule like this doesn't already exist
      exists = Minicron::Hub::Schedule.exists?(
        :minute => request_body['schedule']['minute'],
        :hour => request_body['schedule']['hour'],
        :day_of_the_month => request_body['schedule']['day_of_the_month'],
        :month => request_body['schedule']['month'],
        :day_of_the_week => request_body['schedule']['day_of_the_week'],
        :special => request_body['schedule']['special'],
        :job_id => request_body['schedule']['job']
      )

      if exists
        raise Exception, "That schedule already exists for this job"
      end

      Minicron::Hub::Schedule.transaction do
        # Create the new schedule
        schedule = Minicron::Hub::Schedule.create(
          :minute => request_body['schedule']['minute'],
          :hour => request_body['schedule']['hour'],
          :day_of_the_month => request_body['schedule']['day_of_the_month'],
          :month => request_body['schedule']['month'],
          :day_of_the_week => request_body['schedule']['day_of_the_week'],
          :special => request_body['schedule']['special'],
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
        cron.add_schedule(job, schedule.formatted)

        # Tidy up
        ssh.close

        # And finally save it
        schedule.save!

        # Return the new schedule
        Minicron::Hub::ScheduleSerializer.new(schedule).serialize.to_json
      end
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      status 422
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
        schedule = Minicron::Hub::Schedule.includes({ :job => [:executions, :schedules] }).find(params[:id])
        old_schedule = schedule.formatted

        # Get an ssh instance
        ssh = Minicron::Transport::SSH.new(
          :host => schedule.job.host.host,
          :port => schedule.job.host.port,
          :private_key => "~/.ssh/minicron_host_#{schedule.job.host.id}_rsa"
        )

        # Get an instance of the cron class
        cron = Minicron::Cron.new(ssh)

        # Update the instance of the new schedule
        schedule.minute = request_body['schedule']['minute']
        schedule.hour = request_body['schedule']['hour']
        schedule.day_of_the_month = request_body['schedule']['day_of_the_month']
        schedule.month = request_body['schedule']['month']
        schedule.day_of_the_week = request_body['schedule']['day_of_the_week']
        schedule.special = request_body['schedule']['special']

        # Update the schedule
        cron.update_schedule(
          schedule.job,
          old_schedule,
          schedule.formatted
        )

        # Tidy up
        ssh.close

        # And finally save it
        schedule.save!

        # Return the new schedule
        Minicron::Hub::ScheduleSerializer.new(schedule).serialize.to_json
      end
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      status 422
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
        cron.delete_schedule(schedule.job, schedule.formatted)

        # Tidy up
        ssh.close

        # This is what ember expects as the response
        status 204
      end
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      status 422
      { :error => e.message }.to_json
    end
  end
end
