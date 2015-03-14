desc "Migrate S3 data from previous-url structure to the new storage structure. e.g. mirgate_s3['old_path','new_subdomain']"
task :migrate_s3, [:source_directory, :new_subdomain] => :environment do |t, args|
  source_directory = args[:source_directory] # e.g. "old_naucc_2013"
  subdomain = args[:new_subdomain] # e.g. "naucc2013"

  Apartment::Tenant.switch subdomain
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
  s3 = AWS::S3.new(access_key_id: Rails.application.secrets.aws_access_key,
                   secret_access_key: Rails.application.secrets.aws_secret_access_key,
                   region: Rails.application.secrets.aws_region)
  bucket = s3.buckets[Rails.application.secrets.aws_bucket]
  obj = bucket.objects[old_path]
  puts "obj.key not found (#{obj.key}" unless obj.exists?
  obj.copy_to(new_path, acl: :public_read)
end
