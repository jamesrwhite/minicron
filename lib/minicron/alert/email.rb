require 'mail'

module Minicron
  class Email
    # Configure the mail client
    def initialize
      Mail.defaults do
        delivery_method(
          :smtp,
          :address => Minicron.config['alerts']['email']['smtp']['address'],
          :port => Minicron.config['alerts']['email']['smtp']['port']
        )
      end
    end
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
        "Job ##{options[:job_id]} (#{options[:job].name}) failed to execute at its expected time: #{options[:expected_at]}."
      when 'fail'
        "Execution ##{options[:execution_id]} of Job ##{options[:job_id]} (#{options[:job].name}) failed."
      else
        raise Exception, "The kind '#{options[:kind]} is not supported!"
      end
    end

    # Send an email alert
    #
    # @param from [String]
    # @param to [String]
    # @param subject [String]
    # @param message [String]
    def send(from, to, subject, message)
      Mail.deliver do
        to       to
        from     from
        subject  subject
        body     message
      end
    end
  end
end
