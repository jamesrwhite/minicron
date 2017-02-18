class RemoveHostHost < ActiveRecord::Migration
  def change
    remove_column :hosts, :host
  end
end
