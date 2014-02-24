
class Minicron::Hub::App
  get '/' do
    liquid :index, :layout => :'layouts/main', :locals => {
      :name => 'James',
      :css => css(:app, :media => 'screen'),
      :js => js(:app, :media => 'screen')
    }
  end
end
