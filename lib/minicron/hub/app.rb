require 'sinatra/base'
require 'sinatra/activerecord'
require 'liquid'

module Minicron::Hub
  class App < Sinatra::Base
    register Sinatra::ActiveRecordExtension

    configure :development do
      # Configure the database
      case Minicron.config['database']['type']
      when 'mysql'
        set :database, {
          :adapter => 'mysql2',
          :host => Minicron.config['database']['host'],
          :database => Minicron.config['database']['database'],
          :username => Minicron.config['database']['username'],
          :password => Minicron.config['database']['password']
        }
      when 'sqlite'
        set :database, {
          :adapter => 'sqlite3',
          :database => HUB_PATH + '/db/minicron.sqlite3', # TODO: Allow configuring this but default to this value
        }
      else
        raise Exception, "The database #{Minicron.config['database']['type']} is not supported"
      end
    end
  end
end

# Load all our models
Dir[File.dirname(__FILE__) + '/models/*.rb'].each do |model|
  require model
end

# Load all our controllers
Dir[File.dirname(__FILE__) + '/controllers/*.rb'].each do |controller|
  require controller
end
