require 'active_record'

module Minicron::Hub
  module Model
    class Base < ActiveRecord::Base
      self.abstract_class = true

      scope :belonging_to, ->(user) { where("user_id = ?", user.id) }
    end
  end
end
