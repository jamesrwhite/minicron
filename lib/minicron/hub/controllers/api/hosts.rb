require 'minicron/transport/ssh'

class Minicron::Hub::App
  # Used to test an SSH connection for a host
  get '/api/hosts/:id/test_ssh' do
    begin
      # Get the host
      host = Minicron::Hub::Host.find(params[:id])

      # Set up the ssh instance
      ssh = Minicron::Transport::SSH.new(
        :user => host.user,
        :host => host.host,
        :port => host.port,
        :private_key => "~/.ssh/minicron_host_#{host.id}_rsa"
      )

      # Get an instance of the cron class
      cron = Minicron::Cron.new(ssh)

      # Test the SSH connection
      test = cron.test_host_permissions

      # Tidy up
      ssh.close

      # Return the test results as JSON
      test.to_json
    rescue Exception => e
      status 422
      { :connect => false, :error => e.message }.to_json
    end
  end
end
