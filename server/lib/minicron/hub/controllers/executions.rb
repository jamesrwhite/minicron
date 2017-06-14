class Minicron::Hub::App
  get '/execution/:id' do
    # Look up the job execution
    @execution = Minicron::Hub::Model::Execution.belonging_to(current_user)
                                         .includes(:job, :job_execution_outputs)
                                         .find(params[:id])

    # Sort the execution output in code for better perf
    @execution.job_execution_outputs.sort { |a, b| a.seq <=> b.seq }

    erb :'executions/show', layout: :'layouts/app'
  end

  get '/execution/:id/delete' do
    # Look up the execution
    @execution = Minicron::Hub::Model::Execution.belonging_to(current_user)
                                         .includes(:job)
                                         .find(params[:id])

    erb :'executions/delete', layout: :'layouts/app'
  end

  post '/execution/:id/delete' do
    # Look up the execution
    @execution = Minicron::Hub::Model::Execution.belonging_to(current_user)
                                         .includes(:job)
                                         .find(params[:id])

    begin
      # Try and delete the execution
      Minicron::Hub::Model::Execution.belonging_to(current_user)
                              .destroy(params[:id])

      redirect "#{route_prefix}/job/#{@execution.job.id}"
    rescue Exception => e
      flash.now[:error] = e.message
      erb :'executions/delete', layout: :'layouts/app'
    end
  end
end
