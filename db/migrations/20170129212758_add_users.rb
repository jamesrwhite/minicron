class AddUsers < ActiveRecord::Migration
  def change
    create_table 'users' do |t|
      t.string  'name',        limit: 255, null: false
      t.string  'email',       limit: 255, null: false
      t.string   'password',   limit: 202, null: false
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
    end
  end
end
