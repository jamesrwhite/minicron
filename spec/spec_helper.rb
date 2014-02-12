# require 'coveralls'
# Coveralls.wear!

require 'rspec'
require 'minicron'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end

# Normalise varied new line usage
class String
  def clean
    self.strip.encode(self.encoding, :universal_newline => true)
  end
end

# Taken from commander gem
# prevent paging from actually occurring in test environment
module Commander
  module UI
    def enable_paging
      return
    end
  end
end
