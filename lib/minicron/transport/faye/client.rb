require 'minicron/transport/client'

module Minicron
  module Transport
    class FayeClient < Minicron::Transport::Client
      # Instantiate a new instance of the client
      #
      # @param host [String] The host to be communicated with
      def initialize(scheme, host, port, path)
        @scheme = scheme
        @host = host
        @path = path == '/' ? '/faye' : "#{path}/faye"
        @port = port
        super(@scheme, @host, @port, @path)
      end

      # Used to set up a job on the server
      #
      # @param job_id [Integer]
      # @return [Integer]
      def setup(job_id)
        # Send a request to set up the job
        send(:job_id => job_id, :type => :status, :message => 'SETUP')

        # Wait for the response..
        ensure_delivery

        # TODO: Handle errors here!
        JSON.parse(responses.first[:body]).first['channel'].split('/')[3]
      end

      # Helper that wraps the publish function making it quicker to use
      #
      # TODO: Add otions hash doc
      def send(options = {})
        # Only send the job execution if we have it
        # TODO: Validate if we should have it or not
        execution_id = options[:execution_id] ? "/#{options[:execution_id]}" : ''

        # Publish the message to the correct channel
        publish("/job/#{options[:job_id]}#{execution_id}/#{options[:type]}", options[:message])
      end

      # Publishes a message on the given channel to the server
      #
      # @param channel [String]
      # @param message [String]
      def publish(channel, message)
        # Set up the data to send to faye
        data = {:channel => channel, :data => {
          :ts => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
          :message => message
        }}

        request({ :message => data.to_json })
      end
    end
  end
end
