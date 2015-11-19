require 'json'
<<<<<<< HEAD
=======
require 'net/http/persistent'
>>>>>>> upstream/master

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
<<<<<<< HEAD
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
=======
          :job_id => response['job_id'],
          :execution_id => response['execution_id'],
        }
      end

      # Mark a job as having started
      #
      # @param [Integer] job_id
      # @param [Integer] execution_id
      # @param [Integer] timestamp
      # @return [Hash]
      def start(job_id, execution_id, timestamp)
        # Send a job execution status to the server
        response = send("/execution/start", {
          :execution_id => execution_id,
          :timestamp => timestamp,
        })

        response
      end

      # Mark a job as having finished
      #
      # @param [Integer] job_id
      # @param [Integer] execution_id
      # @param [Integer] timestamp
      # @return [Hash]
      def finish(job_id, execution_id, timestamp)
        # Send a job execution status to the server
        response = send("/execution/finish", {
          :execution_id => execution_id,
          :timestamp => timestamp,
        })

        response
>>>>>>> upstream/master
      end

      # Publishes a message on the given channel to the server
      #
<<<<<<< HEAD
      # @param channel [String]
      # @param message [String, Hash]
      def publish(channel, message)
        # Set up the data to send to faye
        data = { :channel => channel, :data => {
          :ts => Time.now.utc.strftime('%Y-%m-%d %H:%M:%S'),
          :message => message,
          :seq => @seq
        } }
=======
      # @param [Integer] job_id
      # @param [Integer] execution_id
      # @param [Integer] exit_status
      # @return [Hash]
      def exit(job_id, execution_id, exit_status)
        # Send a job execution status to the server
        response = send("/execution/exit", {
          :job_id => job_id,
          :execution_id => execution_id,
          :exit_status => exit_status,
        })

        response
      end

      # Used to send output from the job execution
      #
      # @param [Integer] job_id
      # @param [Integer] execution_id
      # @param [String] output
      # @return [Hash]
      def output(job_id, execution_id, output)
        # Send the job execution output to the server
        response = send("/execution/output", {
          :job_id => job_id,
          :execution_id => execution_id,
          :output => output,
        })

        response
      end

      # Send a message to the server
      #
      # @param path [String] api method to send to
      # @param body [Hash] data to post to the server
      def send(path, body)
        # Set up the data to send to the server
        body[:timestamp] = Time.now.utc.to_i if body[:timestamp].nil?
        body[:seq] = @seq
>>>>>>> upstream/master

        # Increment the sequence id
        @seq += 1

<<<<<<< HEAD
        request(:message => data.to_json)
=======
        # Fetch the result
        result = post(path, body)

        # Did the request succeed?
        if result.body
          begin
            # Get the response body and parse it
            response = JSON.parse!(result.body)
          rescue
            raise Minicron::ClientError, "[General Error] Invalid JSON response \"#{result.body}\""
          end

          if response['error'].nil?
            response
          else
            raise Minicron::ClientError, "[API Error] #{response['error']}"
          end
        else
          raise Minicron::ClientError, '[General Error] No response body returned from API'
        end
      end

      private

      def post(method, data)
        # Create a POST requests
        uri = URI("#{@scheme}://#{@host}:#{@port}#{@path}#{method}")
        post = Net::HTTP::Post.new(uri.path)
        post.set_form_data(data)

        # Execute the POST request, TODO: error handling
        @client.request(uri, post)
>>>>>>> upstream/master
      end
    end
  end
end
