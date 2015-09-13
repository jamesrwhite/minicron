autoload :ActiveRecord, 'sinatra/activerecord'

module Minicron
  module Hub
    class Job < ActiveRecord::Base
      belongs_to :host
      has_many :executions, :dependent => :destroy
      has_many :schedules, :dependent => :destroy

      # Default the name of the command to the command itself if no name is set
      def name
        if read_attribute(:name) == '' || read_attribute(:name).nil?
          read_attribute(:command)
        else
          read_attribute(:name)
        end
      end
    end
  end
end
