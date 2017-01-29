namespace :global_user do
  desc "Get Maximum_user id from all tenants"
  task maximum_user_id: :environment do
    puts "searching all tenants"
    puts "ID: #{GlobalUserMigrator.maximum_user_id}"
  end

  desc "Set GlobalUser starting ID (specify the number BELOW the next value)"
  task :set_starting_user_id, [:start_user_id] => :environment do |_t, args|
    start_user_id = args[:start_user_id]
    GlobalUserMigrator.set_global_start_user_id(start_user_id)
  end

  # Invoke with: bundle exec rake migrate_single_tenant_users[hello]
  desc "Migrate Users to the Global User table for a single tenant"
  task :migrate_single_tenant_users, [:tenant] => :environment do |_t, args|
    tenant = args[:tenant]
    puts "Migrating Users for #{tenant}"
    GlobalUserMigrator.new(tenant).update_global_users
    puts "done."
  end

  desc "Migrate the Data for a single Tenant"
  task :migrate_single_tenant_data, [:tenant] => :environment do |_t, args|
    tenant = args[:tenant]
    puts "Migrating Data for #{tenant}"
    GlobalUserMigrator.new(tenant).migrate_user_ids
    puts "done."
  end
end
