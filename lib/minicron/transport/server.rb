require 'faye'
require 'thin'
require 'rack'

module Minicron
  module Transport
    class Server
      def self.start!(host, port, path)
        return if running?

        # Load the Faye thin adapter, this needs to happen first
        Faye::WebSocket.load_adapter('thin')

        # Set up our Faye rack app
        faye = Faye::RackAdapter.new(
          :mount => '', # This is mounted to /faye
          :timeout => 25
        )

        faye.on(:handshake) do |client_id|
          p [:handshake, client_id]
        end

        faye.on(:subscribe) do |client_id, channel|
          p [:subscribe, client_id, channel]
        end

        faye.on(:unsubscribe) do |client_id, channel|
          p [:unsubscribe, client_id, channel]
        end

        faye.on(:publish) do |client_id, channel, data|
          p [:published, client_id, channel, data]
        end

        faye.on(:disconnect) do |client_id|
          p [:disconnect, client_id]
        end

        # Start the thin server
        # TODO: make host, port and path configurable
        @@server = Thin::Server.new(host, port) do
          use Rack::CommonLogger
          use Rack::ShowExceptions

          map path do
            run faye
          end
        end

        @@server.start
      end

      def self.stop!
        return unless running?

        @@server.stop
      end

      def self.running?
        return false unless defined? @@server

        @@server.running?
      end
    end
  end
end
