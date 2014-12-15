desc "This task describes how to migrate the data to the single-instance"
task :db_backup_commands => :environment do
  puts "psql -c 'create database app_tenant template <current_app_db>' <current_app_db>"
  puts "psql -c 'ALTER schema public RENAME to <new_tenant_schema>' app_tenant"
  puts "pg_dump -n <new_tenant_schema> app_tenant -f tenant.schema"
  puts "psql -f tenant.schema <combined_database>"

  #puts "psql -c 'ALTER SCHEMA public RENAME TO alpha_old'"
  #puts "psql -c 'create schema public'"
  #puts "psql -f alpha.schema"
  #puts "psql -c 'ALTER SCHEMA public RENAME TO <new_tenant_schema>'"
  #puts "psql -c 'ALTER SCHEMA alpha_old RENAME TO public'"
end
