module Minicron
  module Hub
    class Execution < ActiveRecord::Base
      belongs_to :job
      has_many :job_execution_outputs, :dependent => :destroy
    end
  end
end
