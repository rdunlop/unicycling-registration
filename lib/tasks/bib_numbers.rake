desc "Find Duplicate bib numbers"
task find_dup_bib_numbers: :environment do
  puts "Searching for Duplicate Bib Numbers"
  dups = BibNumberUpdater.duplicates
  if dups.any?
    puts "***************************"
    puts "found #{dups.count} Duplicates"
    puts dups
    puts "***************************"
  end
  puts "done."
end
