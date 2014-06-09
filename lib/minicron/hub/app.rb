require 'minicron'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/assetpack'
require 'erubis'
require 'oj'
require 'pathname'

module Minicron::Hub
  class App < Sinatra::Base
    register Sinatra::ActiveRecordExtension
    register Sinatra::AssetPack

    # Set the application root
    set :root, Minicron::HUB_PATH

    configure do
      # Don't log them. We'll do that ourself
      set :dump_errors, false

      # Don't capture any errors. Throw them up the stack
      set :raise_errors, true

      # Disable internal middleware for presenting errors
      # as useful HTML pages
      set :show_exceptions, false

      # Used to enable asset compression, currently nothing else
      # relies on this
      set :environment, :production

      # Force the encoding to be UTF-8 to prevent assetpack encoding issues
      Encoding.default_external = Encoding::UTF_8
    end

    # Configure how we server assets
    assets do
      serve '/css',   :from => 'assets/css'
      serve '/js',    :from => 'assets/js'
      serve '/fonts', :from => 'assets/fonts'
      serve '/app',   :from => 'assets/app'

      js_compression :simple

      # Set up the application css
      css :app, '/css/all.css', [
        '/css/bootswatch.min.css',
        '/css/main.css',
        '/css/perfect-scrollbar-0.4.10.min.css'
      ]

      # Set up the application javascript
      js :app, '/js/all.js', [
        # Dependencies, the order of these is important
        '/js/jquery-2.1.0.min.js',
        '/js/handlebars-1.3.0.min.js',
        '/js/ember-1.5.1.min.js',
        '/js/ember-data-1.0.0-beta.7.f87cba88.min.js',
        '/js/faye-browser-1.0.1.min.js',
        '/js/ansi_up-1.1.1.min.js',
        '/js/bootstrap-3.1.1.min.js',
        '/js/moment-2.5.1.min.js',
        '/js/perfect-scrollbar-0.4.10.with-mousewheel.min.js',

        # Ember application files
        '/app/**/*.js'
      ]
    end

    # Called on class initilisation, sets up the database and requires all
    # the application files
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

    # Used to set up the database connection
    def self.setup_db
      # Configure the database
      case Minicron.config['database']['type']
      when 'mysql'
        set :database,
            :adapter => 'mysql2',
            :host => Minicron.config['database']['host'],
            :database => Minicron.config['database']['database'],
            :username => Minicron.config['database']['username'],
            :password => Minicron.config['database']['password']
      when 'sqlite'
        # Calculate the realtive path to the db because sqlite or activerecord is
        # weird and doesn't seem to handle abs paths correctly
        root = Pathname.new(Dir.pwd)
        db = Pathname.new(Minicron::HUB_PATH + '/db')
        db_rel_path = db.relative_path_from(root)

        ActiveRecord::Base.establish_connection(
          :adapter => 'sqlite3',
          :database => "#{db_rel_path}/minicron.sqlite3" # TODO: Allow configuring this but default to this value
        )
      else
        fail Exception, "The database #{Minicron.config['database']['type']} is not supported"
      end

      # Enable ActiveRecord logging if in verbose mode
      ActiveRecord::Base.logger = Minicron.config['verbose'] ? Logger.new(STDOUT) : nil
    end
  end

  # Based on http://hawkins.io/2013/06/error-handling-in-sinatra-apis/
  class ExceptionHandling
    def initialize(app)
      @app = app
    end

    def handle_exception(env, e, status)
      if Minicron.config['trace']
        env['rack.errors'].puts(e)
        env['rack.errors'].puts(e.backtrace.join("\n"))
        env['rack.errors'].flush
      end

      # Display the error message
      hash = { :error => e.to_s }

      # Display the full trace if tracing is enabled
      hash[:trace] = e.backtrace if Minicron.config['trace']

      [status, { 'Content-Type' => 'application/json' }, [hash.to_json]]
    end

    def call(env)
      begin
        @app.call env
      rescue ActiveRecord::RecordNotFound => e
        handle_exception(env, e, 404)
      rescue Exception => e
        handle_exception(env, e, 500)
      end
    end
  end
end
