require Minicron::REQUIRE_PATH + 'hub/models/base'

module Minicron::Hub
  module Model
    class Execution < Minicron::Hub::Model::Base
      belongs_to :job, counter_cache: true
      belongs_to :host, counter_cache: true
      has_many :job_execution_outputs, dependent: :destroy
      has_many :alerts, dependent: :destroy

      validates :job_id, presence: true, numericality: { only_integer: true }
      validates :number, presence: true, numericality: { only_integer: true }
    end
  end
end
