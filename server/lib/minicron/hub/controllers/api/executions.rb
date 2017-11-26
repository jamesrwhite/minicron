class Minicron::Hub::App
  post '/api/1.0/execution/init' do
    content_type :json

    begin
      body = JSON.parse(request.body.read.to_s).symbolize_keys

      Minicron::Hub::Model::Host.transaction do
        # Try and find the host
        host = Minicron::Hub::Model::Host.belonging_to(current_user)
                                  .where(hostname: body[:hostname])
                                  .first

        # Create it if it didn't exist!
        unless host
          host = Minicron::Hub::Model::Host.create!(
            user_id: current_user.id,
            hostname: body[:hostname],
          )
        end

        # Hash the job command
        command_hash = Minicron::Transport.get_job_hash(body[:command])

        # Find or create the job
        job = Minicron::Hub::Model::Job.belonging_to(current_user).where(command_hash: command_hash).first_or_create! do |j|
          j.user_id = current_user.id
          j.command = body[:command]
          j.command_hash = command_hash
        end

        # Check if the job is enabled
        unless job.enabled
          raise Minicron::ClientError, "Refusing to execute disabled job with id: #{job.id} and name: #{job.name}"
        end

        # Get the latest execution number
        latest_execution = Minicron::Hub::Model::Execution.belonging_to(current_user)
                                                          .where(job_id: job.id)
                                                          .order(id: :desc)
                                                          .limit(1)
                                                          .pluck(:number)

        # If this is the first execution then default it to 1 otherwise increment by 1
        # TODO: is this safe to do like this?
        execution_number = latest_execution[0].nil? ? 1 : latest_execution[0] + 1

        # Create an execution for this job
        execution = Minicron::Hub::Model::Execution.create!(
          user_id: current_user.id,
          job_id: job.id,
          host_id: host.id,
          number: execution_number
        )

        json({
          body: {
            execution_id: execution.id
          },
          success: true,
          error: {
            message: nil
          }
        })
      end
    rescue Exception => e
      status 500

      json({
        body: nil,
        success: false,
        error: {
          message: e.message
        }
      })
    end
  end

  post '/api/1.0/execution/start' do
    content_type :json

    begin
      body = JSON.parse(request.body.read.to_s).symbolize_keys

      Minicron::Hub::Model::Execution.belonging_to(current_user).where(id: body[:execution_id]).update_all(
        started_at: Time.at(body[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S')
      )

      json({
        body: nil,
        success: true,
        error: {
          message: nil
        }
      })
    rescue Exception => e
      status 500

      json({
        body: nil,
        success: false,
        error: {
          message: e.message
        }
      })
    end
  end

  post '/api/1.0/execution/output' do
    content_type :json

    begin
      body = JSON.parse(request.body.read.to_s).symbolize_keys

      Minicron::Hub::Model::JobExecutionOutput.create!(
        user_id: current_user.id,
        execution_id: body[:execution_id],
        output: body[:output],
        timestamp: Time.at(body[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S'),
        seq: body[:seq]
      )

      json({
        body: nil,
        success: true,
        error: {
          message: nil
        }
      })
    rescue Exception => e
      status 500

      json({
        body: nil,
        success: false,
        error: {
          message: e.message
        }
      })
    end
  end

  post '/api/1.0/execution/finish' do
    content_type :json

    begin
      body = JSON.parse(request.body.read.to_s).symbolize_keys

      Minicron::Hub::Model::Execution.belonging_to(current_user).where(id: body[:execution_id]).update_all(
        finished_at: Time.at(body[:timestamp].to_i).utc.strftime('%Y-%m-%d %H:%M:%S')
      )

      json({
        body: nil,
        success: true,
        error: {
          message: nil
        }
      })
    rescue Exception => e
      status 500

      json({
        body: nil,
        success: false,
        error: {
          message: e.message
        }
      })
    end
  end

  post '/api/1.0/execution/exit' do
    content_type :json

    begin
      body = JSON.parse(request.body.read.to_s).symbolize_keys

      Minicron::Hub::Model::Execution.belonging_to(current_user).where(id: body[:execution_id]).update_all(
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

      json({
        body: nil,
        success: true,
        error: {
          message: nil
        }
      })
    rescue Exception => e
      status 500

      json({
        body: nil,
        success: false,
        error: {
          message: e.message
        }
      })
    end
  end
end
