class Minicron::Hub::App
  get '/jobs' do
    # Look up all the jobs
    @jobs = Minicron::Hub::Job.all.order(:created_at => :desc)
                              .includes(:host, :executions)

    erb :'jobs/index', :layout => :'layouts/app'
  end

  get '/job/:id' do
    # Look up the job
    @job = Minicron::Hub::Job.includes(:host, :executions, :schedules).find(params[:id])

    erb :'jobs/show', :layout => :'layouts/app'
  end
end
