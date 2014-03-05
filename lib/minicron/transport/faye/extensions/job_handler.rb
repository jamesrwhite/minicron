require 'minicron/hub/models/host'
require 'minicron/hub/models/job'
require 'minicron/hub/models/execution'
require 'minicron/hub/models/job_execution_output'

module Minicron
  module Transport
    # An extension to the Faye server to store some of the data it receives
    class FayeJobHandler
      # Called by Faye when a message is recieved
      #
      # @param message [Hash] The message data
      # @param callback
      def incoming(message, callback)
        segments = message['channel'].split('/')
        data = message['data']['message']
        ts = message['data']['ts']

        # Is it a job messages
        if segments[1] == 'job'
          # TODO: All of these need more validation checks and error handling
          # currently it's just assumed the correct data is passed

          # Check that the job id is a valid length
          if segments[2].length != 40
            # Do something clever here
          end

          # Is it a setup message?
          if segments[3] == 'status' && data['action'] == 'SETUP'
            # Validate or create the host
            host = Minicron::Hub::Host.where(:hostname => data['host']).first_or_create do |h|
              h.hostname = data['host']
            end

            # Validate or create the job
            Minicron::Hub::Job.where(:id => segments[2]).first_or_create do |job|
              job.command = data['command']
              job.host_id = host.id
            end

            # Create an execution for this job
            execution = Minicron::Hub::Execution.create(
              :job_id => segments[2],
              :created_at => ts
            )

            # Alter the response channel to include the execution id for the
            # client to use in later requests
            segments[3] = "#{execution.id}/status"
            message['channel'] = segments.join('/')
          end

          # Is it a start message?
          if segments[4] == 'status' && data[0..4] == 'START'
            Minicron::Hub::Execution.where(:id => segments[3]).update_all(
              'started_at' => data[6..-1]
            )
          end

          # Is it job output?
          if segments[4] == 'output'
            Minicron::Hub::JobExecutionOutput.create(
              :job_id => segments[2],
              :execution_id => segments[3],
              :output => data,
              :timestamp => ts
            )
          end

          # Is it a finish message?
          if segments[4] == 'status' && data[0..5] == 'FINISH'
            Minicron::Hub::Execution.where(:id => segments[3]).update_all(
              'finished_at' => data[7..-1]
            )
          end

          # Is it an exit message?
          if segments[4] == 'status' && data[0..3] == 'EXIT'
            Minicron::Hub::Execution.where(:id => segments[3]).update_all(
              'exit_status' => data[5..-1]
            )
          end
        end

        callback.call(message)
      end
    end
  end
end
