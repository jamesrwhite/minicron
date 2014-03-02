require 'minicron/hub/models/job'
require 'minicron/hub/models/execution'

class Minicron::Hub::App
  # Get all jobs
  # TODO: Add offset/limit
  get '/api/jobs.json' do
    content_type :json
    Minicron::Hub::Job.all.order(:created_at => :desc)
                      .includes(:host)
                      .to_json(:include => :host)
  end

  # Get a single job by it ID
  get '/api/jobs/:job_id.json' do
    content_type :json
    Minicron::Hub::Job.includes(:host).find(params[:job_id])
                      .to_json(:include => :host)
  end

  # Get all job executions
  # TODO: Add offset/limit
  get '/api/executions.json' do
    content_type :json
    Minicron::Hub::Execution.all.order(:created_at => :desc, :started_at => :desc)
             .includes({:job => :host})
             .to_json(:include => {:job => {:include => :host}})
  end

  # Get a single job execution by its ID
  get '/api/executions/:execution_id.json' do
    content_type :json
    Minicron::Hub::Execution.includes({:job => :host}, :job_execution_output)
             .find(params[:execution_id])
             .to_json(:include => [{:job => {:include => :host}}, :job_execution_output])
  end

  # Get all hosts that a job
  get '/api/hosts.json' do
    content_type :json
    Minicron::Hub::Host.all.includes(:jobs).order(:created_at => :desc)
                       .to_json(:include => :jobs)
  end

  # Get a single host by its ID
  get '/api/hosts/:host_id.json' do
    content_type :json
    Minicron::Hub::Host.includes(:jobs).order(:created_at => :desc)
                       .find(params[:host_id]).to_json(:include => :jobs)
  end
end
