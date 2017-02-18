class RemoveHostUser < ActiveRecord::Migration
  def change
    remove_column :hosts, :user
  end
end
