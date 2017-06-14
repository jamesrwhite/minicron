require Minicron::REQUIRE_PATH + 'hub/models/base'

module Minicron::Hub
  module Model
    class Job < Minicron::Hub::Model::Base
      has_many :executions, dependent: :destroy
      has_many :schedules, dependent: :destroy
      has_many :alerts, dependent: :destroy

      validates :name,    presence: true
      validates :command, presence: true
      validates :enabled, inclusion: { in: [true, false] }

      # Default the name of the command to the command itself if no name is set
      def name
        if read_attribute(:name) == '' || read_attribute(:name).nil?
          read_attribute(:command)
        else
          read_attribute(:name)
        end
      end

      def safe_name
        CGI.escapeHTML(name)
      end

      def status
        read_attribute(:enabled) == true ? 'enabled' : 'disabled'
      end
    end
  end
end
