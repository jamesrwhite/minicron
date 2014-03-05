class Minicron::Hub::Execution < ActiveRecord::Base
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON

  belongs_to :job
  has_one :host, :through => :job
  has_many :job_execution_outputs
end
