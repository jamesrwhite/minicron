require 'spec_helper'
require 'minicron/alert/slack'

describe Minicron::Alert::Slack do
  before (:each) do
    Minicron.parse_config_hash({
      'alerts' => {
        'slack' => {
          'webhook_url' => 'https://hooks.slack.com/services/abc/123',
          'channel' => '#blah'
        }
      }
    })
  end

  describe '#initialize' do
    it 'should create an instance of the Slack gem' do
      slack = Minicron::Alert::Slack.new

      expect(slack.instance_variable_get(:@client)).to be_a Slack::Notifier
    end
  end

  describe '#get_message' do
    context 'when kind is miss' do
      it 'should return the correct message' do
        slack = Minicron::Alert::Slack.new
        time = Time.now.utc
        options = {
          :job_id => 1,
          :expected_at => time,
          :execution_id => 100,
          :kind => 'miss',
          :job => {
            :name => 'Spec Job'
          }
        }
        message = "Job 'Spec Job' (#1) failed to execute at its expected time - #{time}"

        expect(slack.get_message(options)).to eq message
      end
    end

    context 'when kind is fail' do
      it 'should return the correct message' do
        slack = Minicron::Alert::Slack.new
        options = {
          :job_id => 1,
          :execution_id => 100,
          :kind => 'fail',
          :job => {
            :name => 'Spec Job'
          }
        }
        message = "Execution #100 of Job 'Spec Job' (#1) failed"

        expect(slack.get_message(options)).to eq message
      end
    end

    context 'when kind is not supported' do
      it 'should raise an Exception' do
        pagerduty = Minicron::Alert::Slack.new
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
    it 'should send message on slack channel' do
      slack = Minicron::Alert::Slack.new
      expect(slack.instance_variable_get(:@client)).to receive(:ping).with('yo')

      slack.send('yo')
    end
  end
end
