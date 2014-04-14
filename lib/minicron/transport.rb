require 'digest/md5'

module Minicron
  # The transport module deals with interactions between the server and client
  module Transport
    # Calculate the job hash based on the command and host
    #
    # @param command [String] the job command e.g 'ls -la'
    # @param fqdn [String] the fqdn of the server running the job e.g `db1.example.com`
    def self.get_job_hash(command, fqdn)
      Digest::MD5.hexdigest(command + fqdn)
    end
  end
end
