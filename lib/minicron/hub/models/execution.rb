require 'minicron/hub/models/base'

module Minicron
  module Hub
    class Execution < Minicron::Hub::Base
      belongs_to :job, counter_cache: true
      has_many :job_execution_outputs, dependent: :destroy
      has_many :alerts, dependent: :destroy

      validates :job_id, presence: true, numericality: { only_integer: true }
      validates :number, presence: true, numericality: { only_integer: true }
    end
  end
end
