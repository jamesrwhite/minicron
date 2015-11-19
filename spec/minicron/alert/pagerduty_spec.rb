require 'spec_helper'
require 'minicron/alert/pagerduty'

describe Minicron::PagerDuty do
  describe '#intiailize' do
    it 'should create an instance of the Pagerduty gem' do
      pagerduty = Minicron::PagerDuty.new

      expect(pagerduty.instance_variable_get(:@client)).to be_a Pagerduty
    end
  end

  describe '#get_message' do
    context 'when kind is miss' do
      it 'should return the correct message' do
        pagerduty = Minicron::PagerDuty.new
        time = Time.now.utc
        options = {
          :job_id => 1,
          :expected_at => time,
          :execution_id => 2,
          :kind => 'miss'
        }
        message = "Job #1 failed to execute at its expected time - #{time}"

        expect(pagerduty.get_message(options)).to eq message
      end
    end

    context 'when kind is fail' do
      it 'should return the correct message' do
        pagerduty = Minicron::PagerDuty.new
        options = {
          :job_id => 1,
          :execution_id => 2,
          :kind => 'fail'
        }
        message = "Execution #2 of Job #1 failed"

        expect(pagerduty.get_message(options)).to eq message
      end
    end

    context 'when kind is not supported' do
      it 'should raise an Exception' do
        pagerduty = Minicron::PagerDuty.new
        options = {
          :kind => 'derp'
        }

        expect do
          pagerduty.get_message(options)
        end.to raise_error Exception
      end
    end
  end

  describe '#send' do
    it 'should trigger an alert on the pagerduty client' do
      pagerduty = Minicron::PagerDuty.new

      expect(pagerduty.instance_variable_get(:@client)).to receive(:trigger).with('title', :message => 'yo')

      pagerduty.send('title', 'yo')
    end
  end
end
