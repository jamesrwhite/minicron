class Minicron::Hub::App::HostSerializer < ActiveModel::Serializer
  embed :objects, include => true

  attributes :id, :hostname, :name, :created_at

  has_many :jobs
end
