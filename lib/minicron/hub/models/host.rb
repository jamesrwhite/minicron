class Minicron::Hub::Host < ActiveRecord::Base
  has_many :jobs, :dependent => :delete_all
end
