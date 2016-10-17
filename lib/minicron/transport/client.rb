require 'json'
require 'net/http/persistent'
require 'pusher'

module Minicron
  module Transport
    class Client
      # Instantiate a new instance of the client
      #
      # @param scheme [String] The protocol to use e.g http/https
      # @param host [String] The host to be communicated with e.g test.com or 127.0.0.1
      # @param username [String] The http basic auth username
      # @param password [String] The http basic auth password
      # @param port [Integer]
      # @param path [String] Path to the minicron server e.g /minicron
      def initialize(scheme, host, username, password, port, path)
        @scheme = scheme
        @host = host
        @username = username
        @password = password
        @path = path == '/' ? '/api/v1' : "#{path}/api/v1"
        @port = port
        @seq = 1
        @client = Net::HTTP::Persistent.new('minicron')

        if Minicron.config['client']['pusher']['enabled']
          @pusher = Pusher::Client.new({
            :app_id => Minicron.config['client']['pusher']['app_id'],
            :key => Minicron.config['client']['pusher']['key'],
            :secret => Minicron.config['client']['pusher']['secret']
          })
        end
      end

      # Used to init a job
      #
      # @param [String] job_hash
      # @param [String] user
      # @param [Integer] command
      # @param [String] fqdn
      # @param [String] hostname
      # @param [Integer] timestamp
      # @return [Hash]
      def init(job_hash, user, command, fqdn, hostname, timestamp)
        # Send a request to set up the job
        response = server_post("/execution/init", {
          :job_hash => job_hash,
          :user => user,
          :command => command,
          :fqdn => fqdn,
          :hostname => hostname,
          :timestamp => timestamp
        })

        # Publish an event to pusher to say the execution has been initialised
        pusher_post(:init, response) if Minicron.config['client']['pusher']['enabled']

        response
      end

      # Mark a job as having started
      #
      # @param [Integer] job_id
      # @param [Integer] execution_id
      # @param [Integer] timestamp
      # @return [Hash]
      def start(job_id, execution_id, timestamp)
        # Send a job execution status to the server
        response = server_post("/execution/start", {
          :job_id => job_id,
          :execution_id => execution_id,
          :timestamp => timestamp,
        })

        # Publish an event to pusher to say the execution has been started
        pusher_post(:start, response) if Minicron.config['client']['pusher']['enabled']

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
        response = server_post("/execution/finish", {
          :job_id => job_id,
          :execution_id => execution_id,
          :timestamp => timestamp,
        })

        # Publish an event to pusher to say the execution has finished
        pusher_post(:finish, response) if Minicron.config['client']['pusher']['enabled']

        response
      end

      # Set the exit status of a job once it has finished
      #
      # @param [Integer] job_id
      # @param [Integer] execution_id
      # @param [Integer] exit_status
      # @return [Hash]
      def exit(job_id, execution_id, exit_status)
        # Send a job execution status to the server
        response = server_post("/execution/exit", {
          :job_id => job_id,
          :execution_id => execution_id,
          :exit_status => exit_status,
        })

        # Publish an event to pusher to say the execution has finished and has an exit code
        pusher_post(:exit, response) if Minicron.config['client']['pusher']['enabled']

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
        response = server_post("/execution/output", {
          :job_id => job_id,
          :execution_id => execution_id,
          :output => output,
        })

        # Publish an event to pusher to say the execution has some output
        pusher_post(:output, response) if Minicron.config['client']['pusher']['enabled']

        response
      end

      # Send a message to the server
      #
      # @param path [String] api method to send to
      # @param body [Hash] data to post to the server
      def server_post(path, body)
        # Set up the data to send to the server
        body[:timestamp] = Time.now.utc.to_i if body[:timestamp].nil?
        body[:seq] = @seq

        # Increment the sequence id
        @seq += 1

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
        # Create a POST request
        uri = URI("#{@scheme}://#{@host}:#{@port}#{@path}#{method}")
        post = Net::HTTP::Post.new(uri.path)
        post.basic_auth @username, @password if @username || @password
        post.set_form_data(data)

        # Execute the POST request, TODO: error handling
        @client.request(uri, post)
      end

      def pusher_post(event, data)
        begin
          @pusher.trigger(
            'executions',
            event,
            data
          )
        rescue => e
          raise Minicron::ClientError, "[Pusher Error] #{e.message}"
        end
      end
    end
  end
end
