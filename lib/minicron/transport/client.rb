require 'json'
require 'net/http/persistent'
require 'oj'

module Minicron
  module Transport
    class Client
      # Instantiate a new instance of the client
      #
      # @param host [String] The host to be communicated with
      def initialize(scheme, host, port, path)
        @scheme = scheme
        @host = host
        @path = path == '/' ? '/api/v1' : "#{path}/api/v1"
        @port = port
        @seq = 1
        @client = Net::HTTP::Persistent.new('minicron')
      end

      # Used to init a job
      #
      # @param [String] job_hash
      # @param [String] user
      # @param [Integer] command
      # @param [String] fqdn
      # @param [String] hostname
      # @return [Hash]
      def init(job_hash, user, command, fqdn, hostname)
        # Send a request to set up the job
        response = send("/jobs/init", {
          :hash => job_hash,
          :user => user,
          :command => command,
          :fqdn => fqdn,
          :hostname => hostname,
        })

        {
          :job_id => response['job_id'],
          :execution_id => response['execution_id'],
          :execution_number => response['execution_number'],
        }
      end

      # Used to update the status of a job
      #
      # @param [String, Symbol] status
      # @param [Integer] job_id
      # @param [Integer] execution_id
      # @param [String, Integer] meta
      # @return [Hash]
      def status(status, job_id, execution_id, meta)
        # Send a job execution status to the server
        response = send("/jobs/status", {
          :status => status,
          :job_id => job_id,
          :execution_id => execution_id,
          :meta => meta,
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
        response = send("/jobs/output", {
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
        body[:timestamp] = Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')
        body[:seq] = @seq

        # Increment the sequence id
        @seq += 1

        # Fetch the result
        result = post(path, body)

        # Did the request succeed?
        if result.body
          begin
            # Get the response body and parse it
            response = Oj.load(result.body)
          rescue
            raise Exception, "Error parsing JSON response: \"#{result.body}\""
          end

          if response[:error].nil?
            response
          else
            raise Exception, "Error: #{body[:error]}"
          end
        else
          raise Exception, 'No response body returned from API'
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
      end
    end
  end
end
