class Minicron::Hub::App
  get '/' do
    # Get the most recent job execution
    recent = Minicron::Hub::Execution
                           .includes(:job)
                           .order(:created_at => :desc, :started_at => :desc)
                           .first

    redirect "#{Minicron::Transport::Server.get_prefix}/execution/#{recent.id}"
  end
end
