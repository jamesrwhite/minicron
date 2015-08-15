require 'net/ssh'

module Minicron
  module Transport
    class SSH
      # Set all the options for the ssh instance
      #
      # @option options [String] user
      # @option options [String] host
      # @option options [Integer] port
      # @option options [String] path to the private key
      def initialize(options = {})
        @user = options[:user]
        @host = options[:host]
        @port = options[:port]
        @private_key = File.expand_path(options[:private_key])

        # TODO: Make these configurable?
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
          :timeout => Minicron.config['server']['ssh']['connect_timeout']
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
        @ssh.close unless @ssh.nil?
      end
    end
  end
end
