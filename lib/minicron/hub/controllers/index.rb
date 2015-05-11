class Minicron::Hub::App
  # Get a list of recent executions for the sidebar
  @recent_executions = Minicron::Hub::Execution.all
                                               .order(:created_at => :desc, :started_at => :desc)
                                               .includes(:job => :host)

  get '/' do
    # Get the most recent job execution
    recent = Minicron::Hub::Execution
                           .includes(:job)
                           .order(:created_at => :desc, :started_at => :desc)
                           .first

    redirect "#{Minicron::Transport::Server.get_prefix}/execution/#{recent.id}"
  end
end
