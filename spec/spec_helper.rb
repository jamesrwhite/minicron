require 'rspec'
require 'minicron/cli'
require 'stringio'
require 'coveralls'

Coveralls.wear!

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end

# Capture stdout by mocking it and then reset it
# adapted from http://stackoverflow.com/a/11349621/483271
def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end

# Capture stderr by mocking it and then reset it
# adapted from http://stackoverflow.com/a/11349621/483271
def capture_stderr(&block)
  original_stderr = $stderr
  $stderr = fake = StringIO.new
  begin
    yield
  ensure
    $stderr = original_stderr
  end
  fake.string
end

# Normalise varied new line usage
class String
  def clean
    self.strip.encode(self.encoding, :universal_newline => true)
  end
end
