class Minicron::Hub::App
  get '/alerts' do
    @alerts = Minicron::Hub::Alert.all.includes(:job, :schedule, :execution)

    erb :'alerts/index', :layout => :'layouts/app'
  end

  get '/alert/:id' do
    @alert = Minicron::Hub::Alert.includes(:job, :schedule, :execution).find(params[:id])

    erb :'alerts/show', :layout => :'layouts/app'
  end
end
