class RemoveHostPort < ActiveRecord::Migration
  def change
    remove_column :hosts, :port
  end
end
