require 'digest/sha1'
require 'json'

module Minicron
  module Transport
    def self.get_job_id(command, hostname)
      Digest::SHA1.hexdigest command + hostname
    end
  end
end
