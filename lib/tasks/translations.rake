desc "Update Translations from YML"
task import_translations_from_yml: :environment do
  puts "Importing Translations..."
  Tolk::Locale.locales_config_path = Rails.root.join("config", "locales")
  Tolk::Locale.sync_from_disk!
  puts "done."
end

desc "Write the tolk db contents to disk"
task write_tolk_to_disk: :environment do
  puts "Writing Tolk contents to disk..."
  Tolk::Locale.dump_all_to_files
  puts "done."
end

desc "Clear Translations from Tolk"
task clear_translations: :environment do
  puts "Clearing Translations..."
  Tolk::Locale.destroy_all
  Tolk::Phrase.destroy_all
  Tolk::Translation.destroy_all
  puts "done."
end
