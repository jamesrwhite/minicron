class Minicron::Hub::App
  get '/alerts' do
    @alerts = Minicron::Hub::Model::Alert.belonging_to(current_user)
                                  .includes(:job, :schedule, :execution)
                                  .all

    erb :'alerts/index', layout: :'layouts/app'
  end

  get '/alert/:id' do
    @alert = Minicron::Hub::Model::Alert.belonging_to(current_user)
                                 .includes(:job, :schedule, :execution)
                                 .find(params[:id])

    erb :'alerts/show', layout: :'layouts/app'
  end
end
