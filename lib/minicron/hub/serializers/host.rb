class Minicron::Hub::App::HostSerializer < ActiveModel::Serializer
  attributes :id, :hostname, :name, :created_at

  has_many :jobs, :embed => :objects, include => true
end
