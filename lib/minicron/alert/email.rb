require 'mail'

module Minicron
  class Email
    # Return the message for an alert
    #
    # @option options [Minicron::Hub::Schedule] schedule a schedule instance
    # @option options [Minicron::Hub::Job] job a job instance
    # @option options [Integer,nil] execution_id only applies to 'fail' alerts
    # @option options [String] kind 'fail' or 'miss'
    # @option options [Time] expected_at when the schedule was expected to execute
    # @option options [String] medium the medium to send the alert via
    def get_message(options = {})
      # TODO: switch output based on kind of alert
      "The job '#{options[:job].name}'' failed to execute at it's expected time of #{options[:expected_at]}"
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
