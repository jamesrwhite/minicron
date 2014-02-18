require 'eventmachine'
require 'em-http-request'

module Minicron
  module Transport
    class Client
      attr_accessor :host
      attr_accessor :queue
      attr_accessor :responses

      def initialize(host)
        @host = URI.parse(host)
        @queue = {}
        @responses = {}
      end

      def ensure_em_running
        Thread.new { EM.run } unless EM.reactor_running?
        sleep 0.1 until EM.reactor_running?
      end

      def publish(channel, message)
        # Set up the data to send to faye
        data = {:channel => "/#{channel}", :data => {
          :ts => Time.now.to_f,
          :output => message
        }}

        # Make sure eventmachine is running
        ensure_em_running

        # Make the request
        req = EventMachine::HttpRequest.new(@host).post(
          :body => { :message => data.to_json }
        )

        # Record roughly the time the request was made
        time = Time.now.to_f

        # Put the request in the queue
        @queue["#{req.to_s}@#{time}"] = req

        # Did the request succeed? If so remove it from the queue
        req.callback do
          @responses = {
            :status => req.response_header.status,
            :header => req.response_header,
            :body => req.response
          }

          @queue.delete("#{req.to_s}@#{time}")
        end

        # If not  output the error message
        # TODO: retry logic?
        req.errback do |error|
          puts error.message
        end
      end

      def ensure_delivery
        # Keep waiting until the queue is empty but only if we need to
        sleep 0.05 until @queue.length == 0 if @queue.length > 0

        # Stop eventmachine now we're done
        EM.stop

        true
      end
    end
  end
end
