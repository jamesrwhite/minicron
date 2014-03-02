class Minicron::Hub::Execution < ActiveRecord::Base
  belongs_to :job
  has_many :job_execution_output
end
