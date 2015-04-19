class Minicron::Hub::App
  get '/execution/:execution_id' do
    # Look up the job execution
    @execution = Minicron::Hub::Execution.includes(:job_execution_outputs, :job => :host)
                                         .order(:created_at => :desc, :started_at => :desc)
                                         .find(params['execution_id'])

    erb :execution, :layout => :'layouts/app'
  end
end
