class Job < ActiveRecord::Base
  has_many :executions
  has_many :job_execution_outputs

  # Default the name of the command to the command itself if no name is set
  def name
    if read_attribute(:name) == '' || read_attribute(:name) == nil
      read_attribute(:command)
    else
      read_attribute(:name)
    end
  end
end
