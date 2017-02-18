require 'spec_helper'
require Minicron::REQUIRE_PATH + 'alert/sms'

describe Minicron::Alert::SMS do
  before (:each) do
    Minicron.parse_config_hash('alerts' => {
                                 'sms' => {
                                   'twilio' => {
                                     'account_sid' => 'abc123',
                                     'auth_token' => 'abc456'
                                   }
                                 }
                               })
  end

  describe '#intiailize' do
    it 'should create an instance of the Twilio gem' do
      sms = Minicron::Alert::SMS.new

      expect(sms.instance_variable_get(:@client)).to be_a Twilio::REST::Client
    end
  end

  describe '#get_message' do
    context 'when kind is miss' do
      it 'should return the correct message' do
        sms = Minicron::Alert::SMS.new
        time = Time.now.utc
        options = {
          job_id: 1,
          expected_at: time,
          execution_id: 2,
          kind: 'miss'
        }
        message = "minicron alert - job missed!\nJob #1 failed to execute at its expected time: #{time}"

        expect(sms.get_message(options)).to eq message
      end
    end

    context 'when kind is fail' do
      it 'should return the correct message' do
        sms = Minicron::Alert::SMS.new
        options = {
          job_id: 1,
          execution_id: 2,
          kind: 'fail'
        }
        message = "minicron alert - job failed!\nExecution #2 of Job #1 failed"

        expect(sms.get_message(options)).to eq message
      end
    end

    context 'when kind is not supported' do
      it 'should raise an Exception' do
        sms = Minicron::Alert::SMS.new
        options = {
          kind: 'derp'
        }

        expect do
          sms.get_message(options)
        end.to raise_error Exception
      end
    end
  end
end
