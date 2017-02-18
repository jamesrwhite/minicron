class RemoveJobUser < ActiveRecord::Migration
  def change
    remove_column :jobs, :user
  end
end
