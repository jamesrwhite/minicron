require 'minicron'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/assetpack'
require 'erubis'
require 'oj'

module Minicron::Hub
  class App < Sinatra::Base
    register Sinatra::ActiveRecordExtension
    register Sinatra::AssetPack

    # Set the application root
    set :root, Minicron::HUB_PATH

    # Configure how we server assets
    assets do
      serve '/css',   :from => 'assets/css'
      serve '/js',    :from => 'assets/js'
      serve '/fonts', :from => 'assets/fonts'
      serve '/app',   :from => 'assets/app'

      # Set up the application css
      css :app, '/css/all.css', [
        '/css/bootswatch.css',
        '/css/main.css'
      ]

      # Set up the application javascript
      js :app, '/js/all.js', [
        # Dependencies, the order of these is important
        '/js/jquery-2.1.0.min.js',
        '/js/handlebars-1.3.0.min.js',
        '/js/ember-1.4.1.min.js',
        '/js/ember-data-1.0.0-beta.7.f87cba88.min.js',
        '/js/faye-browser-1.0.1.min.js',
        '/js/ansi_up-1.1.1.min.js',
        '/js/bootstrap-3.1.1.min.js',
        '/js/moment-2.5.1.min.js',

        # Ember application files
        '/app/**/*.js'
      ]
    end

    def initialize
      super

      # Initialize the db
      Minicron::Hub::App.setup_db

      # Load all our model serializers
      Dir[File.dirname(__FILE__) + '/serializers/*.rb'].each do |serializer|
        require serializer
      end

      # Load all our models
      Dir[File.dirname(__FILE__) + '/models/*.rb'].each do |model|
        require model
      end

      # Load all our controllers
      Dir[File.dirname(__FILE__) + '/controllers/**/*.rb'].each do |controller|
        require controller
      end
    end

    def self.setup_db
      # For debug, TODO: remove this
      puts "Using #{Minicron.config['database']['type']}"

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
      else
        raise Exception, "The database #{Minicron.config['database']['type']} is not supported"
      end
    end
  end
end
