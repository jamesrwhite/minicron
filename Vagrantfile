# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'.freeze

# Provisioning commands
$script = <<SCRIPT
apt-get update
apt-get install -y libsqlite3-dev wget unzip curl
ufw allow 2222
ufw allow 9292
ufw enable
bash -c "$(curl -sSL https://raw.githubusercontent.com/jamesrwhite/minicron/master/install.sh)"
minicron db setup
minicron server start
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = 'hashicorp/precise64'

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network 'forwarded_port', guest: 9292, host: 9292

  # Provision the VM using the inline script at the top of this file
  config.vm.provision 'shell', inline: $script
end
