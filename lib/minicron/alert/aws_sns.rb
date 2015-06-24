require 'aws-sdk-core'

module Minicron
   # Allows the sending of AWS SNS alerts
  class AwsSns
    # Used to set up on the AWS::SNS::Topic
    def initialize
      # Get an instance of the sns client
      @client = Aws::SNS::Client.new({
        :access_key_id =>  Minicron.config['alerts']['aws_sns']['access_key_id'],
        :secret_access_key =>  Minicron.config['alerts']['aws_sns']['secret_access_key'],
        :region => Minicron.config['alerts']['aws_sns']['region']
      })
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
        "minicron alert - job missed!\nJob ##{options[:job_id]} failed to execute at its expected time: #{options[:expected_at]}"
      when 'fail'
        "minicron alert - job failed!\nExecution ##{options[:execution_id]} of Job ##{options[:job_id]} failed"
      else
        fail Exception, "The kind '#{options[:kind]} is not supported!"
      end
    end

    # Send an sns alert
    #
    # @param from [String]
    # @param to [String]
    # @param message [String]
    def send(subject, message)
      @client.publish(
        :topic_arn => Minicron.config['alerts']['aws_sns']['topic_arn'],
        :subject => subject,
        :message => message
      )
    end
  end
end
