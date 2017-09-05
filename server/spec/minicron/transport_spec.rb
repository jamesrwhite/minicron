require 'spec_helper'
require Minicron::REQUIRE_PATH + 'transport'

describe Minicron::Transport do
  describe '.get_job_hash' do
    context 'when the correct params are passed' do
      it 'should return a 64 char string (sha256 hash)' do
        hash = Minicron::Transport.get_job_hash('ls')

        expect(hash).to eq 'c7b68ac37f364473e922936708e7f43c293dd07b295171566c07ff5fe024fab9'
      end
    end
  end
end
