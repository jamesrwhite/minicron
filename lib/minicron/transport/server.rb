autoload :Thin, 'thin'
autoload :Rack, 'rack'

module Minicron
  module Hub
    autoload :App,                'minicron/hub/app'
    autoload :ExceptionHandling,  'minicron/hub/app'
  end

  module Transport
    autoload :FayeServer, 'minicron/transport/faye/server'

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

          # The 'hub', aka our sinatra web interface
          map path do
            use Minicron::Hub::ExceptionHandling
            run Minicron::Hub::App.new
          end

          # Set the path faye should start relative to
          faye_path = path == '/' ? '/faye' : "#{path}/faye"

          # The faye server the server and browser clients talk to
          map faye_path do
            run Minicron::Transport::FayeServer.new.server
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
    end
  end
end
