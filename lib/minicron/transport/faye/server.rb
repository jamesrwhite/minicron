require 'thin'
require 'rack'
require 'faye'
require 'minicron/transport/faye/extensions/job_handler'

module Minicron
  module Transport
    class FayeServer
      attr_reader :server

      def initialize
        # Load the Faye thin adapter, this needs to happen first
        Faye::WebSocket.load_adapter('thin')

        # Show debug verbose output if requested
        if Minicron.config['global']['verbose']
          log = Logger.new(STDOUT)
          log.level = Logger::DEBUG
          Faye.logger = log
        end

        # Set up our Faye rack app
        @server = Faye::RackAdapter.new(
          :mount => '', # This is relative to the map faye_path set in server.rb
          :timeout => 25
        )

        @server.add_extension(Minicron::Transport::FayeJobHandler.new)

        # Add all the events we want to listen out for
        add_faye_events
      end

      private
      def add_faye_events
        @server.on(:handshake) do |client_id|
          p [:handshake, client_id] #if Minicron.config['global']['verbose']
        end

        @server.on(:subscribe) do |client_id, channel|
          p [:subscribe, client_id, channel] if Minicron.config['global']['verbose']
        end

        @server.on(:unsubscribe) do |client_id, channel|
          p [:unsubscribe, client_id, channel] if Minicron.config['global']['verbose']
        end

        @server.on(:publish) do |client_id, channel, data|
          p [:published, client_id, channel, data] if Minicron.config['global']['verbose']
        end

        @server.on(:disconnect) do |client_id|
          p [:disconnect, client_id] if Minicron.config['global']['verbose']
        end
      end
    end
  end
end
