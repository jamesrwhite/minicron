require 'spec_helper'

describe Minicron do
  describe '.capture_output' do
    context 'when :stdout is passed as an option' do
      it 'should return a StringIO instance' do
        output = Minicron.capture_output(:type => :stdout) do
          $stdout.write 'I like turtles!'
        end

        expect(output).to be_an_instance_of StringIO
      end
    end

    context 'when :stderr is passed as an option' do
      it 'should return a StringIO instance' do
        output = Minicron.capture_output(:type => :stderr) do
          $stderr.write 'Quit yo jibber jabber, fool!'
        end

        expect(output).to be_an_instance_of StringIO
      end
    end

    context 'when :both is passed as an option' do
      it 'should return a Hash' do
        output = Minicron.capture_output(:type => :both) do
          $stdout.write 'I like turtles!'
          $stderr.write 'Quit yo jibber jabber, fool!'
        end

        expect(output).to be_an_instance_of Hash
      end
    end

    context 'when :both is passed as an option' do
      it 'should return a Hash containing :stdout and :stderr with two StringIO instances' do
        output = Minicron.capture_output(:type => :both) do
          $stdout.write 'I like turtles!'
          $stderr.write 'Quit yo jibber jabber, fool!'
        end

        expect(output).to have_key :stdout
        expect(output).to have_key :stderr
        expect(output[:stdout]).to be_an_instance_of StringIO
        expect(output[:stderr]).to be_an_instance_of StringIO
      end
    end

    context 'when an invalid :type is used' do
      it 'should raise an ArgumentError' do
        expect do
          Minicron.capture_output(:type => :lol) do
            $stdout.write 'I like turtles!'
            $stderr.write 'Quit yo jibber jabber, fool!'
          end
        end.to raise_error ArgumentError
      end
    end
  end
end
