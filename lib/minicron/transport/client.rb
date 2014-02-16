require 'net/http'

module Minicron
  module Transport
    class Client
      def initialize(host)
        @host = URI.parse(host)
      end

      def publish(channel, message)
        # Set up the data to send to faye
        data = {:channel => "/#{channel}", :data => {
          :ts => Time.now.to_f,
          :data => message
        }}

        # Post it via a HTTP post
        Net::HTTP.post_form(@host, :message => data.to_json)
      end
    end
  end
end
