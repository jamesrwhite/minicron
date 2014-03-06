class Minicron::Hub::App::JobSerializer < ActiveModel::Serializer
  embed :objects, include => true

  attributes :id, :name, :command, :created_at

  has_one :host
end