module Minicron
  module Hub
    class AlertSerializer
      def initialize(alerts)
        @alerts = alerts
      end

      def serialize
        @response = {
          :alerts => [],
          :jobs => [],
          :executions => [],
          :schedules => []
        }

        if @alerts.respond_to? :each
          @alerts.each do |alert|
            do_serialization(alert)
          end
        else
          do_serialization(@alerts)
        end

        @response
      end

      def do_serialization(alert)
        new_alert = {}

        # Add all the normal attributes of the alert
        alert.attributes.each do |key, value|
          # To make our name method in the model work :/
          value = alert.name if key == 'name'

          # Remove _id from keys
          key = key[-3, 3] == '_id' ? key[0..-4] : key

          new_alert[key] = value
        end

        # Is it an execution alert?
        if !alert.execution.nil?
          @response[:executions].push(alert.execution)
          @response[:jobs].push(alert.execution.job)
          new_alert[:job] = alert.execution.job.id
        end

        # Is it an schedule alert?
        if !alert.schedule.nil?
          @response[:schedules].push(alert.schedule)
          @response[:jobs].push(alert.schedule.job)
          new_alert[:job] = alert.schedule.job.id
        end

        # Append the new alert to the @responseh
        @response[:alerts].push(new_alert)
      end
    end
  end
end
