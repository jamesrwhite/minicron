class Minicron::Hub::App
  get '/jobs' do
    # Look up all the jobs
    @jobs = Minicron::Hub::Job.all.order(:created_at => :desc)
                              .includes(:host, :executions)

    erb :'jobs/index', :layout => :'layouts/app'
  end
end
