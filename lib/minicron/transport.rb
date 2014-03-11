require 'digest/md5'
require 'json'

module Minicron
  # The transport module deals with interactions between the server and client
  module Transport
    # Calculate the job hash based on the command and host
    #
    # @param command [String] the job command e.g 'ls -la'
    # @param hostname [String] the hostname of the server running the job e.g `hostname`
    def self.get_job_hash(command, hostname)
      Digest::MD5.hexdigest(command + hostname)
    end
  end
end
