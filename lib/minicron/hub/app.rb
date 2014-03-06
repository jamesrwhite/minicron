require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/assetpack'
require 'erubis'
require 'yajl'
require 'active_model_serializers'

module Minicron::Hub
  class App < Sinatra::Base
    register Sinatra::ActiveRecordExtension
    register Sinatra::AssetPack

    # Set the application root
    set :root, Minicron::HUB_PATH

    # Set the json encoder we use
    set :json, Yajl::Encoder.new

    # Configure how we server assets
    assets do
      serve '/css',   :from => 'assets/css'
      serve '/js',    :from => 'assets/js'
      serve '/fonts', :from => 'assets/fonts'

      # Set up the application css
      css :app, '/css/all.css', [
        '/css/bootstrap-theme.css',
        '/css/main.css'
      ]

      # Set up the application javascript
      js :app, '/js/all.js', [
        '/js/jquery-2.0.3.js',
        '/js/handlebars-1.3.0.js',
        '/js/ember-1.4.0.js',
        '/js/ember-data-1.0.0-beta.7.f87cba88.js',
        '/js/faye-browser-1.0.1.js',
        '/js/ansi_up.js',
        '/js/bootstrap.js',
        '/js/app/helpers.js',
        '/js/app/application.js',
        '/js/app/models/job.js',
        '/js/app/models/host.js',
        '/js/app/models/execution.js',
        '/js/app/models/job_execution_output.js',
        '/js/app/routes.js',
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

# Load all our model serializers
Dir[File.dirname(__FILE__) + '/serializers/*.rb'].each do |serializer|
  require serializer
end

# Load all our models
Dir[File.dirname(__FILE__) + '/models/*.rb'].each do |model|
  require model
end

# Load all our controllers
Dir[File.dirname(__FILE__) + '/controllers/*.rb'].each do |controller|
  require controller
end
