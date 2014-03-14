require 'sshkey'
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
      def incoming(message, request, callback)
        segments = message['channel'].split('/')

        # Is it a job messages
        if segments[1] == 'job'
          # TODO: All of these need more validation checks and error handling
          # currently it's just assumed the correct data is passed and the server
          # crashes if it isn't!
          data = message['data']['message']
          ts = message['data']['ts']

          # Check that the job id is a valid length
          if segments[2].length != 32
            # TODO: Do something clever here
          end

          # Is it a setup message?
          if segments[3] == 'status' && data['action'] == 'SETUP'
            # Validate or create the host
            host = Minicron::Hub::Host.where(:fqdn => data['fqdn']).first_or_create do |h|
              # Generate a new SSH key - TODO: add passphrase
              key = SSHKey.generate(:comment => "minicron public key for #{data['fqdn']}")

              # Set the locations to save the public key private key pair
              safe_fqdn = Minicron.sanitize_filename(data['fqdn'])
              private_key_path = File.expand_path("~/.ssh/minicron_#{safe_fqdn}_rsa")
              public_key_path = File.expand_path("~/.ssh/minicron_#{safe_fqdn}_rsa.pub")

              # Save the public key private key pair
              File.write(private_key_path, key.private_key)
              File.write(public_key_path, key.ssh_public_key)

              # Set the correct permissions on the files
              File.chmod(0600, private_key_path)
              File.chmod(0644, public_key_path)

              # Set the attributes on the host
              h.name = data['hostname']
              h.fqdn = data['fqdn']
              h.ip = request.ip
              h.public_key = key.ssh_public_key
            end

            # Do we need to update the ip address?
            if host.ip != request.ip
              Minicron::Hub::Host.where(:id => host.id).update_all(
                h.ip = request.ip
              )
            end

            # Validate or create the job
            job = Minicron::Hub::Job.where(:job_hash => segments[2]).first_or_create do |j|
              j.job_hash = segments[2]
              j.command = data['command']
              j.host_id = host.id
            end

            # Create an execution for this job
            execution = Minicron::Hub::Execution.create(
              :job_id => job.id
            )

            # Alter the response channel to include the execution id for the
            # client to use in later requests
            segments[3] = "#{execution.id}/status"
            message['channel'] = segments.join('/')
          end

          # Is it a start message?
          if segments[4] == 'status' && data[0..4] == 'START'
            Minicron::Hub::Execution.where(:id => segments[3]).update_all(
              :started_at => data[6..-1]
            )
          end

          # Is it job output?
          if segments[4] == 'output'
            Minicron::Hub::JobExecutionOutput.create(
              :execution_id => segments[3],
              :output => data,
              :timestamp => ts
            )
          end

          # Is it a finish message?
          if segments[4] == 'status' && data[0..5] == 'FINISH'
            Minicron::Hub::Execution.where(:id => segments[3]).update_all(
              :finished_at => data[7..-1]
            )
          end

          # Is it an exit message?
          if segments[4] == 'status' && data[0..3] == 'EXIT'
            Minicron::Hub::Execution.where(:id => segments[3]).update_all(
              :exit_status => data[5..-1]
            )
          end
        end

        callback.call(message)
      end
    end
  end
end
