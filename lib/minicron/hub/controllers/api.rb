class Minicron::Hub::App
  # Get all hosts that a job
  # TODO: Add offset/limit
  get '/api/hosts' do
    content_type :json
    hosts = Minicron::Hub::Host.all.includes(:jobs).order(:created_at => :desc)
    HostSerializer.new(hosts).serialize.to_json
  end

  # Get a single host by its ID
  get '/api/hosts/:id' do
    content_type :json
    host = Minicron::Hub::Host.includes(:jobs).order(:created_at => :desc)
                              .find(params[:id])
    HostSerializer.new(host).serialize.to_json
  end

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

  # Get all job executions
  # TODO: Add offset/limit
  get '/api/executions' do
    content_type :json
    executions = Minicron::Hub::Execution.all.order(:created_at => :desc, :started_at => :desc)
                                         .includes(:job, :job_execution_outputs)
    ExecutionSerializer.new(executions).serialize.to_json
  end

  # Get a single job execution by its ID
  get '/api/executions/:id' do
    content_type :json
    execution = Minicron::Hub::Execution.includes(:job, :job_execution_outputs)
                                        .find(params[:id])
    ExecutionSerializer.new(execution).serialize.to_json
  end
end
