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
          job = alert.execution.job
          new_alert[:job] = alert.execution.job.id
        end

        # Is it an schedule alert?
        if !alert.schedule.nil?
          @response[:schedules].push(alert.schedule)
          job = alert.schedule.job
          new_alert[:job] = alert.schedule.job.id
        end

        # Patch the jobs host_id attrs
        job = job.serializable_hash
        job['host'] = job['host_id']
        job.delete('host_id')
        @response[:jobs].push(job)

        # Append the new alert to the @responseh
        @response[:alerts].push(new_alert)
      end
    end
  end
end
