require 'spec_helper'

describe Minicron do
  describe '.capture_output' do
    it 'should return a StringIO instance when :stdout is passed as an option' do
      output = Minicron.capture_output :type => :stdout do
        $stdout.write 'I like turtles!'
      end

      output.should be_an_instance_of StringIO
    end

    it 'should return a StringIO instance when :stderr is passed as an option' do
      output = Minicron.capture_output :type => :stderr do
        $stderr.write 'Quit yo jibber jabber, fool!'
      end

      output.should be_an_instance_of StringIO
    end

    it 'should return a Hash when :both is passed as an option' do
      output = Minicron.capture_output :type => :both do
        $stdout.write 'I like turtles!'
        $stderr.write 'Quit yo jibber jabber, fool!'
      end

      output.should be_an_instance_of Hash
    end

    it 'should return a Hash containing :stdout and :stderr with two StringIO instances when :both is passed as an option' do
      output = Minicron.capture_output :type => :both do
        $stdout.write 'I like turtles!'
        $stderr.write 'Quit yo jibber jabber, fool!'
      end

      output.should have_key :stdout
      output.should have_key :stderr
      output[:stdout].should be_an_instance_of StringIO
      output[:stderr].should be_an_instance_of StringIO
    end

    it 'should raise an ArgumentError when an invalid :type is used' do
      expect {
        Minicron.capture_output :type => :lol do
          $stdout.write 'I like turtles!'
          $stderr.write 'Quit yo jibber jabber, fool!'
        end
      }.to raise_error ArgumentError
    end
  end
end
