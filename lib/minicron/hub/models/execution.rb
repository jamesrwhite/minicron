class Minicron::Hub::Execution < ActiveRecord::Base
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON

  belongs_to :job
  belongs_to :host
  has_many :job_execution_outputs
end
