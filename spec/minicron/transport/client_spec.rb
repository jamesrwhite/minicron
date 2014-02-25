require 'spec_helper'
require 'webmock/rspec'

describe Minicron::Transport::Client do
  let(:client) { Minicron::Transport::Client }
  let(:eventmachine) { EM }

  describe '#initialize' do
    it 'should set the host and queue instance variable' do
      client_instance = client.new('http', '127.0.0.1', '80', '/test')
      expect(client_instance.url).to eq 'http://127.0.0.1:80/test'
      expect(client_instance.queue).to eq({})
    end
  end

  describe '#ensure_em_running' do
    context 'when eventmachine is not running' do
      it 'should start eventmachine' #do
      #   eventmachine.stub(:reactor_running?).and_return(false, true)
      #   eventmachine.stub(:run)
      #   eventmachine.should_receive(:reactor_running?).twice
      #   eventmachine.should_receive(:run).once

      #   client.new('http://127.0.0.1/test').ensure_em_running
      # end
    end

    context 'when eventmachine is running' do
      it 'should not start eventmachine' #do
    #     eventmachine.stub(:reactor_running?).and_return true
    #     eventmachine.should_receive(:reactor_running?).twice

    #     client.new('http://127.0.0.1/test').ensure_em_running
    #   end
    end
  end

  describe '#ensure_delivery' do
    before(:each) { eventmachine.stub(:stop) }
    it 'should block until the queue hash is empty and return nil' do
      client_instance = client.new('http', '127.0.0.1', '80', '/test')
      client_instance.stub(:queue).and_return({ :a => 1 }, { :a => 1, :b => 2 }, { :b => 2 }, {})

      client_instance.ensure_delivery
      expect(client_instance.queue.length).to eq 0
    end
  end

  describe '#tidy_up'
   it 'should stop eventmachine' do
    eventmachine.should_receive(:stop)
    client.new('http', '127.0.0.1', '80', '/test').tidy_up
  end
end
