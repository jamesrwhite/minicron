class Minicron::Hub::App::ExecutionSerializer < ActiveModel::Serializer
  embed :objects, include => true

  attributes :id, :created_at, :started_at, :finished_at, :exit_status

  has_one :job
  has_many :job_execution_outputs
end
