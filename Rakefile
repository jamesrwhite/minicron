require 'minicron'
require 'bundler/gem_tasks'

# Task for local dev to dump schema
task :dump_schema do
  # Parse our local config file
  Minicron.parse_file_config('./my.config.toml')

  # Connect to the db
  Minicron.establish_db_connection(
    Minicron.config['server']['database'],
    Minicron.config['verbose']
  )

  # Dump the schema file
  ActiveRecord::SchemaDumper.dump
end
