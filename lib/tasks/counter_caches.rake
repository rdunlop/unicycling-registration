desc "Update all counter caches"
task :update_counter_caches => :environment do
  puts "Updating Counter Caches..."
  Event.all.each do |event|
    Event.reset_counters(event.id, :event_categories)
    Event.reset_counters(event.id, :event_choices)
  end
  puts "done."
end
