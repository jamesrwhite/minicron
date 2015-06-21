require 'spec_helper'
require 'minicron/alert'
require 'minicron/alert/aws_sns'

describe Minicron::Alert do

  describe '#send' do
    context 'when medium is AWS SNS' do
      it 'sends message' do
        alert = Minicron::Alert.new
        allow(Minicron::Hub::Job).to receive(:find).and_return(nil)
        allow(Minicron::Hub::Alert).to receive(:create).and_return(nil)
        expect_any_instance_of(Minicron::Alert).to receive(:send_aws_sns)

        alert.send({
          medium: 'aws_sns',
          job_id: 1
        })
      end
    end
  end

end
