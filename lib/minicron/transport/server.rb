autoload :Thin, 'thin'
autoload :Rack, 'rack'

module Minicron
  module Hub
    autoload :App, 'minicron/hub/app'
  end

  module Transport
    # Used to mangage the web server minicron runs on
    class Server
      @server = nil

      class << self
        attr_accessor :server
      end

      # Starts the thin server
      #
      # @param host [String] the host e.g 0.0.0.0
      # @param port [Integer]
      # @param path [String] The absolute path to the server e.g /server
      def self.start!(host, port, path)
        return false if running?

        # Start the faye or rails apps depending on the path
        @server = Thin::Server.new(host, port) do
          use Rack::CommonLogger
          use Rack::ShowExceptions
          use Rack::Session::Cookie, :key => Minicron.config['server']['session']['name'],
                                     :domain => Minicron.config['server']['session']['domain'],
                                     :path => Minicron.config['server']['session']['path'],
                                     :expire_after => Minicron.config['server']['session']['ttl'],
                                     :secret => Minicron.config['server']['session']['secret']

          # The 'hub', aka our sinatra web interface
          map path do
            run Minicron::Hub::App.new
          end
        end

        @server.start
        true
      end

      # Stops the thin server if it's running
      # @return [Boolean] whether the server was stopped or not
      def self.stop!
        return false unless running? && !@server.nil?

        @server.stop
        true
      end

      # Returns a bool based on whether
      # @return [Boolean]
      def self.running?
        return false unless !@server.nil?

        @server.running?
      end

      # Save doing this logic in every controller redirect
      def self.get_prefix
        Minicron.config['server']['path'] == '/' ? nil : Minicron.config['server']['path']
      end
    end
  end
end
