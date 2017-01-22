class Minicron::Hub::App
  get '/execution/:id' do
    # Look up the job execution
    @execution = Minicron::Hub::Execution.includes(:job_execution_outputs, job: :host)
                                         .order('job_execution_outputs.seq')
                                         .find(params[:id])

    erb :'executions/show', layout: :'layouts/app'
  end

  get '/execution/:id/delete' do
    # Look up the execution
    @execution = Minicron::Hub::Execution.includes(:job).find(params[:id])

    erb :'executions/delete', layout: :'layouts/app'
  end

  post '/execution/:id/delete' do
    # Look up the execution
    @execution = Minicron::Hub::Execution.includes(:job).find(params[:id])

    begin
      # Try and delete the execution
      Minicron::Hub::Execution.destroy(params[:id])

      redirect "#{route_prefix}/job/#{@execution.job.id}"
    rescue Exception => e
      flash.now[:error] = e.message
      erb :'executions/delete', layout: :'layouts/app'
    end
  end
end
