class Minicron::Hub::App
  # Get all job executions
  get '/api/executions' do
    content_type :json
<<<<<<< HEAD
    executions = Minicron::Hub::Execution.all.order(:created_at => :desc, :started_at => :desc)
                                         .includes(:job_execution_outputs, :job => :host)
    Minicron::Hub::ExecutionSerializer.new(executions).serialize.to_json
=======

    begin
      Minicron::Hub::Host.transaction do
        # Try and find the host
        host = Minicron::Hub::Host.where(:fqdn => params[:fqdn]).first

        # Create it if it didn't exist!
        if !host
          host = Minicron::Hub::Host.create!(
            :name => params[:hostname],
            :fqdn => params[:fqdn],
            :user => params[:user], # TODO: this probably wont be correct but needs some value set
            :host => request.ip, # TODO: ensure this is the correct header if behind a reverse proxy etc
            :port => 22
          )

          # Generate a new SSH key - TODO: add passphrase
          key = Minicron.generate_ssh_key('host', host.id, host.fqdn)

          # And finally we store the public key in te db with the host for convenience
          Minicron::Hub::Host.where(:id => host.id).update_all(
            :public_key => key.ssh_public_key
          )
        end

        # Validate or create the job
        job = Minicron::Hub::Job.where(:job_hash => params[:job_hash]).first_or_create! do |j|
          j.job_hash = params[:job_hash]
          j.user = params[:user]
          j.command = params[:command]
          j.host_id = host.id
        end

        # Get the latest execution number
        latest_execution = Minicron::Hub::Execution.where(:job_id => job.id)
                                                   .order(:id => :desc)
                                                   .limit(1)
                                                   .pluck(:number)

       # If this is the first execution then default it to 1 otherwise increment by 1
       execution_number = latest_execution[0].nil? ? 1 : latest_execution[0] + 1

        # Create an execution for this job
        execution = Minicron::Hub::Execution.create!(
          :created_at => Time.at(params[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S'),
          :job_id => job.id,
          :number => execution_number
        )

        json({
          :job_id => job.id,
          :execution_id => execution.id,
          :execution_number => execution_number,
        })
      end
    rescue Exception => e
      status 500

      json({
        :error => e.message
      })
    end
>>>>>>> upstream/master
  end

  # Get a single job execution by its ID
  get '/api/executions/:id' do
    content_type :json
    execution = Minicron::Hub::Execution.includes(:job_execution_outputs, :job => :host)
                                        .find(params[:id])
    Minicron::Hub::ExecutionSerializer.new(execution).serialize.to_json
  end

  # Delete an existing execution
  delete '/api/executions/:id' do
    content_type :json
    begin
      # Try and delete the execution
      Minicron::Hub::Execution.destroy(params[:id])

      # This is what ember expects as the response
      status 204
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
<<<<<<< HEAD
      status 422
      { :error => e.message }.to_json
=======
      status 500

      json({
        :error => e.message
      })
    end
  end

  post '/api/v1/execution/finish' do
    content_type :json

    begin
        Minicron::Hub::Execution.where(:id => params[:execution_id]).update_all(
          :finished_at => Time.at(params[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S')
        )

        json({
          :success => true
        })
    rescue Exception => e
      status 500

      json({
        :error => e.message
      })
    end
  end

  post '/api/v1/execution/exit' do
    content_type :json

    begin
        Minicron::Hub::Execution.where(:id => params[:execution_id]).update_all(
          :exit_status => params[:exit_status]
        )

       # If the exit status was above 0 we need to trigger a failure alert
      if params[:exit_status].to_i > 0
        Minicron::Alert.send_all(
          :kind => 'fail',
          :execution_id => params[:execution_id],
          :job_id => params[:job_id]
        )
      end

      json({
        :success => true
      })
    rescue Exception => e
      status 500

      json({
        :error => e.message
      })
>>>>>>> upstream/master
    end
  end
end
