class Minicron::Hub::App
  get '/hosts' do
    # Look up all the hosts
    @hosts = Minicron::Hub::Host.all.order(:created_at => :desc)
                                .includes(:jobs)

    erb :'hosts/index', :layout => :'layouts/app'
  end

  get '/hosts/new' do
    erb :'hosts/new', :layout => :'layouts/app'
  end

  post '/hosts/new' do
    begin
      # Default the value of the port
      params[:port] ||= 22

      # Default the value of the user
      params[:user] ||= 'root'

      # Try and save the new host
      host = Minicron::Hub::Host.create(
        :name => params[:name],
        :fqdn => params[:fqdn],
        :user => params[:user],
        :host => params[:host],
        :port => params[:port]
      )

      # Generate a new SSH key - TODO: add passphrase
      key = Minicron.generate_ssh_key('host', host.id, host.fqdn)

      # And finally we store the public key in te db with the host for convenience
      host.public_key = key.ssh_public_key
      host.save!

      # Redirect to the new host
      redirect "#{Minicron::Transport::Server.get_prefix}/host/#{host.id}"
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      @error = e.message
    end

    erb :'hosts/new', :layout => :'layouts/app'
  end

  get '/host/:id' do
    # Look up the host
    @host = Minicron::Hub::Host.includes(:jobs).find(params[:id])

    erb :'hosts/show', :layout => :'layouts/app'
  end
end
