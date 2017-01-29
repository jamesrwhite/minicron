require 'active_record'
require 'scrypt'

module Minicron
  module Hub
    class User < ActiveRecord::Base
      validates :name,     presence: true, length: { maximum: 255 }
      validates :email,    presence: true, uniqueness: true, length: { maximum: 255 }
      validates :password, presence: true

      def valid_password?(test_password)
        SCrypt::Password.new(read_attribute(:password)) == test_password
      end
    end
  end
end
