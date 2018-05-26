class Minicron::Hub::App
  get '/hosts' do
    @hosts = Minicron::Hub::Model::Host.belonging_to(current_user)
                                .all
                                .order(created_at: :desc)

    erb :'hosts/index', layout: :'layouts/app'
  end

  get '/host/:id' do
    @host = Minicron::Hub::Model::Host.belonging_to(current_user).find(params[:id])
    @host_executions = Minicron::Hub::Model::Execution.belonging_to(current_user)
                                                      .includes(:job)
                                                      .where(host_id: @host.id)
                                                      .limit(15)
                                                      .order(created_at: :desc)

    erb :'hosts/show', layout: :'layouts/app'
  end

  get '/hosts/new' do
    # Empty instance to simplify views
    @previous = Minicron::Hub::Model::Host.new

    erb :'hosts/new', layout: :'layouts/app'
  end

  post '/hosts/new' do
    begin
      host = Minicron::Hub::Model::Host.create!(
        user_id: current_user.id,
        name: params[:name],
        hostname: params[:hostname]
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
    @host = Minicron::Hub::Model::Host.belonging_to(current_user)
                               .find(params[:id])

    erb :'hosts/edit', layout: :'layouts/app'
  end

  post '/host/:id/edit' do
    @host = Minicron::Hub::Model::Host.belonging_to(current_user)
                               .find(params[:id])

    begin
      @host.name = params[:name]
      @host.hostname = params[:hostname]
      @host.save!

      redirect "#{route_prefix}/host/#{@host.id}"
    rescue Exception => e
      @host.restore_attributes
      flash.now[:error] = e.message
      erb :'hosts/edit', layout: :'layouts/app'
    end
  end

  get '/host/:id/delete' do
    @host = Minicron::Hub::Model::Host.belonging_to(current_user)
                               .find(params[:id])

    erb :'hosts/delete', layout: :'layouts/app'
  end

  post '/host/:id/delete' do
    @host = Minicron::Hub::Model::Host.belonging_to(current_user).find(params[:id])

    begin
      Minicron::Hub::Model::Host.belonging_to(current_user).destroy(params[:id])

      redirect "#{route_prefix}/hosts"
    rescue Exception => e
      @host.restore_attributes
      flash.now[:error] = e.message
      erb :'hosts/delete', layout: :'layouts/app'
    end
  end
end
