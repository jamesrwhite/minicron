class Minicron::Hub::App
  post '/api/v1/jobs/setup' do
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
end
