class JobExecutionOutput < ActiveRecord::Base
  belongs_to :job
  belongs_to :execution
end
