desc "This task describes how to migrate the data to the single-instance"
task :db_backup_commands => :environment do
  puts "psql -c 'create database app_tenant template <current_app_db>' <current_app_db>"
  puts "psql -c 'ALTER schema public RENAME to <new_tenant_schema>' app_tenant"
  puts "pg_dump -n <new_tenant_schema> app_tenant -f tenant.schema"
  puts "psql -f tenant.schema <combined_database>"

  # puts "psql -c 'ALTER SCHEMA public RENAME TO alpha_old'"
  # puts "psql -c 'create schema public'"
  # puts "psql -f alpha.schema"
  # puts "psql -c 'ALTER SCHEMA public RENAME TO <new_tenant_schema>'"
  # puts "psql -c 'ALTER SCHEMA alpha_old RENAME TO public'"
end

# To Restore a database from a single-instance server:
# pg_dump the data into new_subdomain.dump

# restore the data
#  pg_restore --verbose --clean --no-acl --no-owner -h localhost -U robindunlop -d new_instance new_subdomain.dump

# alter the schema
# psql -c 'ALTER schema public RENAME to new_subdomain' new_instance

# Dump the new schema
# pg_dump -n new_subdomain new_instance -f new_subdomain.schema

# Load the schema into the combined database
# psql -f new_subdomain.schema <combined_database>
