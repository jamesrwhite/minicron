require 'active_record'

module Minicron
  module Hub
    class Execution < ActiveRecord::Base
      belongs_to :job
      has_many :job_execution_outputs, dependent: :destroy
      has_many :alerts, dependent: :destroy

      validates :job_id, presence: true, numericality: { only_integer: true }
      validates :number, presence: true, numericality: { only_integer: true }
    end
  end
end
