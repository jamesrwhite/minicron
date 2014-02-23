require 'thin'
require 'rack'
require 'faye'

module Minicron
  module Transport
    class Server
      attr_accessor :server

      # Starts the thin server
      #
      # @param host [String] the host e.g 0.0.0.0
      # @param port [Integer]
      # @param path [String] The absolute path to the server e.g /server
      def start!(host, port, path)
        return false if running?

        # Start the faye or rails apps depending on the path
        server = Thin::Server.new(host, port) do
          use Rack::CommonLogger
          use Rack::ShowExceptions

          # The 'hub', aka our sinatra web interface
          map '/' do
            require Minicron::LIB_PATH + '/minicron/hub/app'
            run Minicron::Hub::App.new
          end

          # Set the path faye should start relative to
          faye_path = path == '/' ? '/faye' : "#{path}/faye"

          # The faye server the server and browser clients talk to
          map faye_path do
            # Load the Faye thin adapter, this needs to happen first
            Faye::WebSocket.load_adapter('thin')

            # Set up our Faye rack app
            faye = Faye::RackAdapter.new(
              :mount => '', # This is mounted to /#{path}
              :timeout => 25
            )

            faye.on(:handshake) do |client_id|
              # TODO: Respect the --verbose option here
              p [:handshake, client_id]
            end

            faye.on(:subscribe) do |client_id, channel|
              # TODO: Respect the --verbose option here
              p [:subscribe, client_id, channel]
            end

            faye.on(:unsubscribe) do |client_id, channel|
              # TODO: Respect the --verbose option here
              p [:unsubscribe, client_id, channel]
            end

            faye.on(:publish) do |client_id, channel, data|
              # TODO: Respect the --verbose option here
              p [:published, client_id, channel, data]
            end

            faye.on(:disconnect) do |client_id|
              # TODO: Respect the --verbose option here
              p [:disconnect, client_id]
            end

            run faye
          end
        end

        server.start
        true
      end

      # Stops the thin server if it's running
      # @return [Boolean] whether the server was stopped or not
      def stop!
        return false unless running? && server != nil

        server.stop
        true
      end

      # Returns a bool based on whether
      # @return [Boolean]
      def running?
        return false unless server != nil

        server.running?
      end
    end
  end
end
