require 'minicron/alert'

module Minicron
  autoload :Alert,                'minicron/alert'

  module Hub
    autoload :Host,               'minicron/hub/models/host'
    autoload :Job,                'minicron/hub/models/job'
    autoload :Execution,          'minicron/hub/models/execution'
    autoload :JobExecutionOutput, 'minicron/hub/models/job_execution_output'
  end

  module Transport
    # An extension to the Faye server to store some of the data it receives
    #
    # TODO: A lot of this need more validation checks and error handling
    #       currently it's just assumed the correct data is passed and the server
    #       can crash if it isn't
    class FayeJobHandler
      # Called by Faye when a message is received
      #
      # @param message [Hash] The message data
      # @param request the rack request object
      # @param callback
      def incoming(message, request, callback)
        segments = message['channel'].split('/')

        # Is it a job messages
        if segments[1] == 'job'
          data = message['data']['message']

          # Is it a setup message?
          if segments[3] == 'status' && data['action'] == 'SETUP'
            message = handle_setup(request, message, segments)
          end

          # Is it a start message?
          if segments[4] == 'status' && data[0..4] == 'START'
            handle_start(request, message, segments)
          end

          # Is it job output?
          if segments[4] == 'output'
            message = handle_output(request, message, segments)
          end

          # Is it a finish message?
          if segments[4] == 'status' && data[0..5] == 'FINISH'
            handle_finish(request, message, segments)
          end

          # Is it an exit message?
          if segments[4] == 'status' && data[0..3] == 'EXIT'
            handle_exit(request, message, segments)
          end
        end

        # Return the message back to faye
        callback.call(message)
      end

      # Handle SETUP messages
      #
      # @param request the rack request object
      # @param message [Hash] the decoded message sent with the request
      # @param segments [Hash] the message channel split by /
      def handle_setup(request, message, segments)
        data = message['data']['message']

        Minicron::Hub::Host.transaction do
          # Try and find the host
          host = Minicron::Hub::Host.where(:fqdn => data['fqdn']).first

          # Create it if it didn't exist!
          if !host
            host = Minicron::Hub::Host.create(
              :name => data['hostname'],
              :fqdn => data['fqdn'],
              :host => request.ip,
              :port => 22
            )

            # Generate a new SSH key - TODO: add passphrase
            key = Minicron.generate_ssh_key('host', host.id, host.fqdn)

            # And finally we store the public key in te db with the host for convenience
            Minicron::Hub::Host.where(:id => host.id).update_all(
              :public_key => key.ssh_public_key
            )
          end

          # Validate or create the job
          job = Minicron::Hub::Job.where(:job_hash => segments[2]).first_or_create do |j|
            j.job_hash = segments[2]
            j.user = data['user']
            j.command = data['command']
            j.host_id = host.id
          end

          # Get the latest execution number
          latest_execution = Minicron::Hub::Execution.where(:job_id => job.id)
                                                     .order(:id => :desc)
                                                     .limit(1)
                                                     .pluck(:number)

         # If this is the first execution then default it to 1 otherwise increment by 1
         execution_number = latest_execution[0].nil? ? 1 : latest_execution[0] + 1

          # Create an execution for this job
          execution = Minicron::Hub::Execution.create(
            :job_id => job.id,
            :number => execution_number
          )

          # Alter the response channel to include the execution id and
          # number for the client to use
          segments[3] = "#{job.id}-#{execution.id}-#{execution_number}/status"
          message['channel'] = segments.join('/')

          # And finally return the message
          message
        end
      end

      # Handle START messages
      #
      # @param request the rack request object
      # @param message [Hash] the decoded message sent with the request
      # @param segments [Hash] the message channel split by /
      def handle_start(request, message, segments)
        data = message['data']['message']

        # Update the execution and add the start time
        Minicron::Hub::Execution.where(:id => segments[3]).update_all(
          :started_at => data[6..-1]
        )
      end

      # Handle job output
      #
      # @param request the rack request object
      # @param message [Hash] the decoded message sent with the request
      # @param segments [Hash] the message channel split by /
      def handle_output(request, message, segments)
        data = message['data']['message']
        ts = message['data']['ts']
        seq = message['data']['seq']

        # Store the job execution output
        output = Minicron::Hub::JobExecutionOutput.create(
          :execution_id => segments[3],
          :output => data,
          :timestamp => ts,
          :seq => seq
        )

        # Append the id to the message so we can use it on the frontend
        message['data']['job_execution_output_id'] = output.id

        # And finally return the message
        message
      end

      # Handle FINISH messages
      #
      # @param request the rack request object
      # @param message [Hash] the decoded message sent with the request
      # @param segments [Hash] the message channel split by /
      def handle_finish(request, message, segments)
        data = message['data']['message']

        # Update the execution and add the finish time
        Minicron::Hub::Execution.where(:id => segments[3]).update_all(
          :finished_at => data[7..-1]
        )
      end

      # Handle EXIT messages
      #
      # @param request the rack request object
      # @param message [Hash] the decoded message sent with the request
      # @param segments [Hash] the message channel split by /
      def handle_exit(request, message, segments)
        data = message['data']['message']

        # Update the execution and add the exit status
        Minicron::Hub::Execution.where(:id => segments[3]).update_all(
          :exit_status => data[5..-1]
        )

        # If the exit status was above 0 we need to trigger a failure alert
        if data[5..-1].to_i > 0
          alert = Minicron::Alert.new
          alert.send_all(
            :kind => 'fail',
            :execution_id => segments[3],
            :job_id => segments[2]
          )
        end
      end
    end
  end
end
