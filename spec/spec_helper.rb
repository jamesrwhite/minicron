if ENV['CI'] && (!defined?(RUBY_ENGINE) || RUBY_ENGINE == 'ruby')
  require 'coveralls'
  Coveralls.wear!
end

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'rspec'
require 'minicron'
require 'minicron/cli'

RSpec.configure do |config|
  config.color = true
  config.formatter     = 'documentation'

  # Taken from commander gem
  # prevent paging from actually occurring in test environment
  config.before(:each) do
    allow(Commander::UI).to receive(:enable_paging)
  end
end

# Normalise varied new line usage
class String
  def clean
    strip.gsub(/\r\n?/, "\n")
  end
end
