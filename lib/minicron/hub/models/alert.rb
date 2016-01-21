require 'sinatra/activerecord'

module Minicron
  module Hub
    class Alert < ActiveRecord::Base
      belongs_to :job
      belongs_to :schedule
      belongs_to :execution
    end
  end
end
