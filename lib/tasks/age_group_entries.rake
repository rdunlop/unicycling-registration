desc "Update all age_group_entries"
task update_age_group_entries: :environment do
  puts "Updating Age Group Entries..."
  AgeGroupType.update_all
  puts "done."
end
