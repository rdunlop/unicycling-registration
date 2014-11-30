desc "Update all counter caches"
task :update_counter_caches => :environment do
  puts "Updating Counter Caches..."
  EventCategory.counter_culture_fix_counts
  EventChoice.counter_culture_fix_counts
  puts "done."
end
