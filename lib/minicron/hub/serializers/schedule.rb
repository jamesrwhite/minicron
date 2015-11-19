module Minicron
  module Hub
    class ScheduleSerializer
      def initialize(schedules)
        @schedules = schedules
      end

      def serialize
        @response = {
          :schedules => [],
          :jobs => []
        }

        if @schedules.respond_to? :each
          @schedules.each do |schedule|
            do_serialization(schedule)
          end
        else
          do_serialization(@schedules)
        end

        @response
      end

      def do_serialization(schedule)
        new_schedule = {}

        # Add all the normal attributes of the schedule
        schedule.attributes.each do |key, value|
           # Remove _id from keys
          key = key[-3, 3] == '_id' ? key[0..-4] : key

          new_schedule[key] = value
        end

        # Add the formatted version of the schedule
        new_schedule['formatted'] = schedule.formatted

        # Add the schedule job to the sideloaded data
        new_job = {
          :schedules => [],
          :executions => []
        }
        schedule.job.attributes.each do |key, value|
          # To make our name method in the model work :/
          value = schedule.job.name if key == 'name'

          # Remove _id from keys
          key = key[-3, 3] == '_id' ? key[0..-4] : key

          new_job[key] = value
        end

        # Add the ids of each job schedule to the job
        schedule.job.schedules.each do |s|
          new_job[:schedules].push(s.id)
        end

        # Add the ids of each job execution to the job
        schedule.job.executions.each do |execution|
          new_job[:executions].push(execution.id)
        end

        # Append the new job to the @response
        @response[:jobs].push(new_job)

        # Append the new schedule to the @responseh
        @response[:schedules].push(new_schedule)
      end
    end
  end
end
