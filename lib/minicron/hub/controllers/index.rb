class Minicron::Hub::App
  get '/' do
    # Get a list of recent executions for the sidebar
    @recent = Minicron::Hub::Execution.all
                                      .order(:created_at => :desc, :started_at => :desc)
                                      .includes(:job => :host)

    erb :index, :layout => :'layouts/app'
  end
end
