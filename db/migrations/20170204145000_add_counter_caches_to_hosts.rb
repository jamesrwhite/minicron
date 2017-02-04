class AddCounterCachesToHosts < ActiveRecord::Migration
  def change
    add_column :hosts, :jobs_count, :integer, default: 0

    reversible do |dir|
      dir.up { data }
    end
  end

  def data
    execute <<-SQL.squish
      UPDATE hosts
      SET jobs_count = (
        SELECT count(1)
        FROM jobs
        WHERE jobs.host_id = hosts.id
      )
    SQL
  end
end
