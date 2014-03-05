require 'eventmachine'
require 'em-http-request'
require 'digest/sha1'

module Minicron
  module Transport
    class Client
      attr_accessor :url
      attr_accessor :queue
      attr_accessor :responses

      # Instantiate a new instance of the client
      #
      # @param scheme [String] http or https
      # @param host [String] The host to be communicated with
      # @param port [String] The port number the server runs on
      # @param path [String] The path to the server, optional
      def initialize(scheme, host, port, path) # TODO: Add options hash for other options
        @scheme = scheme
        @host = host
        @path = path
        @port = port
        @url = "#{scheme}://#{host}:#{port}#{path}"
        @queue = {}
        @responses = []
        @retries = 3
        @retry_counts = {}
      end

      # Starts EventMachine in a new thread if it isn't already running
      def ensure_em_running
        Thread.new { EM.run } unless EM.reactor_running?
        sleep 0.1 until EM.reactor_running?
      end

      # Sends a request to the @url and adds it to the request queue
      #
      # @param body [String]
      def request(body)
        # Make sure eventmachine is running
        ensure_em_running

        # Wait until there is some space in the queue so we don't overwhelm the server
        # until queue.length <= 10
        #   sleep 1
        # end

        # Make the request
        req = EventMachine::HttpRequest.new(
          @url,
          :connect_timeout => Minicron.config['client']['connect_timeout'],
          :inactivity_timeout => Minicron.config['client']['inactivity_timeout']
        ).post(:body => body)

        # Generate an id for the request
        req_id = Digest::SHA1.hexdigest(body.to_s)

        # Put the request in the queue
        queue[req_id] = req

        # Set up the retry count for this request if it didn't already exist
        @retry_counts[req_id] ||= 0

        # p "[minicron] Sending #{req_id}"

        # Did the request succeed? If so remove it from the queue
        req.callback do
          @responses.push({
            :status => req.response_header.status,
            :header => req.response_header,
            :body => req.response
          })

          # p "[minicron] ACK #{req_id}"

          queue.delete(req_id)
        end

        # If not retry the request up to @retries times
        req.errback do |error|
          @responses.push({
            :status => req.response_header.status,
            :header => req.response_header,
            :body => req.response
          })

          # p "[minicron] #{req.response}"

          if @retry_counts[req_id] < @retries
            # puts "[minicron] Retrying #{req_id} x#{@retry_counts[req_id]}"
            @retry_counts[req_id] += 1
            request(body)
          end
        end
      end

      # Blocks until all messages in the sending queue have completed
      def ensure_delivery
        # Keep waiting until the queue is empty but only if we need to
        # p "[minicron] init queue length is #{queue.length}"
        if queue.length > 0
          until queue.length == 0
            sleep 0.05
            # p "[minicron] queue length is #{queue.length}"
          end
        end

        true
      end

      # Tidy up after we are done with the client
      def tidy_up
        EM.stop
      end
    end
  end
end
