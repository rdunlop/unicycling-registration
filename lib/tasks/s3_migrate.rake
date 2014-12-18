desc "Migrate S3 data from previous-url structure to the new storage structure"
task :migrate_s3 => :environment do
  source_directory = "old_naucc_2013"
  subdomain = "naucc2013"

  Song.all.each do |song|
    identifier = song.song_file_name_identifier
    move_s3("#{source_directory}/uploads/#{identifier}", "#{subdomain}/uploads/song/song_file_name/#{song.id}/#{identifier}")
  end

  ec = EventConfiguration.first
  identifier = ec.logo_file_identifier
  move_s3("#{source_directory}/uploads/#{identifier}", "#{subdomain}/uploads/logo/#{identifier}")

  CompetitionResult.all.each do |result|
    identifier = result.results_file_identifier
    move_s3("#{source_directory}/uploads/#{identifier}", "#{subdomain}/uploads/competition_result/results_file/#{result.id}/#{identifier}")
  end
end

def move_s3(old_path, new_path)
  puts "moving #{old_path} => #{new_path}"
end
