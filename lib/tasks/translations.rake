desc "Update Translations from YML"
task :import_translations_from_yml => :environment do
  puts "Importing Translations..."
  Tolk::Locale.locales_config_path = Rails.root.join("config","locales")
  Tolk::Locale.sync_from_disk!
  puts "done."
end
