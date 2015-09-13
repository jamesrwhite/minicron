require 'spec_helper'
require 'minicron/transport/faye/client'

describe Minicron::Transport::FayeClient do
  let(:client) { Minicron::Transport::FayeClient }
  let(:eventmachine) { EM }

  describe '#initialize' do
    it 'should set the host and queue instance variable' do
      client_instance = client.new('http', '127.0.0.1', '80', '/test')
      expect(client_instance.url).to eq 'http://127.0.0.1:80/test'
      expect(client_instance.queue).to eq({})
    end
  end

  describe '#ensure_delivery' do
    before(:each) { allow(eventmachine).to receive(:stop) }

    it 'should block until the queue hash is empty and return nil' do
      client_instance = client.new('http', '127.0.0.1', '80', '/test')
      allow(client_instance).to receive(:queue).and_return({ :a => 1 }, { :a => 1, :b => 2 }, { :b => 2 }, {})

      client_instance.ensure_delivery
      expect(client_instance.queue.length).to eq 0
    end
  end

  # describe '#ensure_em_running' do
  #   context 'when eventmachine is not running' do
  #     it 'should start eventmachine' do
  #        eventmachine.stub(:reactor_running?).and_return(false, true)
  #        eventmachine.stub(:run)
  #        eventmachine.should_receive(:reactor_running?).twice
  #        eventmachine.should_receive(:run).once

  #        client.new('http', '127.0.0.1', '80', '/test').ensure_em_running
  #     end
  #   end

  #   context 'when eventmachine is running' do
  #     it 'should not start eventmachine' do
  #       eventmachine.stub(:reactor_running?).and_return true
  #       eventmachine.should_receive(:reactor_running?).twice

  #       client.new('http', '127.0.0.1', '80', '/test').ensure_em_running
  #     end
  #   end
  # end

  describe '#tidy_up' do
    context 'when eventmachine is running' do
      it 'should stop eventmachine' do
        expect(eventmachine).to receive(:reactor_running?).and_return true
        expect(eventmachine).to receive(:stop)

        client.new('http', '127.0.0.1', '80', '/test').tidy_up
      end
    end

    context 'when eventmachine is not running' do
      it 'should do nothing' do
        expect(eventmachine).to receive(:reactor_running?).and_return false

        client.new('http', '127.0.0.1', '80', '/test').tidy_up
      end
    end
  end
end
