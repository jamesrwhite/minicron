autoload :ActiveRecord, 'active_record'

module Minicron
  module Hub
    class JobExecutionOutput < ActiveRecord::Base
      belongs_to :execution
    end
  end
end
