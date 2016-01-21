require 'spec_helper'
require 'minicron/transport/server'

describe Minicron::Transport::Server do
  let(:server) { Minicron::Transport::Server }
  let(:thin_server) { Thin::Server }

  describe '#start!' do
    context 'when the server is running' do
      it 'should return false' do
        allow(server).to receive(:server).and_return thin_server
        expect(server).to receive(:running?).and_return true

        expect(server.start!('127.0.0.1', 1337, '/lol')).to eq false
      end
    end

    context 'when the server is not running' do
      it 'should return true' do
        expect(server).to receive(:running?).and_return false
      	expect(thin_server).to receive(:new).and_return thin_server
        allow(thin_server).to receive(:start)

        expect(server.start!('127.0.0.1', 1337, '/lol')).to eq true
      end
    end
  end

  describe '#stop!' do
    context 'when the server is not running' do
      it 'should return false' do
        server.server = nil
        expect(server).to receive(:running?).and_return false

        expect(server.stop!).to eq false
      end
    end

    context 'when the server is running' do
      it 'should return true' do
        server.server = thin_server
        expect(server).to receive(:running?).and_return true
        expect(thin_server).to receive(:stop).and_return true

        expect(server.stop!).to eq true
      end
    end
  end

  describe '#running?' do
    context 'when the server is not running' do
      it 'should return false' do
        server.server = nil
        expect(Minicron::Transport::Server.running?).to eq false
      end
    end

    context 'when the server is running' do
      it 'should return true' do
        server.server = thin_server
        expect(thin_server).to receive(:running?).and_return true

        expect(server.running?).to eq true
      end
    end
  end
end
