require 'minicron/alert/email'

module Minicron
  class Alert
    # Send an alert!
    #
    # @param medium [String] the medium to send the alert via
    # @param message [String] the message the alert should contain
    # @option options [String] title the title of the message, not applicable
    # to all mediums
    def send(medium, message, options = {})
      case medium
      when 'email'
        email = Minicron::Email.new
        email.send(
          Minicron.config['alerts']['email']['to'],
          Minicron.config['alerts']['email']['from'],
          'minicron alert!',
          message
        )
      else
        raise Exception, "The medium '#{medium}' is not supported!"
      end
    end
  end
end
