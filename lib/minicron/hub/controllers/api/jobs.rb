class Minicron::Hub::App
  post '/api/v1/jobs/init' do
    begin
      Minicron::Hub::Host.transaction do
        # Try and find the host
        host = Minicron::Hub::Host.where(:fqdn => params[:fqdn]).first

        # Create it if it didn't exist!
        if !host
          host = Minicron::Hub::Host.create!(
            :name => params[:hostname],
            :fqdn => params[:fqdn],
            :host => request.ip,
            :port => 22,
            :user => 'root',
          )

          # Generate a new SSH key - TODO: add passphrase
          key = Minicron.generate_ssh_key('host', host.id, host.fqdn)

          # And finally we store the public key in te db with the host for convenience
          Minicron::Hub::Host.where(:id => host.id).update_all(
            :public_key => key.ssh_public_key
          )
        end

        # Try and locate the job
        job = Minicron::Hub::Job.where(:job_hash => params[:hash]).first

        # Create it if it didn't exist!
        if !job
          job = Minicron::Hub::Job.create!(
            :job_hash => params[:hash],
            :user => params[:user],
            :command => params[:command],
            :host_id => host.id,
          )
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
          :job_id => job.id,
          :number => execution_number
        )

        json({
          :job_id => job.id,
          :execution_id => execution.id,
          :execution_number => execution.number
        })
      end
    rescue Exception => e
      status 500
      json({
        :error => e.message
      })
    end
  end

  post '/api/v1/jobs/status' do
    begin
      Minicron::Hub::Host.transaction do
        case params[:status]
        # Update the execution with the start time
        when 'start'
          Minicron::Hub::Execution.where(:id => params[:execution_id]).update_all(
            :started_at => params[:meta]
          )
        # Update the execution with the finish time
        when 'finish'
          Minicron::Hub::Execution.where(:id => params[:execution_id]).update_all(
            :finished_at => params[:meta]
          )
        # Update the execution with the exit status
        when 'exit'
          Minicron::Hub::Execution.where(:id => params[:execution_id]).update_all(
            :exit_status => params[:meta]
          )

          # If the exit status was above 0 we need to trigger a failure alert
          if params[:meta].to_i > 0
            alert = Minicron::Alert.new
            alert.send_all(
              :kind => 'fail',
              :execution_id => segments[3],
              :job_id => segments[2]
            )
          end
        else
          raise Exception, "Unknown status type: \"#{params[:status]}\""
        end

        json({
          :success => true
        })
      end
    rescue Exception => e
      status 500
      json({
        :error => e.message
      })
    end
  end

  post '/api/v1/jobs/output' do
    begin
      Minicron::Hub::Host.transaction do
        # Store the job execution output
        Minicron::Hub::JobExecutionOutput.create(
          :execution_id => params[:execution_id],
          :output => params[:output],
          :timestamp => params[:timestamp],
          :seq => params[:seq]
        )

        json({
          :success => true
        })
      end
    rescue Exception => e
      status 500
      json({
        :error => e.message
      })
    end
  end
end
