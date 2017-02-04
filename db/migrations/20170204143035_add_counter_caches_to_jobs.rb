class AddCounterCachesToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :executions_count, :integer, default: 0
    add_column :jobs, :schedules_count, :integer, default: 0

    reversible do |dir|
      dir.up { data }
    end
  end

  def data
    execute <<-SQL.squish
      UPDATE jobs
      SET executions_count = (
        SELECT count(1)
        FROM executions
        WHERE executions.job_id = jobs.id
      )
    SQL

    execute <<-SQL.squish
      UPDATE jobs
      SET schedules_count = (
        SELECT count(1)
        FROM schedules
        WHERE schedules.job_id = jobs.id
      )
    SQL
  end
end
