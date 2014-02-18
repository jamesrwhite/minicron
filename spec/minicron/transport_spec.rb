require 'spec_helper'

describe Minicron::Transport do
  describe '.get_job_id' do
    context 'when the correct params are passed' do
      it 'should return a 40 char string (sha1 hash)' do
        hash = Minicron::Transport.get_job_id('ls', 'server1')

        expect(hash.length).to eq 40
      end
    end
  end
end
