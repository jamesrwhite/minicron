class Minicron::Hub::App
  get '/schedule/:id' do
    # Look up the schedule
    @schedule = Minicron::Hub::Schedule.find(params[:id])

    erb :'schedules/show', :layout => :'layouts/app'
  end
end
