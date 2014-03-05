class Minicron::Hub::App::ExecutionSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :created_at, :started_at, :finished_at, :exit_status

  has_one :job
end
