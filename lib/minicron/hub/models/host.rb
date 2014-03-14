class Minicron::Hub::Host < ActiveRecord::Base
  has_many :jobs
end
