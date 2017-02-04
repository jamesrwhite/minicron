# Apparently this is the only way to conditionally load this, eww
begin
  require 'better_errors'
rescue LoadError
end

require 'active_record'
require 'minicron'
require 'sinatra/base'
require 'sinatra/json'
require 'erubis'
require 'pathname'
require 'ansi-to-html'
require 'sinatra/flash'
require 'cron2english'
require 'better_errors'
require 'sinatra/asset_pipeline'

module Minicron::Hub
  class App < Sinatra::Base
    # Connect to the database
    Minicron.establish_db_connection(
      Minicron.config['server']['database'],
      Minicron.config['verbose']
    )

    # Load all our models
    Dir[File.dirname(__FILE__) + '/models/*.rb'].each do |model|
      require model
    end

    # Load all our controllers
    Dir[File.dirname(__FILE__) + '/controllers/**/*.rb'].each do |controller|
      require controller
    end

    # Load all our middlewares
    Dir[File.dirname(__FILE__) + '/middleware/**/*.rb'].each do |middleware|
      require middleware
    end

    configure do
      # Set the application root
      set :root, Minicron::HUB_PATH

      # Always compress assets
      set :environment, :production

      # Serve static assets from ./public
      set :public_folder, "#{Minicron::HUB_PATH}/public"

      # Don't log them. We'll do that ourself
      set :dump_errors, false

      # Don't capture any errors. Throw them up the stack
      set :raise_errors, true

      # Disable internal middleware for presenting errors as HTML
      set :show_exceptions, false

      # Include these files when precompiling assets
      set :assets_precompile, %w(app.js app.css *.png *.jpg *.svg *.eot *.ttf *.woff *.woff2)

      # Asset set up
      set :assets_paths, %w(assets/sass assets/js assets/fonts)

      # CSS minification
      set :assets_css_compressor, :sass

      # JavaScript minification
      set :assets_js_compressor, :uglifier

      # Force the encoding to be UTF-8
      Encoding.default_external = Encoding::UTF_8
    end

    # Middleware
    use Rack::CommonLogger
    use Rack::ShowExceptions
    use BetterErrors::Middleware
    BetterErrors.application_root = __dir__
    use Rack::Session::Cookie, key: Minicron.config['server']['session']['name'],
                               domain: Minicron.config['server']['session']['domain'],
                               path: Minicron.config['server']['session']['path'],
                               expire_after: Minicron.config['server']['session']['ttl'],
                               secret: Minicron.config['server']['session']['secret']

    # Extensions
    register Sinatra::Flash
    register Sinatra::AssetPipeline

    # Auth middleware
    use Minicron::Hub::Middleware::Auth

    # Register our helpers
    helpers do
      def signed_in?
        session[:user_id] != nil
      end

      def current_user
        nil if !signed_in?

        Minicron::Hub::User.find(session[:user_id])
      end

      def route_prefix
        Minicron::Transport::Server.get_prefix
      end

      def cron2english(schedule)
        Cron2English.parse(schedule).join(' ')
      end

      def nav_page
        # Strip the server prefix off the request path
        prefix = Minicron::Transport::Server.get_prefix.to_s
        path = request.fullpath[prefix.length..-1]

        if request.fullpath[0..9] == '/execution'
          :execution
        elsif request.fullpath[0..3] == '/job'
          :job
        elsif request.fullpath[0..4] == '/host'
          :host
        elsif request.fullpath[0..5] == '/alert'
          :alert
        else
          :unknown
        end
      end

      def ansi_to_html(output)
        Ansi::To::Html.new(output).to_html(:solarized)
      end
    end

    def initialize
      super
    end
  end
end
