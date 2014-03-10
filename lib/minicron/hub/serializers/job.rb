class Minicron::Hub::App::JobSerializer < ActiveModel::Serializer
  attributes :id, :name, :command, :created_at

  has_one :host, :embed => :objects, include => true
  has_many :executions, :embed => :objects, include => true
end