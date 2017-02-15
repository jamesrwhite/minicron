class AddApiKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_key, :string, limit: 64, null: false, unique: true
    add_index  :users, :api_key, name: 'unique_api_key_per_user', unique: true, using: :btree
  end
end
