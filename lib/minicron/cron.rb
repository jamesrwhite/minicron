module Minicron
  # Used to interact with the crontab on hosts over an ssh connection
  class Cron
    # Initialise the cron class
    #
    # @param ssh [Minicron::Transport::SSH] instance
    def initialize(ssh)
      @ssh = ssh
    end

    # Escape the quotes in a command
    #
    # @param command [String]
    # @return [String]
    def escape_command(command)
      command.gsub(/\\|'/) { |c| "\\#{c}" }
    end

    # Build the minicron command to be used in the crontab
    #
    # @param command [String]
    # @param schedule [String]
    # @return [String]
    def build_minicron_command(command, schedule)
      # Escape any quotes in the command
      command = escape_command(command)

      "#{schedule} root minicron run '#{command}'"
    end

    # Add the schedule for this job to the crontab
    #
    # @param job [Minicron::Hub::Job] an instance of a job model
    # @param schedule [String] the job schedule as a string
    def add_schedule(job, schedule)
      # Open an SSH connection
      conn = @ssh.open

      # Prepare the line we are going to write to the crontab
      line = build_minicron_command(job.command, schedule)
      echo_line = "echo \"#{line}\" >> /etc/crontab && echo 'y' || echo 'n'"

      # Append it to the end of the crontab
      write = conn.exec!(echo_line).strip

      # Throw an exception if it failed
      if write != 'y'
        raise Exception, "Unable to write #{line} to the crontab"
      end

      # Check the line is there
      tail = conn.exec!('tail -n 1 /etc/crontab').strip

      # Throw an exception if we can't see our new line at the end of the file
      if tail != line
        raise Exception, "Expected to find #{line} at eof but found #{tail}"
      end

      @ssh.close
    end

    # Update the schedule for this job in the crontab
    #
    # @param job [Minicron::Hub::Job] an instance of a job model
    # @param old_schedule [String] the old job schedule as a string
    # @param new_schedule [String] the new job schedule as a string
    def update_schedule(job, old_schedule, new_schedule)
      # Open an SSH connection
      conn = @ssh.open

      # We are looking for the current value of the schedule
      find = build_minicron_command(job.command, old_schedule)

      # And replacing it with the updated value
      replace = build_minicron_command(job.command, new_schedule)

      # Build the parts of the sed command we are going to run
      sed = "sed -e \"s/#{Regexp.escape(find)}/#{Regexp.escape(replace)}/g\""
      sed_redirect = '/etc/crontab > /etc/crontab.tmp'
      test = "&& echo 'y' || echo 'n'"

      # Build the full command
      sed_command = "#{sed} #{sed_redirect} #{test}"

      # Append it to the end of the crontab
      update = conn.exec!(sed_command).strip

      # Throw an exception if it failed
      if update != 'y'
        raise Exception, "Unable to replace #{find} with #{replace} in the crontab"
      end

      # Check the line is there
      tail = conn.exec!('tail -n 1 /etc/crontab.tmp').strip

      # Throw an exception if we can't see our new line at the end of the file
      if tail != replace
        raise Exception, "Expected to find #{replace} at eof but found #{tail}"
      end

      # And finally replace the crontab with the new one now we now the change worked
      conn.exec!('mv /etc/crontab.tmp /etc/crontab')

      @ssh.close
    end

    # Remove the schedule for this job from the crontab
    #
    # @param job [Minicron::Hub::Job] an instance of a job model
    # @param schedule [String] the job schedule as a string
    def delete_schedule(job, schedule)
      # Open an SSH connection
      conn = @ssh.open

      # We are looking for the current value of the schedule
      find = build_minicron_command(job.command, schedule)

      # Build the parts of the sed command we are going to run
      sed = "sed -e \"s/#{Regexp.escape(find)}//g\""
      sed_redirect = '/etc/crontab > /etc/crontab.tmp'
      test = "&& echo 'y' || echo 'n'"

      # Build the full command
      sed_command = "#{sed} #{sed_redirect} #{test}"

      # Append it to the end of the crontab
      update = conn.exec!(sed_command).strip

      # Throw an exception if it failed
      if update != 'y'
        raise Exception, "Unable to remove #{find} from the crontab"
      end

      # Check the line is there
      grep = conn.exec!("grep \"#{find}\" /etc/crontab.tmp")

      # Throw an exception if we can't see our new line at the end of the file
      if grep
        raise Exception, "Expected to find nothing when grepping for '#{find}' but found #{grep}"
      end

      # And finally replace the crontab with the new one now we now the change worked
      conn.exec!('mv /etc/crontab.tmp /etc/crontab')

      @ssh.close
    end
  end
end
