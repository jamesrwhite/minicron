require 'active_record'
require 'scrypt'
require 'digest/md5'

module Minicron
  module Hub
    class User < ActiveRecord::Base
      validates :name,     presence: true, length: { maximum: 255 }
      validates :email,    presence: true, uniqueness: true, length: { maximum: 255 }
      validates :password, presence: true

      def avatar
        "https://s.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
      end

      def self.auth(email, password)
        # Find the user based on their email address
        user = Minicron::Hub::User.where(email: email).first

        return false if !user

        hashed_password = SCrypt::Password.new(user.password)

        if hashed_password.is_password?(password)
          return user
        end

        return false
      end
    end
  end
end
