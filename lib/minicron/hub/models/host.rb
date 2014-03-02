class Minicron::Hub::Host < ActiveRecord::Base
  has_many :jobs

  # Default the name of the host to the hostname itself if no name is set
  def name
    if read_attribute(:name) == '' || read_attribute(:name) == nil
      read_attribute(:hostname)
    else
      read_attribute(:name)
    end
  end
end
