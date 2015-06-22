require 'spec_helper'
require 'minicron/alert/aws_sns'

describe Minicron::AwsSns do

  before (:each) do
    Minicron.parse_config_hash({
      'alerts' => {
        'aws_sns' => {
          'secret_access_key' => 'jiuwmEf91KWMqzsUlV/xzuDku7otULnAmm7v/bSM',
          'access_key_id' => 'AKIAJMUAH24YJW6BCX2Q',
          'region' => 'us-west-2',
          'topic_arn' => 'arn:aws:sns:us-west-2:453856305308:minicron-test'
        }
      }
    })
  end

  describe '#intiailize' do
    it 'should create an instance of the Twilio gem' do
      sns = Minicron::AwsSns.new

      expect(sns.instance_variable_get(:@client)).to be_a Aws::SNS::Client
    end
  end

  describe '#get_message' do
    context 'when kind is miss' do
      it 'should return the correct message' do
        sns = Minicron::AwsSns.new
        time = Time.now.utc
        options = {
          :job_id => 1,
          :expected_at => time,
          :execution_id => 2,
          :kind => 'miss'
        }
        message = "minicron alert - job missed!\nJob #1 failed to execute at its expected time: #{time}"

        expect(sns.get_message(options)).to eq message
      end
    end

    context 'when kind is fail' do
      it 'should return the correct message' do
        sns = Minicron::AwsSns.new
        options = {
          :job_id => 1,
          :execution_id => 2,
          :kind => 'fail'
        }
        message = "minicron alert - job failed!\nExecution #2 of Job #1 failed"

        expect(sns.get_message(options)).to eq message
      end
    end

    context 'when kind is not supported' do
      it 'should raise an Exception' do
        sns = Minicron::AwsSns.new
        options = {
          :kind => 'derp'
        }

        expect do
          sns.get_message(options)
        end.to raise_error Exception
      end
    end
  end

  describe '#send' do
    it 'sends message to the topic_arn' do
      sns = Minicron::AwsSns.new
      subject = 'subject'
      message = 'message'
      expect_any_instance_of(Aws::SNS::Client).to receive(:publish).with(
        topic_arn: Minicron.config['alerts']['aws_sns']['topic_arn'],
        subject: subject,
        message: message
      )

      sns.send(subject, message)
    end
  end

end
