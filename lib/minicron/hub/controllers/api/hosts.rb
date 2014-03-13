class Minicron::Hub::App
  # Get all hosts that a job
  # TODO: Add offset/limit
  get '/api/hosts' do
    content_type :json
    hosts = Minicron::Hub::Host.all.includes(:jobs).order(:id => :asc)
    HostSerializer.new(hosts).serialize.to_json
  end

  # Get a single host by its ID
  get '/api/hosts/:id' do
    content_type :json
    host = Minicron::Hub::Host.includes(:jobs).find(params[:id])
    HostSerializer.new(host).serialize.to_json
  end
end
