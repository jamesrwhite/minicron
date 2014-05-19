module Minicron
  autoload :Email,      'minicron/alert/email'
  autoload :SMS,        'minicron/alert/sms'
  autoload :PagerDuty,  'minicron/alert/pagerduty'

  module Hub
    autoload :Alert,    'minicron/hub/models/alert'
    autoload :Job,      'minicron/hub/models/job'
  end

  # Allows the sending of alerts via multiple mediums
  class Alert
    # Send an alert using all enabled mediums
    #
    # @option options [String] kind 'fail' or 'miss'
    # @option options [Integer] job_id used by the #send method
    # @option options [Integer, nil] execution_id only used by 'fail' alerts
    # @option options [Integer, nil] schedule_id only applies to 'miss' alerts
    # @option options [Time] expected_at only applies to 'miss' alerts
    def send_all(options = {})
      Minicron.config['alerts'].each do |medium, value|
        # Check if the medium is enabled and alert hasn't already been sent
        if value['enabled'] && !sent?(options)
          send(
            :kind => options[:kind],
            :schedule_id => options[:schedule_id],
            :execution_id => options[:execution_id],
            :job_id => options[:job_id],
            :expected_at => options[:expected_at],
            :medium => medium
          )
        end
      end
    end

    # Send an individual alert
    #
    # @option options [String] kind 'fail' or 'miss'
    # @option options [Integer] job_id used to look up the job name for the alert message
    # @option options [Integer, nil] execution_id only used by 'fail' alerts
    # @option options [Integer, nil] schedule_id only applies to 'miss' alerts
    # @option options [Time] expected_at when the schedule was expected to execute
    # @option options [String] medium the medium to send the alert via
    def send(options = {})
      # Look up the job for this schedule
      options[:job] = Minicron::Hub::Job.find(options[:job_id])

      # Switch the medium that the alert will be sent via
      case options[:medium]
      when 'email'
        send_email(options)
      when 'sms'
        send_sms(options)
      when 'pagerduty'
        send_pagerduty(options)
      else
        fail Exception, "The medium '#{options[:medium]}' is not supported!"
      end

      # Store that we sent the alert
      Minicron::Hub::Alert.create(
        :job_id => options[:job_id],
        :execution_id => options[:execution_id],
        :schedule_id => options[:schedule_id],
        :kind => options[:kind],
        :expected_at => options[:expected_at],
        :medium => options[:medium],
        :sent_at => Time.now.utc
      )
    end

    # Send an email alert, this has the same options as #send
    def send_email(options = {})
      email = Minicron::Email.new
      email.send(
        Minicron.config['alerts']['email']['from'],
        Minicron.config['alerts']['email']['to'],
        "minicron alert for job '#{options[:job].name}'!",
        email.get_message(options)
      )
    end

    # Send an sms alert, this has the same options as #send
    def send_sms(options = {})
      sms = Minicron::SMS.new
      sms.send(
        Minicron.config['alerts']['sms']['from'],
        Minicron.config['alerts']['sms']['to'],
        sms.get_message(options)
      )
    end

    # Send a pagerduty alert, this has the same options as #send
    def send_pagerduty(options = {})
      pagerduty = Minicron::PagerDuty.new
      pagerduty.send(
        options[:kind] == 'fail' ? 'Job failed!' : 'Job missed!',
        pagerduty.get_message(options)
      )
    end

    # Queries the database to determine if an alert for this kind has already
    # been sent
    #
    # @option options [String] kind 'fail' or 'miss'
    # @option options [Integer, nil] execution_id only used by 'fail' alerts
    # @option options [Integer, nil] schedule_id only applies to 'miss' alerts
    # @option options [Time] expected_at when the schedule was expected to execute
    # @option options [String] medium the medium to send the alert via
    def sent?(options = {})
      Minicron::Hub::Alert.exists?(
        :kind => options[:kind],
        :execution_id => options[:execution_id],
        :schedule_id => options[:schedule_id],
        :job_id => options[:job_id],
        :expected_at => options[:expected_at],
        :medium => options[:medium]
      )
    end
  end
end
