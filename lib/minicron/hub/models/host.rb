require 'active_record'

module Minicron
  module Hub
    class Host < ActiveRecord::Base
      has_many :jobs, dependent: :destroy

      validates :name, presence: true
      validates :fqdn, presence: true, uniqueness: true
      validates :user, presence: true
      validates :host, presence: true
      validates :port, presence: true, numericality: { only_integer: true }

      # Default the name of the host to the fqdn itself if no name is set
      def name
        if read_attribute(:name) == '' || read_attribute(:name).nil?
          read_attribute(:fqdn)
        else
          read_attribute(:name)
        end
      end
    end
  end
end
