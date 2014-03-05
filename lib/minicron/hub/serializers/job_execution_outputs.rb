class Minicron::Hub::App::JobExecutionOutputSerializer < ActiveModel::Serializer
  attributes :id, :execution_id, :job_id, :output, :timestamp
end
