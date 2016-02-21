class Minicron::Hub::App
  post '/api/v1/execution/init' do
    content_type :json

    begin
      Minicron::Hub::Host.transaction do
        # Try and find the host
        host = Minicron::Hub::Host.where(:fqdn => params[:fqdn]).first

        # Create it if it didn't exist!
        if !host
          host = Minicron::Hub::Host.create!(
            :name => params[:hostname],
            :fqdn => params[:fqdn],
            :user => params[:user],
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
          j.command = params[:command]
          j.host_id = host.id
        end

        # Check if the job is enabled
        unless job.enabled
          raise Minicron::ClientError, "Refusing to execute disabled job with id: #{job.id} and name: #{job.name}"
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
          :job => job,
          :execution => execution,
          :host => host,
        })
      end
    rescue Exception => e
      status 500

      json({
        :error => e.message
      })
    end
  end

  post '/api/v1/execution/start' do
    content_type :json

    begin
      # Add the execution start time
      Minicron::Hub::Execution.where(:id => params[:execution_id]).update_all(
        :started_at => Time.at(params[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S')
      )

      # Look up the job and it's host and the execution and its output
      job = Minicron::Hub::Job.includes(:host).find(params[:job_id])
      execution = Minicron::Hub::Execution.includes(:job_execution_outputs).find(params[:execution_id])

      json({
        :job => job,
        :execution => execution,
        :output => execution.job_execution_outputs,
        :host => job.host,
      })
    rescue Exception => e
      status 500

      json({
        :error => e.message
      })
    end
  end

  post '/api/v1/execution/output' do
    content_type :json

    begin
      # Append to the job executiob output
      Minicron::Hub::JobExecutionOutput.create!(
        :execution_id => params[:execution_id],
        :output => params[:output],
        :timestamp => Time.at(params[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S'),
        :seq => params[:seq],
      )

      # Look up the job and it's host and the execution and its output
      job = Minicron::Hub::Job.includes(:host).find(params[:job_id])
      execution = Minicron::Hub::Execution.includes(:job_execution_outputs).find(params[:execution_id])

      json({
        :job => job,
        :execution => execution,
        :output => execution.job_execution_outputs,
        :host => job.host,
      })
    rescue Exception => e
      status 500

      json({
        :error => e.message
      })
    end
  end

  post '/api/v1/execution/finish' do
    content_type :json

    begin
      # Update the status of the job to finished
      Minicron::Hub::Execution.where(:id => params[:execution_id]).update_all(
        :finished_at => Time.at(params[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S')
      )

      # Look up the job and it's host and the execution and its output
      job = Minicron::Hub::Job.includes(:host).find(params[:job_id])
      execution = Minicron::Hub::Execution.includes(:job_execution_outputs).find(params[:execution_id])

      json({
        :job => job,
        :execution => execution,
        :output => execution.job_execution_outputs,
        :host => job.host,
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
      # Set the jobs exit status code
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

      # Look up the job and it's host and the execution and its output
      job = Minicron::Hub::Job.includes(:host).find(params[:job_id])
      execution = Minicron::Hub::Execution.includes(:job_execution_outputs).find(params[:execution_id])

      json({
        :job => job,
        :execution => execution,
        :output => execution.job_execution_outputs,
        :host => job.host,
      })
    rescue Exception => e
      status 500

      json({
        :error => e.message
      })
    end
  end
end
