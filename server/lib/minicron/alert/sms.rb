require 'twilio-ruby'

module Minicron
  module Alert
    # Allows the sending of SMS alerts via Twilio
    class SMS
      # Used to set up on the twilio client
      def initialize
        # Get an instance of the twilio client
        @client = Twilio::REST::Client.new(
          Minicron.config['alerts']['sms']['twilio']['account_sid'],
          Minicron.config['alerts']['sms']['twilio']['auth_token']
        )
      end

      # Return the message for an alert
      #
      # @option options [Minicron::Hub::Model::Job] job a job instance
      # @option options [String] kind 'fail' or 'miss'
      # @option options [Integer, nil] schedule_id only applies to 'miss' alerts
      # @option options [Integer, nil] execution_id only used by 'fail' alerts
      # @option options [Integer] job_id used to look up the job name for the alert message
      # @option options [Time] expected_at when the schedule was expected to execute
      # @option options [String] medium the medium to send the alert via
      def get_message(options = {})
        case options[:kind]
        when 'miss'
          "minicron alert - job missed!\nJob ##{options[:job_id]} failed to execute at its expected time: #{options[:expected_at]}"
        when 'fail'
          "minicron alert - job failed!\nExecution ##{options[:execution_id]} of Job ##{options[:job_id]} failed"
        else
          raise Minicron::ArgumentError, "The kind '#{options[:kind]} is not supported!"
        end
      end

      # Send an sms alert
      #
      # @param from [String]
      # @param to [String]
      # @param message [String]
      def send(from, to, message)
        @client.account.messages.create(
          from: from,
          to: to,
          body: message
        )
      end
    end
  end
end
