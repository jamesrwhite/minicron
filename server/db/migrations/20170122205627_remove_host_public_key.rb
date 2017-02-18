class RemoveHostPublicKey < ActiveRecord::Migration
  def change
    remove_column :hosts, :public_key
  end
end
