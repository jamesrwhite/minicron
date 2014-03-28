require 'mail'

module Minicron
  class Email
    # Send an email alert
    #
    # @param to [String]
    # @param from [String]
    # @param subject [String]
    # @param message [String]
    def send(to, from, subject, message)
      # Set up the email
      mail = Mail.new do
        to       to
        from     from
        subject  subject
        body     message
      end

      mail.deliver!
    end
  end
end
