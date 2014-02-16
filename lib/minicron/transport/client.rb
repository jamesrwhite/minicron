require 'faye'
require 'eventmachine'

module Minicron
  module Transport
    class Client
      def initialize(host)
        @client = Faye::Client.new(host)
        @queue = {}
      end

      def ensure_em_running
        Thread.new { EM.run } unless EM.reactor_running?
        sleep 0.1 until EM.reactor_running?
      end

      def publish(channel, message)
        ensure_em_running

        # Slightly nasty way to ensure messages are delivered in order
        # until @queue.length == 0
        #   sleep(0)
        # end

        publication = @client.publish("/#{channel}", {
          :ts => Time.now.to_f,
          :data => message
        })

        time = Time.now.to_f
        @queue["#{publication.to_s}@#{time}"] = publication

        publication.callback do
          @queue.delete("#{publication.to_s}@#{time}")
        end

        publication.errback do |error|
          puts error.message
        end
      end

      def ensure_delivery
        until @queue.length == 0
          sleep 0.05
        end
      end
    end
  end
end
