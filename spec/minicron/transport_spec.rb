require 'spec_helper'
require 'minicron/transport'

describe Minicron::Transport do
  describe '.get_job_hash' do
    context 'when the correct params are passed' do
      it 'should return a 32 char string (md5 hash)' do
        hash = Minicron::Transport.get_job_hash('ls', 'server1')

        expect(hash.length).to eq 32
      end
    end
  end
end
