class Minicron::Hub::JobExecutionOutput < ActiveRecord::Base
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON

  belongs_to :job
  belongs_to :execution
  has_one :host, :through => :job
end
