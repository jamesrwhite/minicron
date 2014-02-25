require 'minicron/hub/models/execution'
require 'minicron/hub/models/job_execution_output'

module Minicron
  module Transport
    class FayeJobHandler
      def incoming(message, callback)
        segments = message['channel'].split('/')

        # Is it a job messages
        if segments[1] == 'job'
          # TODO: All of these need more validation checks and error handling

          # Is it a setup message?
          if segments[3] == 'status' && message['data']['message'] == 'SETUP'
            # Check that the job id is a valid length
            if segments[2].length == 40
              # Create an execution for this job
              execution = Execution.create(
                :job_id => segments[2],
              )

              # Alter the response channel to include the execution id for the
              # client to use in later requests
              segments[3] = "#{execution.execution_id}/status"
              message['channel'] = segments.join('/')
            end
          end

          # Is it a start message?
          if segments[4] == 'status' && message['data']['message'][0..4] == 'START'
            # Check that the job id is a valid length
            if segments[2].length == 40
              Execution.where(:execution_id => segments[3]).update_all(
                'started_at' => message['data']['message'][6..-1]
              )
            end
          end

          # Is it job output?
          if segments[4] == 'output'
            JobExecutionOutput.create(
              :job_id => segments[2],
              :execution_id => segments[3],
              :output => message['data']['message'],
              :timestamp => message['data']['ts']
            )
          end

          # Is it a finish message?
          if segments[4] == 'status' && message['data']['message'][0..5] == 'FINISH'
            # Check that the job id is a valid length
            if segments[2].length == 40
              Execution.where(:execution_id => segments[3]).update_all(
                'finished_at' => message['data']['message'][9..-1],
                'exit_status' => message['data']['message'][7..7]
              )
            end
          end
        end

        callback.call(message)
      end
    end
  end
end
