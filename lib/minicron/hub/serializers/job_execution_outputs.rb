class Minicron::Hub::App::JobExecutionOutputSerializer < ActiveModel::Serializer
  attributes :id, :execution_id, :output, :timestamp

  has_one :execution, :embed => :objects, include => true
end
