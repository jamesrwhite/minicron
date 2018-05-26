class Minicron::Hub::App
  get '/jobs' do
    @jobs = Minicron::Hub::Model::Job.belonging_to(current_user)
                                     .all
                                     .order(created_at: :desc)

    erb :'jobs/index', layout: :'layouts/app'
  end

  get '/job/:id' do
    @job = Minicron::Hub::Model::Job.belonging_to(current_user)
                                    .includes(:schedules)
                                    .find(params[:id])
    @job_executions = Minicron::Hub::Model::Execution.belonging_to(current_user)
                                                      .where(job_id: @job.id)
                                                      .limit(15)
                                                      .order(created_at: :desc)

    # Sort the executions in code for better perf
    @job.executions.sort { |a, b| a.number <=> b.number }

    erb :'jobs/show', layout: :'layouts/app'
  end

  get '/jobs/new' do
    # Empty instance to simplify views
    @previous = Minicron::Hub::Model::Job.new

    erb :'jobs/new', layout: :'layouts/app'
  end

  post '/jobs/new' do
    begin
      # Try and save the new job
      job = Minicron::Hub::Model::Job.create!(
        user_id: current_user.id,
        name: params[:name],
        command: params[:command],
        command_hash: Minicron::Transport.get_job_hash(params[:command])
      )

      # TODO: needed?
      job.save!

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
    @job = Minicron::Hub::Model::Job.belonging_to(current_user)
                             .find(params[:id])

    erb :'jobs/edit', layout: :'layouts/app'
  end

  post '/job/:id/edit' do
    begin
      Minicron::Hub::Model::Job.transaction do
        @job = Minicron::Hub::Model::Job.belonging_to(current_user)
                                        .includes(:schedules)
                                        .find(params[:id])

        @job.name = params[:name]
        @job.command = params[:command]
        @job.command_hash = Minicron::Transport.get_job_hash(@job.command)

        @job.save!

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
    @job = Minicron::Hub::Model::Job.belonging_to(current_user)
                             .includes(:executions, :schedules)
                             .find(params[:id])

    # Sort the executions in code for better perf
    @job.executions.sort { |a, b| a.number <=> b.number }

    begin
      Minicron::Hub::Model::Job.transaction do
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

        @job.save!

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
    @job = Minicron::Hub::Model::Job.belonging_to(current_user).find(params[:id])

    erb :'jobs/delete', layout: :'layouts/app'
  end

  post '/job/:id/delete' do
    # Look up the job
    @job = Minicron::Hub::Model::Job.belonging_to(current_user)
                             .includes(:schedules)
                             .find(params[:id])

    begin
      Minicron::Hub::Model::Job.transaction do
        # Try and delete the job
        Minicron::Hub::Model::Job.destroy(params[:id])


        redirect "#{route_prefix}/jobs"
      end
    rescue Exception => e
      @job.restore_attributes
      flash.now[:error] = e.message
      erb :'jobs/delete', layout: :'layouts/app'
    end
  end

  get '/job/:job_id/schedule/:schedule_id' do
    # Look up the schedule
    @schedule = Minicron::Hub::Model::Schedule.belonging_to(current_user)
                                       .includes(:job)
                                       .find(params[:schedule_id])

    # Look up the job
    @job = @schedule.job

    erb :'jobs/schedules/show', layout: :'layouts/app'
  end

  get '/job/:job_id/schedules/new' do
    # Empty instance to simplify views
    @previous = Minicron::Hub::Model::Schedule.new

    # Look up the job
    @job = Minicron::Hub::Model::Job.belonging_to(current_user).find(params[:job_id])

    erb :'jobs/schedules/new', layout: :'layouts/app'
  end

  post '/job/:job_id/schedules/new' do
    # Look up the job
    @job = Minicron::Hub::Model::Job.belonging_to(current_user)
                             .includes(:schedules)
                             .find(params[:job_id])

    begin
      ActiveRecord::Base.transaction do
        # First we need to check a schedule like this doesn't already exist
        exists = Minicron::Hub::Model::Schedule.belonging_to(current_user).exists?(
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
        schedule = Minicron::Hub::Model::Schedule.create(
          user_id: current_user.id,
          minute: params[:minute].empty? ? nil : params[:minute],
          hour: params[:hour].empty? ? nil : params[:hour],
          day_of_the_month: params[:day_of_the_month].empty? ? nil : params[:day_of_the_month],
          month: params[:month].empty? ? nil : params[:month],
          day_of_the_week: params[:day_of_the_week].empty? ? nil : params[:day_of_the_week],
          special: params[:special].empty? ? nil : params[:special],
          job_id: params[:job_id]
        )

        schedule.save!
      end

      # Redirect to the updated job
      redirect "#{route_prefix}/job/#{@job.id}"
    rescue Exception => e
      flash.now[:error] = e.message
      erb :'jobs/schedules/new', layout: :'layouts/app'
    end
  end

  get '/job/:job_id/schedule/:schedule_id/edit' do
    # Look up the schedule
    @schedule = Minicron::Hub::Model::Schedule.belonging_to(current_user)
                                       .includes(:job)
                                       .find(params[:schedule_id])

    # Look up the job
    @job = Minicron::Hub::Model::Job.belonging_to(current_user).find(params[:job_id])

    erb :'jobs/schedules/edit', layout: :'layouts/app'
  end

  post '/job/:job_id/schedule/:schedule_id/edit' do
    # Look up the schedule and job
    @schedule = Minicron::Hub::Model::Schedule.belonging_to(current_user)
                                              .find(params[:schedule_id])

    begin
      # To keep the view similar to #new store the job here
      @job = @schedule.job

      Minicron::Hub::Model::Schedule.transaction do
        old_schedule = @schedule.formatted

        # Update the instance of the new schedule
        @schedule.minute = params[:minute].empty? ? nil : params[:minute]
        @schedule.hour = params[:hour].empty? ? nil : params[:hour]
        @schedule.day_of_the_month = params[:day_of_the_month].empty? ? nil : params[:day_of_the_month]
        @schedule.month = params[:month].empty? ? nil : params[:month]
        @schedule.day_of_the_week = params[:day_of_the_week].empty? ? nil : params[:day_of_the_week]
        @schedule.special = params[:special].empty? ? nil : params[:special]

        @schedule.save!

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
    @schedule = Minicron::Hub::Model::Schedule.belonging_to(current_user)
                                              .includes(:job)
                                              .find(params[:schedule_id])

    erb :'jobs/schedules/delete', layout: :'layouts/app'
  end

  post '/job/:id/schedule/:schedule_id/delete' do
    # Find the schedule
    @schedule = Minicron::Hub::Model::Schedule.belonging_to(current_user)
                                              .find(params[:schedule_id])
    begin
      Minicron::Hub::Model::Schedule.destroy(params[:schedule_id])

      redirect "#{route_prefix}/job/#{@schedule.job.id}"
    rescue Exception => e
      @schedule.restore_attributes
      flash.now[:error] = e.message
      erb :'jobs/schedules/delete', layout: :'layouts/app'
    end
  end
end
