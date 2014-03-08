class Minicron::Hub::JobExecutionOutput < ActiveRecord::Base
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON

  belongs_to :execution
end
