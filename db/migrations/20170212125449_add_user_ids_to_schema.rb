require 'highline'
require 'scrypt'
require 'minicron'
require 'minicron/hub/app'

class AddUserIdsToSchema < ActiveRecord::Migration
  def change
    puts "What user do you want to own any existing hosts/jobs/schedules/alerts?"

    cli = HighLine.new
    name = cli.ask("Name: ")
    email = cli.ask("Email: ")
    password = cli.ask("Password: ") { |q| q.echo = false }

    # Validate the password length here before it gets to the model
    if password.length < 8
      raise Minicron::AuthError, "Password must be at least 8 characters long"
    end

    # Hash their password with scrypt
    hashed_password = SCrypt::Password.create(password, key_len: 64)

    # Create their account
    user = Minicron::Hub::User.create!(
      name: name,
      email: email,
      password: hashed_password,
      api_key: SecureRandom.urlsafe_base64(48)
    )

    add_column :alerts, :user_id, :integer, null: false
    add_column :executions, :user_id, :integer, null: false
    add_column :hosts, :user_id, :integer, null: false
    add_column :job_execution_outputs, :user_id, :integer, null: false
    add_column :jobs, :user_id, :integer, null: false
    add_column :schedules, :user_id, :integer, null: false

    %w(alerts executions hosts job_execution_outputs jobs schedules).each do |table|
      execute <<-SQL.squish
        UPDATE #{table}
        SET user_id = #{user.id}
      SQL
    end
  end
end
