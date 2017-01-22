class Minicron::Hub::App
  get '/jobs' do
    # Look up all the jobs
    @jobs = Minicron::Hub::Job.all.order(created_at: :desc).includes(:host, :executions)

    erb :'jobs/index', layout: :'layouts/app'
  end

  get '/job/:id' do
    # Look up the job
    @job = Minicron::Hub::Job.includes(:host, :executions, :schedules)
                             .order('executions.number DESC')
                             .find(params[:id])

    erb :'jobs/show', layout: :'layouts/app'
  end

  get '/jobs/new' do
    # Empty instance to simplify views
    @previous = Minicron::Hub::Job.new

    # All the hosts for the select dropdown
    @hosts = Minicron::Hub::Host.all

    erb :'jobs/new', layout: :'layouts/app'
  end

  post '/jobs/new' do
    # All the hosts for the select dropdown
    @hosts = Minicron::Hub::Host.all

    begin
      # First we need to look up the host
      host = Minicron::Hub::Host.find(params[:host])

      # Try and save the new job
      job = Minicron::Hub::Job.create!(
        job_hash: Minicron::Transport.get_job_hash(params[:command], host.fqdn),
        name: params[:name],
        command: params[:command],
        host_id: host.id
      )

      # Save the job before we look up the hosts jobs so it's changes are there
      job.save!

      # Look up the host and its jobs and job schedules
      host = Minicron::Hub::Host.includes(jobs: :schedules).find(job.host.id)

      # Redirect to the new job
      redirect "#{route_prefix}/job/#{job.id}"
    rescue Exception => e
      @previous = params
      flash.now[:error] = e.message
      erb :'jobs/new', layout: :'layouts/app'
    end
  end

  get '/job/:id/edit' do
    # Find the job
    @job = Minicron::Hub::Job.includes(:host).find(params[:id])

    # All the hosts for the select dropdown
    @hosts = Minicron::Hub::Host.all

    erb :'jobs/edit', layout: :'layouts/app'
  end

  post '/job/:id/edit' do
    # All the hosts for the select dropdown
    @hosts = Minicron::Hub::Host.all

    begin
      Minicron::Hub::Job.transaction do
        # Find the job
        @job = Minicron::Hub::Job.includes(:host, :schedules).find(params[:id])

        # Update the name and command
        @job.name = params[:name]
        @job.command = params[:command]

        # Update the job on the remote if the user/command has changed
        # Rehash the job command
        @job.job_hash = Minicron::Transport.get_job_hash(@job.command, @job.host.fqdn)

        # Save the job before we look up the hosts jobs so it's changes are there
        @job.save!

        # Look up the host and its jobs and job schedules
        host = Minicron::Hub::Host.includes(jobs: :schedules).find(@job.host.id)

        # Redirect to the updated job
        redirect "#{route_prefix}/job/#{@job.id}"
      end
    rescue Exception => e
      @job.restore_attributes
      flash.now[:error] = e.message
      erb :'jobs/edit', layout: :'layouts/app'
    end
  end

  post '/job/:id/status/:status' do
    # Find the job
    @job = Minicron::Hub::Job.includes(:host, :executions, :schedules)
                             .order('executions.number DESC')
                             .find(params[:id])

    begin
      Minicron::Hub::Job.transaction do
        # Set if the job is enabled or not
        enabled = if params[:status] == 'enable'
                    true
                  elsif params[:status] == 'disable'
                    false
                  else
                    params[:status] # this will get caught by the AR validation
                  end

        # Update the name and user
        @job.enabled = enabled

        # Save the job before we look up the hosts jobs so it's changes are there
        @job.save!

        # Look up the host and its jobs and job schedules
        host = Minicron::Hub::Host.includes(jobs: :schedules).find(@job.host.id)

        # Redirect to the updated job
        redirect "#{route_prefix}/job/#{@job.id}"
      end
    rescue Exception => e
      @job.restore_attributes
      flash.now[:error] = e.message
      erb :'jobs/show', layout: :'layouts/app'
    end
  end

  get '/job/:id/delete' do
    # Look up the job
    @job = Minicron::Hub::Job.find(params[:id])

    erb :'jobs/delete', layout: :'layouts/app'
  end

  post '/job/:id/delete' do
    # Look up the job
    @job = Minicron::Hub::Job.includes(:schedules).find(params[:id])

    begin
      Minicron::Hub::Job.transaction do
        # Try and delete the job
        Minicron::Hub::Job.destroy(params[:id])

        # Look up the host and its jobs and job schedules
        host = Minicron::Hub::Host.includes(jobs: :schedules).find(@job.host.id)

        redirect "#{route_prefix}/jobs"
      end
    rescue Exception => e
      flash.now[:error] = "<h4>Error</h4>
                            <p>#{e.message}</p>
                            <p>You can force delete the job without connecting to the host</p>"
      erb :'jobs/delete', layout: :'layouts/app'
    end
  end

  get '/job/:job_id/schedule/:schedule_id' do
    # Look up the schedule
    @schedule = Minicron::Hub::Schedule.includes(:job).find(params[:schedule_id])

    # Look up the job
    @job = @schedule.job

    erb :'jobs/schedules/show', layout: :'layouts/app'
  end

  get '/job/:job_id/schedules/new' do
    # Empty instance to simplify views
    @previous = Minicron::Hub::Schedule.new

    # Look up the job
    @job = Minicron::Hub::Job.find(params[:job_id])

    erb :'jobs/schedules/new', layout: :'layouts/app'
  end

  post '/job/:job_id/schedules/new' do
    # Look up the job
    @job = Minicron::Hub::Job.includes(:host, :schedules).find(params[:job_id])

    begin
      # First we need to check a schedule like this doesn't already exist
      exists = Minicron::Hub::Schedule.exists?(
        minute: params[:minute].empty? ? nil : params[:minute],
        hour: params[:hour].empty? ? nil : params[:hour],
        day_of_the_month: params[:day_of_the_month].empty? ? nil : params[:day_of_the_month],
        month: params[:month].empty? ? nil : params[:month],
        day_of_the_week: params[:day_of_the_week].empty? ? nil : params[:day_of_the_week],
        special: params[:special].empty? ? nil : params[:special],
        job_id: params[:job_id].empty? ? nil : params[:job_id]
      )

      if exists
        raise Minicron::ValidationError, 'That schedule already exists for this job'
      end

      # Create the new schedule
      schedule = Minicron::Hub::Schedule.create(
        minute: params[:minute].empty? ? nil : params[:minute],
        hour: params[:hour].empty? ? nil : params[:hour],
        day_of_the_month: params[:day_of_the_month].empty? ? nil : params[:day_of_the_month],
        month: params[:month].empty? ? nil : params[:month],
        day_of_the_week: params[:day_of_the_week].empty? ? nil : params[:day_of_the_week],
        special: params[:special].empty? ? nil : params[:special],
        job_id: params[:job_id]
      )

      schedule.save!

      # Look up the host
      host = Minicron::Hub::Host.includes(jobs: :schedules).find(@job.host.id)

      # Redirect to the updated job
      redirect "#{route_prefix}/job/#{@job.id}"
    rescue Exception => e
      flash.now[:error] = e.message
      erb :'jobs/schedules/new', layout: :'layouts/app'
    end
  end

  get '/job/:job_id/schedule/:schedule_id/edit' do
    # Look up the schedule
    @schedule = Minicron::Hub::Schedule.includes(:job).find(params[:schedule_id])

    # Look up the job
    @job = Minicron::Hub::Job.find(params[:job_id])

    erb :'jobs/schedules/edit', layout: :'layouts/app'
  end

  post '/job/:job_id/schedule/:schedule_id/edit' do
    # Look up the schedule and job
    @schedule = Minicron::Hub::Schedule.includes(job: :host).find(params[:schedule_id])

    begin
      # To keep the view similar to #new store the job here
      @job = @schedule.job

      Minicron::Hub::Schedule.transaction do
        old_schedule = @schedule.formatted

        # Update the instance of the new schedule
        @schedule.minute = params[:minute].empty? ? nil : params[:minute]
        @schedule.hour = params[:hour].empty? ? nil : params[:hour]
        @schedule.day_of_the_month = params[:day_of_the_month].empty? ? nil : params[:day_of_the_month]
        @schedule.month = params[:month].empty? ? nil : params[:month]
        @schedule.day_of_the_week = params[:day_of_the_week].empty? ? nil : params[:day_of_the_week]
        @schedule.special = params[:special].empty? ? nil : params[:special]

        # Save the schedule before looking up the hosts jobs => schedule so the change is there
        @schedule.save!

        # Look up the host and its jobs and job schedules
        host = Minicron::Hub::Host.includes(jobs: :schedules).find(@job.host.id)

        # Redirect to the updated job
        redirect "#{route_prefix}/job/#{@schedule.job.id}"
      end
    rescue Exception => e
      @schedule.restore_attributes
      flash.now[:error] = e.message
      erb :'jobs/schedules/edit', layout: :'layouts/app'
    end
  end

  get '/job/:id/schedule/:schedule_id/delete' do
    # Look up the schedule
    @schedule = Minicron::Hub::Schedule.includes(:job).find(params[:schedule_id])

    erb :'jobs/schedules/delete', layout: :'layouts/app'
  end

  post '/job/:id/schedule/:schedule_id/delete' do
    # Find the schedule
    @schedule = Minicron::Hub::Schedule.includes(job: :host).find(params[:schedule_id])

    begin
      Minicron::Hub::Schedule.transaction do
        # Try and delete the schedule
        Minicron::Hub::Schedule.destroy(params[:schedule_id])

        # Look up the host and its jobs and job schedules
        host = Minicron::Hub::Host.includes(jobs: :schedules).find(@schedule.job.host.id)

        redirect "#{route_prefix}/job/#{@schedule.job.id}"
      end
    rescue Exception => e
      flash.now[:error] = "<h4>Error</h4>
                            <p>#{e.message}</p>
                            <p>You can force delete the schedule without connecting to the host</p>"
      erb :'jobs/schedules/delete', layout: :'layouts/app'
    end
  end
end
