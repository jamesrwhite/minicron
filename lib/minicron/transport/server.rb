require 'thin'
require 'rack'

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

          map path do
            map '/faye' do
              require './faye.rb'
              run Minicron::Transport::Faye.new
            end

            map '/' do
              require ::File.expand_path('../../hub/config/environment',  __FILE__)
              run Rails.application
            end
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
