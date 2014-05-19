autoload :ActiveRecord, 'active_record'

module Minicron
  module Hub
    class Alert < ActiveRecord::Base
      belongs_to :schedule
      belongs_to :execution
      belongs_to :job
    end
  end
end
