require Minicron::REQUIRE_PATH + 'hub/models/base'

module Minicron::Hub
  module Model
    class Host < Minicron::Hub::Model::Base
      has_many :executions, dependent: :destroy

      validates :hostname, presence: true

      # Default the name to the hostname if no name is set
      def name
        if read_attribute(:name) == '' || read_attribute(:name).nil?
          read_attribute(:hostname)
        else
          read_attribute(:name)
        end
      end
    end
  end
end
