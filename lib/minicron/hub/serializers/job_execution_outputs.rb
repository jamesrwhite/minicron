class Minicron::Hub::App::JobExecutionOutputSerializer < ActiveModel::Serializer
  embed :objects, include => true

  attributes :id, :execution_id, :output, :timestamp

  has_one :execution
end
