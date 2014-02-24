class Job < ActiveRecord::Base
  has_many :executions
  has_many :job_execution_outputs
end
