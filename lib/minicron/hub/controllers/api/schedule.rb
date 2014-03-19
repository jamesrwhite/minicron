require 'minicron/transport/ssh'

class Minicron::Hub::App
  # Get all schedules
  # TODO: Add offset/limit
  get '/api/schedules' do
    content_type :json
    schedules = Minicron::Hub::Schedule.all.order(:id => :asc)
                                       .includes(:job)

    ScheduleSerializer.new(schedules).serialize.to_json
  end

  # Get a single schedule by it ID
  get '/api/schedules/:id' do
    content_type :json
    schedule = Minicron::Hub::Schedule.includes(:job).find(params[:id])
    ScheduleSerializer.new(schedule).serialize.to_json
  end

  # Create a new schedule
  post '/api/schedules' do
    content_type :json
    begin
      # Load the JSON body
      request_body = Oj.load(request.body)

      # Create the new schedule
      schedule = Minicron::Hub::Schedule.create(
        :schedule => request_body['schedule']['schedule'],
        :job_id => request_body['schedule']['job']
      )

      Minicron::Hub::Schedule.transaction do
        # Get the job and host for the schedule
        job = Minicron::Hub::Job.includes(:host).find(schedule.job_id)

        # Get an ssh instance and open a connection
        ssh = Minicron::Transport::SSH.new(
          :host => job.host.host,
          :port => job.host.port,
          :private_key => "~/.ssh/minicron_host_#{job.host.id}_rsa"
        )
        conn = ssh.open

        # Prepare the line we are going to write to the crontab
        command = "'" + job.command.gsub(/\\|'/) { |c| "\\#{c}" } + "'"
        line = "#{schedule.schedule} root minicron run #{command}"
        echo_line = "echo \"#{line}\" >> /etc/crontab && echo 'y' || echo 'n'"

        # Append it to the end of the crontab
        write = conn.exec!(echo_line).strip

        # Throw an exception if it failed
        if write != 'y'
          raise Exception, "Unable to write #{line} to the crontab"
        end

        # Check the line is there
        tail = conn.exec!('tail -n 1 /etc/crontab').strip

        # Throw an exception if we can't see our new line at the end of the file
        if tail != line
          raise Exception, "Expected to find #{line} at eof but found #{tail}"
        end

        # And finally save it
        schedule.save!
      end

      # Return the new schedule
      ScheduleSerializer.new(schedule).serialize.to_json
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

      # Find the schedule
      schedule = Minicron::Hub::Schedule.includes(:job).find(params[:id])

      # Update the name and schedule
      schedule.schedule = request_body['schedule']['schedule']

      schedule.save!

      # Return the new schedule
      ScheduleSerializer.new(schedule).serialize.to_json
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end

  # Delete an existing schedule
  delete '/api/schedules/:id' do
    content_type :json
    begin
      # Try and delete the schedule
      Minicron::Hub::Schedule.destroy(params[:id])

      # This is what ember expects as the response
      status 204
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end
end
