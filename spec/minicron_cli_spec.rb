require 'spec_helper'

describe Minicron::CLI do
  describe '#run' do
    it 'should run a simple command and print the output to stdout' do
      Minicron::CLI.new.run ['run', 'echo hello', '--trace'], :trace => true do |output|
        output.clean == 'hello'
      end
    end

    it 'should run a simple multi-line command and print the output to stdout' do
      Minicron::CLI.new.run ['run', 'ls -l', '--trace'], :trace => true do |output|
        output.clean == `ls -l`.clean
      end
    end

    it 'should return an error when a non-existent command is run' do
      Minicron.capture_output :type => :stderr do
        expect {
          Minicron::CLI.new.run ['lol'], :trace => true
        }.to raise_error SystemExit
      end
    end

    it 'should raise SystemExit when tracing is disabled but passed as an option' do
      Minicron.capture_output :type => :stderr do
        expect {
          Minicron::CLI.new.run ['run', 'echo 1', '--trace']
        }.to raise_error SystemExit
      end
    end

    it 'should raise ArgumentError when no argument is passed to the run action' do
      Minicron.capture_output :type => :stderr do
        expect {
          Minicron::CLI.new.run ['run', '--trace'], :trace => true
        }.to raise_error ArgumentError
      end
    end
  end

  describe '#coloured_output?' do
    it 'should return true when rainbow is enabled' do
      Rainbow.enabled = true

      Minicron::CLI.new.coloured_output?.should eq true
    end

    it 'should return false when rainbow is disabled' do
      Rainbow.enabled = false

      Minicron::CLI.new.coloured_output?.should eq false
    end
  end

  describe '#enable_coloured_output' do
    it 'should set Rainbow.enabled to true' do
      minicron = Minicron::CLI.new
      minicron.enable_coloured_output

      Rainbow.enabled.should eq true
      minicron.coloured_output?.should eq true
    end
  end

  describe '#disable_coloured_output' do
    it 'should set Rainbow.enabled to false' do
      minicron = Minicron::CLI.new
      minicron.disable_coloured_output

      Rainbow.enabled.should eq false
      minicron.coloured_output?.should eq false
    end
  end
end
