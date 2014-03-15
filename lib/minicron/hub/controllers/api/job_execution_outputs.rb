class Minicron::Hub::App
  # Get all job execution outputs
  # TODO: Add offset/limit
  get '/api/jobExecutionOutputs' do
    content_type :json

    if params[:ids]
      output = Minicron::Hub::JobExecutionOutput.includes(:execution)
                                                .where(:id => params[:ids])
                                                .order(:id => :asc)
    else
      output = Minicron::Hub::JobExecutionOutput.all.order(:id => :asc)
    end

    JobExecutionOutputSerializer.new(output).serialize.to_json
  end

  # Get a single job execution output by it ID
  get '/api/jobExecutionOutputs/:id' do
    content_type :json
    output = Minicron::Hub::JobExecutionOutput.includes(:execution)
                                              .order(:id => :asc)
                                              .find(params[:id])
    JobExecutionOutputSerializer.new(output).serialize.to_json
  end
end
