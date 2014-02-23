require 'sinatra/base'

module Minicron
  module Hub
    class App < Sinatra::Base
      get '/' do
        'hello world'
      end
    end
  end
end
