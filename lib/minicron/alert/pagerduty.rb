require 'pagerduty'

module Minicron
  # Allows the sending of pagerduty alerts
  class PagerDuty
    # Used to set up on the pagerduty client
    def initialize
      # Get an instance of the Pagerduty client
      @client = ::Pagerduty.new(Minicron.config['alerts']['pagerduty']['service_key'])
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
        "Job ##{options[:job_id]} failed to execute at its expected time - #{options[:expected_at]}"
      when 'fail'
        "Execution ##{options[:execution_id]} of Job ##{options[:job_id]} failed"
      else
        fail Exception, "The kind '#{options[:kind]} is not supported!"
      end
    end

    # Send a pager duty alert
    #
    # @param title [String]
    # @param message [String]
    def send(title, message)
      @client.trigger(title, { :message => message })
    end
  end
end
