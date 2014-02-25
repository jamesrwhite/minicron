require 'minicron/hub/models/job'

class Minicron::Hub::App
  get '/api/jobs.json' do
    content_type :json
    Job.all.to_json
  end

  get '/api/jobs/:job_id.json' do
    content_type :json
    Job.find(params[:job_id]).to_json
  end
end
