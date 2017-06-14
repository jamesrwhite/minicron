require Minicron::REQUIRE_PATH + 'hub/models/base'

module Minicron::Hub
  module Model
    class Alert < Minicron::Hub::Model::Base
      belongs_to :job
      belongs_to :schedule
      belongs_to :execution
    end
  end
end
