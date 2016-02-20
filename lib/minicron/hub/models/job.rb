require 'active_record'

module Minicron
  module Hub
    class Job < ActiveRecord::Base
      belongs_to :host
      has_many :executions, :dependent => :destroy
      has_many :schedules, :dependent => :destroy

      validates :name,    :presence => true, :uniqueness => true
      validates :user,    :presence => true
      validates :command, :presence => true
      validates :host,    :presence => true
      validates :enabled, :inclusion => { :in => [true, false] }

      # Default the name of the command to the command itself if no name is set
      def name
        if read_attribute(:name) == '' || read_attribute(:name).nil?
          read_attribute(:command)
        else
          read_attribute(:name)
        end
      end

      def status
        read_attribute(:enabled) == true ? 'enabled' : 'disabled'
      end
    end
  end
end
