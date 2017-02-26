require 'spec_helper'
require Minicron::REQUIRE_PATH + 'cli'

describe Minicron::CLI do
  let(:server) { Minicron::Transport::Server }
  let(:thin_server) { Thin::Server }

  describe '#server' do
    it 'should start the minicron server' # do
    # server.should_receive(:start!)
    # server.should_receive(:running?)
    # server.should_receive(:server)
    # thin_server.should_receive(:new).and_return Thin::Server
    # Thin::Server.stub(:start)

    # Minicron::CLI.new.run(['server'])
    # end
  end

  describe '#coloured_output?' do
    context 'when Rainbow is enabled' do
      it 'should return true' do
        Rainbow.enabled = true

        expect(Minicron::CLI.coloured_output?).to eq true
      end
    end

    context 'when Rainbow is disabled' do
      it 'should return false' do
        Rainbow.enabled = false

        expect(Minicron::CLI.coloured_output?).to eq false
      end
    end
  end

  describe '#enable_coloured_output!' do
    it 'should set Rainbow.enabled to true' do
      Minicron::CLI.enable_coloured_output!

      expect(Rainbow.enabled).to eq true
      expect(Minicron::CLI.coloured_output?).to eq true
    end
  end

  describe '#disable_coloured_output!' do
    it 'should set Rainbow.enabled to false' do
      Minicron::CLI.disable_coloured_output!

      expect(Rainbow.enabled).to eq false
      expect(Minicron::CLI.coloured_output?).to eq false
    end
  end
end
