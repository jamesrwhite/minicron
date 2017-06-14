require 'digest'

module Minicron
  # The transport module deals with interactions between the server and client
  module Transport
    # Calculate the job hash based on the command and host
    #
    # @param command [String] the job command e.g 'ls -la'
    def self.get_job_hash(command)
      Digest::SHA256.hexdigest(command)
    end
  end
end
