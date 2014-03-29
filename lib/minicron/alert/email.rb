require 'mail'

module Minicron
  class Email
    # Return the message for an alert
    #
    # @option options [Minicron::Hub::Job] job a job instance
    # @option options [String] kind 'fail' or 'miss'
    # @option options [Integer, nil] schedule_id only applies to 'miss' alerts
    # @option options [Integer, nil] execution_id only used by 'fail' alerts
    # @option options [Integer] job_id used to look up the job name for the alert message
    # @option options [Time] expected_at when the schedule was expected to execute
    # @option options [String] medium the medium to send the alert via
    def get_message(options = {})
      case options[:kind]
      when 'miss'
        "The job '#{options[:job].name}'' failed to execute at it's expected time of #{options[:expected_at]}"
      when 'fail'
        "Execution ##{options[:execution_id]} of the job '#{options[:job].name}' failed."
      else
        raise Exception, "The kind '#{options[:kind]} is not supported!"
      end
    end

    # Send an email alert
    #
    # @param to [String]
    # @param from [String]
    # @param subject [String]
    # @param message [String]
    def send(to, from, subject, message)
      # Set up the email
      mail = Mail.new do
        to       to
        from     from
        subject  subject
        body     message
      end

      mail.deliver!
    end
  end
end
