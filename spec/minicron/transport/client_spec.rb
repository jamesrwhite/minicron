require 'spec_helper'
require 'minicron/transport/client'

describe Minicron::Transport::Client do
  describe '#initialize' do
    context 'when path is root' do
      it 'should set the correct instance variables and call the parent init' do
        client = Minicron::Transport::Client.new('http', 'example.com', 99, '/')

        expect(client.instance_variable_get(:@scheme)).to eq 'http'
        expect(client.instance_variable_get(:@host)).to eq 'example.com'
        expect(client.instance_variable_get(:@port)).to eq 99
        expect(client.instance_variable_get(:@path)).to eq '/faye'
        expect(client.instance_variable_get(:@seq)).to eq 1
      end
    end

    context 'when path is not root' do
      it 'should set the correct instance variables and call the parent init' do
        client = Minicron::Transport::Client.new('https', 'test.com', 139, '/test')

        expect(client.instance_variable_get(:@scheme)).to eq 'https'
        expect(client.instance_variable_get(:@host)).to eq 'test.com'
        expect(client.instance_variable_get(:@port)).to eq 139
        expect(client.instance_variable_get(:@path)).to eq '/test/faye'
        expect(client.instance_variable_get(:@seq)).to eq 1
      end
    end
  end

  describe '#setup' do
    # before(:each) do
    #   let(:client) do
    #     client = Minicron::Transport::Client.new('https', 'test.com', 139, '/test')
    #     client.stub(:ensure_delivery)
    #     client.instance_variable_set(:@responses, {[
    #       :body => :channel
    #     ]})
    #   end
    # end

    it 'should call #publish with the correct params'
  end

  describe '#send' do
    it 'should call #publish with the correct params' do
      client = Minicron::Transport::Client.new('http', 'example.com', 99, '/')

      expect(client).to receive(:publish).with('/job/1/2/output', 'test')

      client.send(
        :job_id => 1,
        :execution_id => 2,
        :type => :output,
        :message => 'test'
      )
    end
  end

  describe '#publish' do
    it 'should call #request with the correct params' do
      client = Minicron::Transport::Client.new('https', 'test.com', 139, '/test')
      allow(client).to receive(:request)

      json = { :channel => '/job/1/2/status', :data => {
        :ts => Time.now.utc.strftime('%Y-%m-%d %H:%M:%S'),
        :message => 'test',
        :seq => 1
      } }.to_json

      expect(client).to receive(:request).with(:message => json)

      client.publish('/job/1/2/status', 'test')

      expect(client.instance_variable_get(:@seq)).to eq 2
    end
  end
end
