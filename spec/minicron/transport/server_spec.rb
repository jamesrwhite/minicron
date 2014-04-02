require 'spec_helper'

describe Minicron::Transport::Server do
  let(:server) { Minicron::Transport::Server }
  let(:thin_server) { Thin::Server }

  describe '#start!' do
    context 'when the server is running' do
      it 'should return false' do
        server.stub(:server).and_return thin_server
        server.should_receive(:running?).and_return true

        expect(server.start!('127.0.0.1', 1337, '/lol')).to eq false
      end
    end

    context 'when the server is not running' do
      it 'should return true' do
        server.should_receive(:running?).and_return false
      	thin_server.should_receive(:new).and_return thin_server
        thin_server.stub(:start)

        expect(server.start!('127.0.0.1', 1337, '/lol')).to eq true
      end
    end
  end

  describe '#stop!' do
    context 'when the server is not running' do
      it 'should return false' do
        server.should_receive(:running?).and_return false

        expect(server.stop!).to eq false
      end
    end

    context 'when the server is running' do
      it 'should return true' do
        server.should_receive(:running?).and_return true
        thin_server.should_receive(:stop).and_return true

        expect(server.stop!).to eq true
      end
    end
  end

  describe '#running?' do
    context 'when the server is not running' do
      it 'should return false' do
        thin_server.should_receive(:running?).and_return false

        expect(server.running?).to eq false
      end
    end

    context 'when the server is running' do
      it 'should return true' do
        thin_server.should_receive(:running?).and_return true

        expect(server.running?).to eq true
      end
    end
  end
end
