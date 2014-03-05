class Minicron::Hub::App::HostSerializer < ActiveModel::Serializer
  attributes :id, :hostname, :name, :created_at, :jobs
end
