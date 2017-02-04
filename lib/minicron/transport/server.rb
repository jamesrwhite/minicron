require 'thin'
require 'rack'

module Minicron
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

        @server = Thin::Server.new(host, port) do
          map path do
            require 'minicron/hub/app'
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
        return false if @server.nil?

        @server.running?
      end

      # Save doing this logic in every controller redirect
      def self.get_prefix
        Minicron.config['server']['path'] == '/' ? nil : Minicron.config['server']['path']
      end
    end
  end
end
