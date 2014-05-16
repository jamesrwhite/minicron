require 'json'

module Minicron
  module Transport
    autoload :FayeClient, 'minicron/transport/faye/client'

    class Client < Minicron::Transport::FayeClient
      # Instantiate a new instance of the client
      #
      # @param host [String] The host to be communicated with
      def initialize(scheme, host, port, path)
        @scheme = scheme
        @host = host
        @path = path == '/' ? '/faye' : "#{path}/faye"
        @port = port
        @seq = 1
        super(@scheme, @host, @port, @path)
      end

      # Used to set up a job on the server
      #
      # @option options [String] job_hash
      # @option options [String] user
      # @option options [Integer] command
      # @option options [String] fqdn
      # @option options [String] hostname
      # @return [Hash]
      def setup(options = {})
        # Send a request to set up the job
        publish("/job/#{options[:job_hash]}/status",
          :action => 'SETUP',
          :user => options[:user],
          :command => options[:command],
          :fqdn => options[:fqdn],
          :hostname => options[:hostname]
        )

        # Wait for the response..
        ensure_delivery

        # TODO: Handle errors here!
        # Get the job and execution id from the response
        begin
          ids = JSON.parse(@responses.first[:body]).first['channel'].split('/')[3]
        rescue Exception => e
          raise Exception, "Unable to parse JSON response of: '#{@responses.first[:body]}', reason: #{e.message}"
        end

        # Split them up
        ids = ids.split('-')

        # Return them as a hash
        {
          :job_id => ids[0],
          :execution_id => ids[1],
          :number => ids[2]
        }
      end

      # Helper that wraps the publish function making it quicker to use
      #
      # @option options [String] job_id
      # @option options [Integer] execution_id
      # @option options [String, Symbol] type status or output
      # @option options [String, Hash]
      def send(options = {})
        # Publish the message to the correct channel
        publish("/job/#{options[:job_id]}/#{options[:execution_id]}/#{options[:type]}", options[:message])
      end

      # Publishes a message on the given channel to the server
      #
      # @param channel [String]
      # @param message [String, Hash]
      def publish(channel, message)
        # Set up the data to send to faye
        data = { :channel => channel, :data => {
          :ts => Time.now.utc.strftime('%Y-%m-%d %H:%M:%S'),
          :message => message,
          :seq => @seq
        } }

        # Increment the sequence id
        @seq += 1

        request(:message => data.to_json)
      end
    end
  end
end
