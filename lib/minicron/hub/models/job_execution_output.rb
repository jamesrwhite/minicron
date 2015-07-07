autoload :ActiveRecord, 'sinatra/activerecord'

module Minicron
  module Hub
    class JobExecutionOutput < ActiveRecord::Base
      belongs_to :execution

      validates :execution_id, :presence => true, :numericality => { :only_integer => true }
      validates :seq, :presence => true, :numericality => { :only_integer => true }
      validates :output, :presence => true
      validates :timestamp, :presence => true
    end
  end
end
