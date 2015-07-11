require 'minicron/transport/ssh'

class Minicron::Hub::App
  get '/hosts' do
    # Look up all the hosts
    @hosts = Minicron::Hub::Host.all.order(:created_at => :desc)
                                .includes(:jobs)

    erb :'hosts/index', :layout => :'layouts/app'
  end

  get '/host/:id' do
    # Look up the host
    @host = Minicron::Hub::Host.includes(:jobs).find(params[:id])

    erb :'hosts/show', :layout => :'layouts/app'
  end

  get '/hosts/new' do
    # Empty instance to simplify views
    @previous = Minicron::Hub::Host.new

    erb :'hosts/new', :layout => :'layouts/app'
  end

  post '/hosts/new' do
    begin
      # Try and save the new host
      host = Minicron::Hub::Host.create!(
        :name => params[:name],
        :fqdn => params[:fqdn],
        :user => params[:user],
        :host => params[:host],
        :port => params[:port]
      )

      # Generate a new SSH key - TODO: add passphrase
      key = Minicron.generate_ssh_key('host', host.id, host.fqdn)

      # And finally we store the public key in the db with the host for convenience
      host.public_key = key.ssh_public_key
      host.save!

      # Redirect to the new host
      redirect "#{route_prefix}/host/#{host.id}"
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      @previous = params
      @error = e.message
    end

    erb :'hosts/new', :layout => :'layouts/app'
  end

  get '/host/:id/edit' do
    # Find the host
    @host = Minicron::Hub::Host.find(params[:id])

    erb :'hosts/edit', :layout => :'layouts/app'
  end

  post '/host/:id/edit' do
    begin
      # Find the host
      @host = Minicron::Hub::Host.find(params[:id])

      # Update its data
      @host.name = params[:name]
      @host.fqdn = params[:fqdn]
      @host.user = params[:user]
      @host.host = params[:host]
      @host.port = params[:port]

      @host.save!

      # Redirect to the updated host
      redirect "#{route_prefix}/host/#{@host.id}"
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      @host.restore_attributes
      @error = e.message
      erb :'hosts/edit', :layout => :'layouts/app'
    end
  end

  get '/host/:id/delete' do
    # Look up the host
    @host = Minicron::Hub::Host.find(params[:id])

    erb :'hosts/delete', :layout => :'layouts/app'
  end

  post '/host/:id/delete' do
    # Look up the host
    @host = Minicron::Hub::Host.find(params[:id])

    begin
      Minicron::Hub::Host.transaction do
        # Try and delete the host
        Minicron::Hub::Host.destroy(params[:id])

        # Get an ssh instance and open a connection
        ssh = Minicron::Transport::SSH.new(
          :user => @host.user,
          :host => @host.host,
          :port => @host.port,
          :private_key => "~/.ssh/minicron_host_#{@host.id}_rsa"
        )

        # Get an instance of the cron class
        cron = Minicron::Cron.new(ssh)

        # Delete the host from the crontab
        cron.delete_host(@host)

        # Tidy up
        ssh.close

        # Delete the pub/priv key pair
        private_key_path = File.expand_path("~/.ssh/minicron_host_#{@host.id}_rsa")
        public_key_path = File.expand_path("~/.ssh/minicron_host_#{@host.id}_rsa.pub")
        File.delete(private_key_path)
        File.delete(public_key_path)

        redirect "#{route_prefix}/hosts"
      end
    # TODO: nicer error handling here with proper validation before hand
    rescue Exception => e
      @error = e.message
      erb :'hosts/delete', :layout => :'layouts/app'
    end
  end

  get '/host/:id/test' do
    begin
      # Get the host
      @host = Minicron::Hub::Host.find(params[:id])

      # Set up the ssh instance
      ssh = Minicron::Transport::SSH.new(
        :user => @host.user,
        :host => @host.host,
        :port => @host.port,
        :private_key => "~/.ssh/minicron_host_#{@host.id}_rsa"
      )

      # Get an instance of the cron class
      cron = Minicron::Cron.new(ssh)

      # Test the SSH connection
      @test = cron.test_host_permissions

      # Tidy up
      ssh.close
    rescue Exception => e
      @error = e.message
    end

    erb :'hosts/test', :layout => :'layouts/app'
  end
end
