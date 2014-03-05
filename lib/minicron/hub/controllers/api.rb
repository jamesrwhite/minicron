class Minicron::Hub::App
  # Get all jobs
  # TODO: Add offset/limit
  get '/api/jobs' do
    content_type :json
    jobs = Minicron::Hub::Job.all.order(:created_at => :desc).includes(:host)
    { :jobs => jobs.map { |e| JobSerializer.new(e, :root => false) } }.to_json
  end

  # Get a single job by it ID
  get '/api/jobs/:id' do
    content_type :json
    job = Minicron::Hub::Job.includes(:host).find(params[:id])
    JobSerializer.new(job).to_json
  end

  # Get all job executions
  # TODO: Add offset/limit
  get '/api/executions' do
    content_type :json
    executions = Minicron::Hub::Execution.all.order(:created_at => :desc, :started_at => :desc)
                                         #.includes({:job => :host}, :job_execution_outputs)
    { :executions => executions.map { |e| ExecutionSerializer.new(e, :root => false) } }.to_json
  end

  # Get a single job execution by its ID
  get '/api/executions/:id' do
    content_type :json
    execution = Minicron::Hub::Execution.find(params[:id])
                                        #.includes({:job => :host}, :job_execution_outputs)
    ExecutionSerializer.new(execution).to_json
  end

  # Get all hosts that a job
  # TODO: Add offset/limit
  get '/api/hosts' do
    content_type :json
    hosts = Minicron::Hub::Host.all.includes(:jobs).order(:created_at => :desc)
    { :hosts => hosts.map { |h| HostSerializer.new(h, :root => false) } }.to_json
  end

  # Get a single host by its ID
  get '/api/hosts/:id' do
    content_type :json
    host = Minicron::Hub::Host.includes(:jobs).order(:created_at => :desc)
                              .find(params[:id])
    HostSerializer.new(host).to_json
  end
end
