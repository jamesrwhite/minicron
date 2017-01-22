class Minicron::Hub::App
  get '/hosts' do
    # Look up all the hosts
    @hosts = Minicron::Hub::Host.all.order(created_at: :desc)
                                .includes(:jobs)

    erb :'hosts/index', layout: :'layouts/app'
  end

  get '/host/:id' do
    # Look up the host
    @host = Minicron::Hub::Host.includes(:jobs).find(params[:id])

    erb :'hosts/show', layout: :'layouts/app'
  end

  get '/hosts/new' do
    # Empty instance to simplify views
    @previous = Minicron::Hub::Host.new

    erb :'hosts/new', layout: :'layouts/app'
  end

  post '/hosts/new' do
    begin
      # Try and save the new host
      host = Minicron::Hub::Host.create!(
        name: params[:name],
        fqdn: params[:fqdn],
      )

      host.save!

      # Redirect to the new host
      redirect "#{route_prefix}/host/#{host.id}"
    rescue Exception => e
      @previous = params
      flash.now[:error] = e.message
    end

    erb :'hosts/new', layout: :'layouts/app'
  end

  get '/host/:id/edit' do
    # Find the host
    @host = Minicron::Hub::Host.find(params[:id])

    erb :'hosts/edit', layout: :'layouts/app'
  end

  post '/host/:id/edit' do
    # Find the host
    @host = Minicron::Hub::Host.find(params[:id])

    begin
      # Update its data
      @host.name = params[:name]
      @host.fqdn = params[:fqdn]

      @host.save!

      # Redirect to the updated host
      redirect "#{route_prefix}/host/#{@host.id}"
    rescue Exception => e
      @host.restore_attributes
      flash.now[:error] = e.message
      erb :'hosts/edit', layout: :'layouts/app'
    end
  end

  get '/host/:id/delete' do
    # Look up the host
    @host = Minicron::Hub::Host.find(params[:id])

    erb :'hosts/delete', layout: :'layouts/app'
  end

  post '/host/:id/delete' do
    # Look up the host
    @host = Minicron::Hub::Host.includes(jobs: :schedules).find(params[:id])

    begin
      # Try and delete the host
      Minicron::Hub::Host.destroy(params[:id])

      redirect "#{route_prefix}/hosts"
    rescue Exception => e
      flash.now[:error] = "<h4>Error</h4>
                            <p>#{e.message}</p>
                            <p>You can force delete the host without connecting to the host</p>"
      erb :'hosts/delete', layout: :'layouts/app'
    end
  end
end
