require 'faye'

module Minicron
  module Transport
    class Faye
      def initialize
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

        faye
      end
    end
  end
end
