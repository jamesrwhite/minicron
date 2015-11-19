require 'spec_helper'

describe Minicron do
  describe '.capture_output' do
    context 'when :stdout is passed as an option' do
      it 'should return a StringIO instance' do
        output = Minicron.capture_output(:type => :stdout) do
          $stdout.write 'I like turtles!'
        end

        expect(output).to be_an_instance_of StringIO
      end
    end

    context 'when :stderr is passed as an option' do
      it 'should return a StringIO instance' do
        output = Minicron.capture_output(:type => :stderr) do
          $stderr.write 'Quit yo jibber jabber, fool!'
        end

        expect(output).to be_an_instance_of StringIO
      end
    end

    context 'when :both is passed as an option' do
      it 'should return a Hash' do
        output = Minicron.capture_output(:type => :both) do
          $stdout.write 'I like turtles!'
          $stderr.write 'Quit yo jibber jabber, fool!'
        end

        expect(output).to be_an_instance_of Hash
      end
    end

    context 'when :both is passed as an option' do
      it 'should return a Hash containing :stdout and :stderr with two StringIO instances' do
        output = Minicron.capture_output(:type => :both) do
          $stdout.write 'I like turtles!'
          $stderr.write 'Quit yo jibber jabber, fool!'
        end

        expect(output).to have_key :stdout
        expect(output).to have_key :stderr
        expect(output[:stdout]).to be_an_instance_of StringIO
        expect(output[:stderr]).to be_an_instance_of StringIO
      end
    end

    context 'when an invalid :type is used' do
      it 'should raise an ArgumentError' do
        expect do
          Minicron.capture_output(:type => :lol) do
            $stdout.write 'I like turtles!'
            $stderr.write 'Quit yo jibber jabber, fool!'
          end
        end.to raise_error ArgumentError
      end
    end
  end

  describe '.parse_file_config' do
    context 'when a valid toml file is passed' do
      it 'should update the config class variable with the toml file config' do
        expected_valid_config = {
<<<<<<< HEAD
          'verbose' => true,
          'trace' => false,
=======
          'verbose' => false,
          'debug' => false,
>>>>>>> upstream/master
          'client' => {
            'scheme' => 'http',
            'host' => '127.0.0.1',
            'port' => 9292,
            'path' => '/',
            'connect_timeout' => 5,
            'inactivity_timeout' => 5
          },
          'server' => {
            'host' => '127.0.0.1',
            'port' => 9292,
            'path' => '/',
            'debug' => false,
            'pid_file' => '/tmp/minicron.pid',
            'cron_file' => '/etc/crontab'
          },
          'database' => {
            'type' => 'sqlite'
          },
          'cli' => {
            'mode' => 'line',
            'dry_run' => false
          },
          'alerts' => {
            'email' => {
              'enabled' => false,
              'smtp' => {
                'address' => 'localhost',
                'port' => 25
              }
            },
            'sms' => {
              'enabled' => false
            },
            'pagerduty' => {
              'enabled' => false
            },
            'aws_sns' => {
              'enabled' => false
            }
          }
        }

        parse_file_config = Minicron.parse_file_config('./spec/valid_config.toml')
        expect(parse_file_config).to eq expected_valid_config
        expect(Minicron.config).to eq expected_valid_config
      end
    end

    context 'when an invalid toml file is passed' do
      it 'should update the config class variable with the toml file config' do
        expect do
          Minicron.parse_file_config('./spec/invalid_config.toml')
        end.to raise_error Exception
      end
    end

    context 'when a non existent toml file is passed' do
      it 'should raise an Exception' do
        expect do
          Minicron.parse_file_config('./nowhere/minicron.toml')
        end.to raise_error Exception
      end
    end

    context 'when a file without read permissions is passed' do
      before (:each) do
        File.write('/tmp/minicron_toml_test', 'hey')
        File.chmod(0200, '/tmp/minicron_toml_test')
      end

      it 'should raise an Exception' do
        expect do
          Minicron.parse_file_config('/tmp/minicron_toml_test')
        end.to raise_error Exception
      end

      after (:each) do
        File.delete('/tmp/minicron_toml_test')
      end
    end
  end

  describe '.generate_ssh_key' do
    it 'should generate an ssh key pub/priv pair' do
      Minicron.generate_ssh_key('rspec', 1337, 'rspec')

      expect(File.exists?(File.expand_path('~/.ssh/minicron_rspec_1337_rsa'))).to eq true
      expect(File.exists?(File.expand_path('~/.ssh/minicron_rspec_1337_rsa.pub'))).to eq true
    end

    after (:each) do
      `rm ~/.ssh/minicron_rspec_1337_rsa*`
    end
  end

  describe '.get_fqdn' do
    it 'should return the fqdn as a string with no newline' do
      expect(Minicron.get_fqdn).to eq `hostname -f`.strip
    end
  end

  describe '.get_hostname' do
    it 'should return the hostname as a string with no newline' do
      expect(Minicron.get_hostname).to eq `hostname -s`.strip
    end
  end

  describe '.get_user' do
    it 'should return the user as a string with no newline' do
      expect(Minicron.get_user).to eq `whoami`.strip
    end
  end
end
