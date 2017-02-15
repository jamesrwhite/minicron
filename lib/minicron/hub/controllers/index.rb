class Minicron::Hub::App
  get '/' do
    # Get the most recent job execution
    recent = Minicron::Hub::Execution
             .belonging_to(current_user)
             .includes(:job)
             .order(created_at: :desc, started_at: :desc)
             .first

    # Redirect the user to that execution if we found one
    if recent
      redirect "#{route_prefix}/execution/#{recent.id}"
    else
      erb :index, layout: :'layouts/app'
    end
  end
end
