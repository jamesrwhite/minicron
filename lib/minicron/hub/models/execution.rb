autoload :ActiveRecord, 'active_record'

module Minicron
  module Hub
    class Execution < ActiveRecord::Base
      belongs_to :job
      has_many :job_execution_outputs, :dependent => :destroy
      has_many :alerts, :dependent => :destroy
    end
  end
end
