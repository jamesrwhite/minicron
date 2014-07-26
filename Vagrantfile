# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Provisioning commands
$script = <<SCRIPT
apt-get install -y python-software-properties
apt-add-repository ppa:brightbox/ruby-ng
apt-get update
apt-get install -y ruby rubygems ruby-switch
apt-get install -y ruby1.9.3
apt-get install -y libsqlite3-dev ruby-dev build-essential
bash --login
ruby-switch --set ruby1.9.1
gem install --no-ri --no-rdoc minicron
minicron db setup
minicron server start
ufw allow 2222
ufw allow 9292
ufw enable
echo "minicron is running on http://localhost:9292!"
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "base"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 9292, host: 9292

  # Provision the VM using the inline script at the top of this file
  config.vm.provision "shell", inline: $script
end
