require 'minicron/hub/models/alert'
require 'minicron/hub/models/job'
require 'minicron/alert/email'

module Minicron
  class Alert
    # Send an alert
    #
    # @option options [Minicron::Hub::Schedule] schedule a schedule instance
    # @option options [Integer,nil] execution_id only applies to 'fail' alerts
    # @option options [String] kind 'fail' or 'miss'
    # @option options [Time] expected_at when the schedule was expected to execute
    # @option options [String] medium the medium to send the alert via
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
    # @param schedule_id [Integer]
    # @param expected_at [Time]
    # @param medium [String]
    def sent?(kind, schedule_id, expected_at, medium)
      Minicron::Hub::Alert.exists?(
        :schedule_id => schedule_id,
        :kind => kind,
        :expected_at => expected_at,
        :medium => medium
      )
    end
  end
end
