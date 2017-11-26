require Minicron::REQUIRE_PATH + 'hub/models/base'

module Minicron::Hub
  module Model
    class JobExecutionOutput < Minicron::Hub::Model::Base
      belongs_to :execution

      validates :execution_id, presence: true, numericality: { only_integer: true, greater_than: 0 }
      validates :seq, presence: true, numericality: { only_integer: true, greater_than: 0 }
      validates :timestamp, presence: true

      def safe_output
        CGI.escapeHTML(read_attribute(:output))
      end
    end
  end
end
