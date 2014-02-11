require 'spec_helper'

describe Minicron::CLI do
  it 'should run a simple command and print the output to stdout' do
    Minicron::CLI.new.run argv: ['run', 'echo hello', '--trace'], trace: true do |output|
      output.clean == 'hello'
    end
  end

  it 'should run a simple multi-line command and print the output to stdout' do
    Minicron::CLI.new.run argv: ['run', 'ls -l', '--trace'], trace: true do |output|
      output.clean == `ls -l`.clean
    end
  end

  it 'should return an error when a non-existent command is run' do
    capture_stderr do
      expect {
        Minicron::CLI.new.run argv: ['lol'], trace: true
      }.to raise_error(SystemExit)
    end
  end

  it 'should return an error when tracing is disabled but passed as an option' do
    capture_stderr do
      expect {
        Minicron::CLI.new.run argv: ['run', 'echo 1', '--trace']
      }.to raise_error(SystemExit)
    end
  end
end
