require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/assetpack'
require 'erubis'
require 'json'

module Minicron::Hub
  class App < Sinatra::Base
    register Sinatra::ActiveRecordExtension
    register Sinatra::AssetPack

    # Set the application root
    set :root, Minicron::HUB_PATH

    # Configure how we server assets
    assets do
      serve '/css', :from => 'assets/css'
      serve '/js', :from => 'assets/js'

      # Set up the application css
      css :app, '/css/all.css', [
        '/css/bootstrap.css',
        '/css/bootstrap-theme.css',
        '/css/main.css'
      ]

      # Set up the application javascript
      js :app, '/js/all.js', [
        '/js/jquery-2.0.3.js',
        '/js/handlebars-1.3.0.js',
        '/js/ember-1.4.0.js',
        '/js/faye-browser-1.0.1.js',
        '/js/app.js'
      ]
    end

    configure :development do
      # Configure the database
      case Minicron.config['database']['type']
      when 'mysql'
        set :database, {
          :adapter => 'mysql2',
          :host => Minicron.config['database']['host'],
          :database => Minicron.config['database']['database'],
          :username => Minicron.config['database']['username'],
          :password => Minicron.config['database']['password']
        }
      when 'sqlite'
        set :database, {
          :adapter => 'sqlite3',
          :database => HUB_PATH + '/db/minicron.sqlite3', # TODO: Allow configuring this but default to this value
        }
      else
        raise Exception, "The database #{Minicron.config['database']['type']} is not supported"
      end
    end
  end
end

# Load all our models
Dir[File.dirname(__FILE__) + '/models/*.rb'].each do |model|
  require model
end

# Load all our controllers
Dir[File.dirname(__FILE__) + '/controllers/*.rb'].each do |controller|
  require controller
end
