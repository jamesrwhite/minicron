class Minicron::Hub::App
  post '/api/1.0/execution/init' do
    content_type :json

    begin
      body = JSON.parse(request.body.read.to_s).symbolize_keys

      Minicron::Hub::Host.transaction do
        # Try and find the host
        host = Minicron::Hub::Host.belonging_to(current_user)
                                  .where(fqdn: body[:fqdn])
                                  .first

        # Create it if it didn't exist!
        unless host
          host = Minicron::Hub::Host.create!(
            user_id: current_user.id,
            name: body[:hostname],
            fqdn: body[:fqdn],
          )
        end

        # Validate or create the job
        job = Minicron::Hub::Job.belonging_to(current_user).where(job_hash: body[:job_hash]).first_or_create! do |j|
          j.user_id = current_user.id
          j.job_hash = body[:job_hash]
          j.command = body[:command]
          j.host_id = host.id
        end

        # Check if the job is enabled
        unless job.enabled
          raise Minicron::ClientError, "Refusing to execute disabled job with id: #{job.id} and name: #{job.name}"
        end

        # Get the latest execution number
        latest_execution = Minicron::Hub::Execution.belonging_to(current_user)
                                                   .where(job_id: job.id)
                                                   .order(id: :desc)
                                                   .limit(1)
                                                   .pluck(:number)

        # If this is the first execution then default it to 1 otherwise increment by 1
        execution_number = latest_execution[0].nil? ? 1 : latest_execution[0] + 1

        # Create an execution for this job
        execution = Minicron::Hub::Execution.create!(
          user_id: current_user.id,
          created_at: Time.at(body[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S'),
          job_id: job.id,
          number: execution_number
        )

        json(
          execution_id: execution.id,
        )
      end
    rescue Exception => e
      status 500

      json(error: e.message)
    end
  end

  post '/api/1.0/execution/start' do
    content_type :json

    begin
      body = JSON.parse(request.body.read.to_s).symbolize_keys

      Minicron::Hub::Execution.belonging_to(current_user).where(id: body[:execution_id]).update_all(
        started_at: Time.at(body[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S')
      )

      json(success: true)
    rescue Exception => e
      status 500

      json(error: e.message)
    end
  end

  post '/api/1.0/execution/output' do
    content_type :json

    begin
      body = JSON.parse(request.body.read.to_s).symbolize_keys

      Minicron::Hub::JobExecutionOutput.create!(
        user_id: current_user.id,
        execution_id: body[:execution_id],
        output: body[:output],
        timestamp: Time.at(body[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S'),
        seq: body[:seq]
      )

      json(success: true)
    rescue Exception => e
      status 500

      json(error: e.message)
    end
  end

  post '/api/1.0/execution/finish' do
    content_type :json

    begin
      body = JSON.parse(request.body.read.to_s).symbolize_keys

      Minicron::Hub::Execution.belonging_to(current_user).where(id: body[:execution_id]).update_all(
        finished_at: Time.at(body[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S')
      )

      json(success: true)
    rescue Exception => e
      status 500

      json(error: e.message)
    end
  end

  post '/api/1.0/execution/exit' do
    content_type :json

    begin
      body = JSON.parse(request.body.read.to_s).symbolize_keys

      Minicron::Hub::Execution.belonging_to(current_user).where(id: body[:execution_id]).update_all(
        exit_status: body[:exit_status]
      )

      # If the exit status was above 0 we need to trigger a failure alert
      if body[:exit_status].to_i > 0
        Minicron::Alert.send_all(
          user_id: current_user.id,
          kind: 'fail',
          execution_id: body[:execution_id],
          job_id: body[:job_id]
        )
      end

      json(success: true)
    rescue Exception => e
      status 500

      json(error: e.message)
    end
  end
end
