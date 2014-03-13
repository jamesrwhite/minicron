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
end
