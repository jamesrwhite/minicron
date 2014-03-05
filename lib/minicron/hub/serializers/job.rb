class Minicron::Hub::App::JobSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :name, :command, :created_at

  has_one :host
end