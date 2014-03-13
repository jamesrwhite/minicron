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

  post '/api/hosts' do
    begin
      # Load the JSON body
      request_body = Oj.load(request.body)

      # Try and save the new host
      host = Minicron::Hub::Host.create(
        :name => request_body['host']['name'],
        :hostname => request_body['host']['hostname']
      )

      # Return the new host
      HostSerializer.new(host).serialize.to_json
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end
end
