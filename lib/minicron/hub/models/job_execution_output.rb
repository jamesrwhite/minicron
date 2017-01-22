require 'active_record'

module Minicron
  module Hub
    class JobExecutionOutput < ActiveRecord::Base
      belongs_to :execution

      validates :execution_id, presence: true, numericality: { only_integer: true }
      validates :seq, presence: true, numericality: { only_integer: true }
      validates :timestamp, presence: true

      def safe_output
        CGI.escapeHTML(read_attribute(:output))
      end
    end
  end
end
