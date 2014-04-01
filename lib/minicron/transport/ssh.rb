require 'net/ssh'

module Minicron
  module Transport
    class SSH
      # Set all the options for the ssh instance
      #
      # @option options [String] the host to connect to
      # @option options [Integer] the port number
      # @option options [String] the path to the private key
      def initialize(options = {})
        @host = options[:host]
        @port = options[:port]
        @private_key = File.expand_path(options[:private_key])

        # TODO: Make these configurable?
        @user = 'root'
        @auth_methods = ['publickey']
        @host_key = 'ssh-rsa'
        @timeout = 10
      end

      # Open the SSH connection
      def open
        @ssh = Net::SSH.start(
          @host,
          @user,
          :port => @port,
          :keys => [@private_key],
          :auth_methods => @auth_methods,
          :host_key => @host_key,
          :timeout => @timeout
        )
      end

      # Execute a command on the host and block until output is returned
      #
      # @param command [String]
      def exec!(command)
        @ssh.exec!(command)
      end

      # Close the SSH connection
      def close
        @ssh.close
      end
    end
  end
end
