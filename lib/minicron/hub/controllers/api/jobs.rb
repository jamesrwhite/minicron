require 'minicron/transport'

class Minicron::Hub::App
  # Get all jobs
  get '/api/jobs' do
    content_type :json

    if params[:job_hash]
      jobs = Minicron::Hub::Job.includes(:host, :schedules, :executions => :job_execution_outputs)
                               .where(:job_hash => params[:job_hash])
    else
      jobs = Minicron::Hub::Job.all.order(:created_at => :desc)
                               .includes(:host, :schedules, :executions => :job_execution_outputs)
    end

    Minicron::Hub::JobSerializer.new(jobs).serialize.to_json
  end

  # Get a single job by it ID
  get '/api/jobs/:id' do
    content_type :json
    job = Minicron::Hub::Job.includes(:host, :schedules, :executions => :job_execution_outputs)
                            .find(params[:id])
    Minicron::Hub::JobSerializer.new(job).serialize.to_json
  end

  # Create a new job
  post '/api/jobs' do
    content_type :json
    begin
      # Load the JSON body
      request_body = Oj.load(request.body)

      # First we need to look up the host
      host = Minicron::Hub::Host.find(request_body['job']['host'])

      # Try and save the new job
      job = Minicron::Hub::Job.create(
        :job_hash => Minicron::Transport.get_job_hash(request_body['job']['command'], host.fqdn),
        :name => request_body['job']['name'],
        :user => request_body['job']['user'],
        :command => request_body['job']['command'],
        :host_id => host.id
      )

      job.save!

      # Return the new job
      Minicron::Hub::JobSerializer.new(job).serialize.to_json
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      status 422
      { :error => e.message }.to_json
    end
  end

  # Update an existing job
  put '/api/jobs/:id' do
    content_type :json
    begin
      # Load the JSON body
      request_body = Oj.load(request.body)

      # Find the job
      job = Minicron::Hub::Job.includes(:host, :schedules, :executions => :job_execution_outputs)
                              .find(params[:id])

      # Update the name and user
      job.name = request_body['job']['name']
      job.user = request_body['job']['user']

      job.save!

      # Return the new job
      Minicron::Hub::JobSerializer.new(job).serialize.to_json
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      status 422
      { :error => e.message }.to_json
    end
  end

  # Delete an existing job
  delete '/api/jobs/:id' do
    content_type :json
    begin
      Minicron::Hub::Job.transaction do
        # Look up the job
        job = Minicron::Hub::Job.includes(:schedules).find(params[:id])

        # Try and delete the job
        Minicron::Hub::Job.destroy(params[:id])

        # Get an ssh instance
        ssh = Minicron::Transport::SSH.new(
          :user => job.host.user,
          :host => job.host.host,
          :port => job.host.port,
          :private_key => "~/.ssh/minicron_host_#{job.host.id}_rsa"
        )

        # Get an instance of the cron class
        cron = Minicron::Cron.new(ssh)

        # Delete the job from the crontab
        cron.delete_job(job)

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
