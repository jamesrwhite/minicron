autoload :ActiveRecord, 'active_record'

module Minicron
  module Hub
    class Schedule < ActiveRecord::Base
      belongs_to :job
      has_many :alerts, :dependent => :destroy

      # The formatted schedule
      def formatted
        Minicron::Hub::Schedule.format(self)
      end

      # Format the schedule based on all it's components
      #
      # @param schedule [Minicron::Hub::Schedule]
      # @return string
      def self.format(schedule)
        # If it's not a 'special' schedule then build up the full schedule string
        if schedule.special == '' || schedule.special.nil?
          "#{schedule.minute} #{schedule.hour} #{schedule.day_of_the_month} #{schedule.month} #{schedule.day_of_the_week}"
        else
          schedule.special
        end
      end
    end
  end
end
