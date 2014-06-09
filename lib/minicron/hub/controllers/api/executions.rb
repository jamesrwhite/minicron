class Minicron::Hub::App
  # Get all job executions
  get '/api/executions' do
    content_type :json
    executions = Minicron::Hub::Execution.all.order(:created_at => :desc, :started_at => :desc)
                                         .includes(:job_execution_outputs, :job => :host)
    Minicron::Hub::ExecutionSerializer.new(executions).serialize.to_json
  end

  # Get a single job execution by its ID
  get '/api/executions/:id' do
    content_type :json
    execution = Minicron::Hub::Execution.includes(:job_execution_outputs, :job => :host)
                                        .find(params[:id])
    Minicron::Hub::ExecutionSerializer.new(execution).serialize.to_json
  end

  # Delete an existing execution
  delete '/api/executions/:id' do
    content_type :json
    begin
      # Try and delete the execution
      Minicron::Hub::Execution.destroy(params[:id])

      # This is what ember expects as the response
      status 204
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      status 422
      { :error => e.message }.to_json
    end
  end
end
