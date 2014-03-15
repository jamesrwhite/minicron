class Minicron::Hub::App
  # Get all jobs
  # TODO: Add offset/limit
  get '/api/jobs' do
    content_type :json

    if params[:job_hash]
      jobs = Minicron::Hub::Job.includes(:host, { :executions => :job_execution_outputs }).where(:job_hash => params[:job_hash])
    else
      jobs = Minicron::Hub::Job.all.order(:created_at => :desc).includes(:host, :executions)
    end

    JobSerializer.new(jobs).serialize.to_json
  end

  # Get a single job by it ID
  get '/api/jobs/:id' do
    content_type :json
    job = Minicron::Hub::Job.includes(:host, { :executions => :job_execution_outputs }).find(params[:id])
    JobSerializer.new(job).serialize.to_json
  end

  # Update an existing job
  put '/api/jobs/:id' do
    content_type :json
    begin
      # Load the JSON body
      request_body = Oj.load(request.body)

      # Try and save the updated job
      job = Minicron::Hub::Job.find(params[:id])
      job.name = request_body['job']['name']
      job.save!

      # Return the new job
      JobSerializer.new(job).serialize.to_json
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end

  # Delete an existing job
  delete '/api/jobs/:id' do
    content_type :json
    begin
      # Try and delete the job
      Minicron::Hub::Job.destroy(params[:id])

      # This is what ember expects as the response
      status 204
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end
end
