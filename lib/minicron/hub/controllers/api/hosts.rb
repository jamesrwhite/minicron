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

  # Create a new host
  post '/api/hosts' do
    content_type :json
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

  # Update an existing host
  put '/api/hosts/:id' do
    content_type :json
    begin
      # Load the JSON body
      request_body = Oj.load(request.body)

      # Try and save the updated host
      host = Minicron::Hub::Host.find(params[:id])
      host.name = request_body['host']['name']
      host.hostname = request_body['host']['hostname']
      host.save!

      # Return the new host
      HostSerializer.new(host).serialize.to_json
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end

  # Delete an existing host
  delete '/api/hosts/:id' do
    content_type :json
    begin
      # Try and delete the host
      Minicron::Hub::Host.destroy(params[:id])

      # This is what ember expects as the response
      status 204
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      { :error => e.message }.to_json
    end
  end
end
