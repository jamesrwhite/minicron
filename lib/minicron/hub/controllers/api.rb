require 'minicron/hub/models/job'
require 'minicron/hub/models/execution'

class Minicron::Hub::App
  get '/api/jobs.json' do
    content_type :json
    Job.all.order(:created_at => :desc).to_json
  end

  get '/api/jobs/:job_id.json' do
    content_type :json
    Job.find(params[:job_id]).to_json
  end

  get '/api/executions.json' do
    content_type :json
    Execution.all.order(:created_at => :desc, :started_at => :desc).includes(:job)
             .to_json(:include => :job)
  end

  get '/api/executions/:execution_id.json' do
    content_type :json
    Execution.includes(:job, :job_execution_output)
             .find(params[:execution_id])
             .to_json(:include => [:job, :job_execution_output])
  end
end
