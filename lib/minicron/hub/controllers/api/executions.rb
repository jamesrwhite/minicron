class Minicron::Hub::App
  # Get all job executions
  # TODO: Add offset/limit
  get '/api/executions' do
    content_type :json
    executions = Minicron::Hub::Execution.all.order(:created_at => :desc, :started_at => :desc)
                                         .includes({:job => :host}, :job_execution_outputs)
    ExecutionSerializer.new(executions).serialize.to_json
  end

  # Get a single job execution by its ID
  get '/api/executions/:id' do
    content_type :json
    execution = Minicron::Hub::Execution.includes({:job => :host}, :job_execution_outputs)
                                        .find(params[:id])
    ExecutionSerializer.new(execution).serialize.to_json
  end
end
