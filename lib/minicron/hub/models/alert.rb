require 'minicron/hub/models/base'

module Minicron
  module Hub
    class Alert < Minicron::Hub::Base
      belongs_to :job
      belongs_to :schedule
      belongs_to :execution
    end
  end
end
