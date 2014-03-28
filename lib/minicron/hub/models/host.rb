module Minicron
  module Hub
    class Host < ActiveRecord::Base
      has_many :jobs, :dependent => :delete_all
    end
  end
end
