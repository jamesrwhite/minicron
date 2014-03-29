require 'minicron/hub/models/alert'
require 'minicron/hub/models/job'
require 'minicron/alert/email'

module Minicron
  class Alert
    # Send an alert using all enabled mediums
    #
    # @param schedule [Minicron::Hub::Schedule] a schedule instance
    # @param expected_at [DateTime] when the schedule was expected to execute
    # @option options [Integer, nil] execution_id only used by 'fail' alerts
    def send_all(schedule, expected_at, options = {})
      Minicron.config['alerts'].each do |medium, value|
        # Set up the options hash for the sent? check
        sent_options = {
          :schedule_id => schedule.id,
          :execution_id => options[:execution_id]
        }

        # Check if the medium is enabled and alert hasn't already been sent
        if value['enabled'] && !sent?('miss', expected_at, medium, sent_options)
          send(
            :schedule => schedule,
            :kind => 'miss',
            :expected_at => expected_at,
            :medium => medium
          )
        end
      end
    end

    # Send an individual alert
    #
    # @option options [Minicron::Hub::Schedule] schedule a schedule instance
    # @option options [Integer,nil] execution_id only applies to 'fail' alerts
    # @option options [String] kind 'fail' or 'miss'
    # @option options [Time] expected_at when the schedule was expected to execute
    # @option options [String] medium the medium to send the alert via
    # @option options [Integer, nil] execution_id only used by 'fail' alerts
    def send(options = {})
      # Look up the job for this schedule
      options[:job] = Minicron::Hub::Job.find(options[:schedule].job_id)

      case options[:medium]
      when 'email'
        email = Minicron::Email.new
        email.send(
          Minicron.config['alerts']['email']['to'],
          Minicron.config['alerts']['email']['from'],
          "minicron alert for job '#{options[:job].name}'!",
          email.get_message(options)
        )
      else
        raise Exception, "The medium '#{medium}' is not supported!"
      end

      # Store that we sent the alert
      Minicron::Hub::Alert.create(
        :schedule_id => options[:schedule].id,
        :execution_id => options[:execution_id],
        :kind => options[:kind],
        :expected_at => options[:expected_at],
        :medium => options[:medium],
        :sent_at => Time.now.utc
      )
    end

    # Queries the database to determine if an alert for the given expected schedule
    # execution and medium has already been marked as sent
    #
    # @param kind [String] 'miss' or 'fail'
    # @param expected_at [Time]
    # @param medium [String]
    # @option options [Integer] schedule_id
    # @option options [Integer, nil] execution_id
    def sent?(kind, expected_at, medium, options = {})
      Minicron::Hub::Alert.exists?(
        :schedule_id => options[:schedule_id],
        :execution_id => options[:execution_id],
        :kind => kind,
        :expected_at => expected_at,
        :medium => medium
      )
    end
  end
end
