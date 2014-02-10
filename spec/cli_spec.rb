require 'spec_helper'

describe Minicron::CLI do
  it 'should run a simple command and print the output to stdout' do
    Minicron::CLI.new(['run', 'echo hello', '--trace']).run do |output|
      output.clean == 'hello'
    end
  end

  it 'should run a simple multi-line command and print the output to stdout' do
    Minicron::CLI.new(['run', 'ls -l', '--trace']).run do |output|
      output.clean == `ls -l`.clean
    end
  end

  it 'should return an error when a non-existent command is run' do
    capture_stderr do
      expect {
        Minicron::CLI.new(['lol']).run
      }.to raise_error(SystemExit)
    end
  end
end
