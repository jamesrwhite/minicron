class Minicron::Hub::App::JobSerializer < ActiveModel::Serializer
  attributes :id, :job_hash, :name, :command, :created_at, :updated_at

  has_one :host, :embed => :objects, include => true
  has_many :executions, :embed => :objects, include => true
end