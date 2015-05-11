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
end
