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

        # TODO: Return the correct value!
        5
      end

      # Helper that wraps the publish function making it quicker to use
      #
      # TODO: Add otions hash doc
      def send(options = {})
        # Only send the job execution if we have it
        job_execution_id = job_execution_id ? "/#{options[:job_execution_id]}" : ''

        # Publish the message to the correct channel
        publish("/job/#{options[:job_id]}#{options[:job_execution_id]}/#{options[:type]}", options[:message])
      end

      # Publishes a message on the given channel to the server
      #
      # @param channel [String]
      # @param message [String]
      def publish(channel, message)
        # Set up the data to send to faye
        data = {:channel => channel, :data => {
          :ts => Time.now.to_f,
          :message => message
        }}

        request({ :message => data.to_json })
      end
    end
  end
end
