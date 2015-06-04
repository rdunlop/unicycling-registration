desc "Update all counter caches"
task update_counter_caches: :environment do
  puts "Updating Counter Caches..."
  EventConfiguration.reset_counter_caches
  puts "done."
end
