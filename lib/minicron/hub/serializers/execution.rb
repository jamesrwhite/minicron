class Minicron::Hub::App::ExecutionSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :started_at, :finished_at, :exit_status

  has_one :job, :embed => :objects, include => true
  has_many :job_execution_outputs, :embed => :objects, include => true
end
