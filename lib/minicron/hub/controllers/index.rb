
class Minicron::Hub::App
  get '/' do
    p Job.all

    liquid :index, :layout => :'layouts/main', :locals => {
      :name => 'James'
    }
  end
end
