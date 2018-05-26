require 'active_record'
require 'scrypt'
require 'digest/md5'

module Minicron::Hub
  module Model
    class User < Minicron::Hub::Model::Base
      validates :name,     presence: true, length: { maximum: 255 }
      validates :email,    presence: true, uniqueness: true, length: { maximum: 255 }
      validates :password, presence: true

      has_many :alerts, dependent: :destroy
      has_many :hosts, dependent: :destroy
      has_many :executions, dependent: :destroy
      has_many :jobs, dependent: :destroy
      has_many :job_execution_outputs, dependent: :destroy

      def avatar
        "https://s.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}"
      end

      def self.auth(email, password)
        # Find the user based on their email address
        user = Minicron::Hub::Model::User.where(email: email).first

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
