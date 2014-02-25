require 'thin'
require 'rack'
require 'faye'
require Minicron::HUB_PATH + '/models/execution'

module Minicron
  module Transport
    class FayeServer
      attr_reader :server

      def initialize
        # Load the Faye thin adapter, this needs to happen first
        Faye::WebSocket.load_adapter('thin')

        # log = Logger.new(STDOUT)
        # log.level = Logger::DEBUG
        # Faye.logger = log

        # Set up our Faye rack app
        @server = Faye::RackAdapter.new(
          :mount => '', # This is relative to the map faye_path set in server.rb
          :timeout => 25
        )

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

          # Split the channel into it's segments by /
          segments = channel.split('/')

          # Check if it's a 'job' message and a valid job_id is present
          if segments[1] == 'job' && segments[2].length == 40
            job_id = segments[2]

            # Check if it's a status message
            if segments[3] == 'status'
              # How do we need to handle this?
              if data['message'][0..4] == 'START'
                Execution.create(
                  :job_id => job_id,
                  :start_time => Time.now # TODO: Use the time in the output instead
                )
              end
            end
          end
        end

        @server.on(:disconnect) do |client_id|
          p [:disconnect, client_id] if Minicron.config['global']['verbose']
        end
      end
    end
  end
end
