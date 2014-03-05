class Minicron::Hub::App::JobExecutionOutputSerializer < ActiveModel::Serializer
  embed :ids, include => true

  attributes :id, :execution_id, :job_id, :output, :timestamp

  has_one :execution
end
