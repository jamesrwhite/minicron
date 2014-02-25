class Minicron::Hub::App
  get '/' do
    erb :index, :layout => :'layouts/app'
  end
end
