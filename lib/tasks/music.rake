desc "Remove incomplete music - dry run"
task remove_incomplete_music_dry_run: :environment do
  Apartment.tenant_names.each do |tenant|
    Apartment::Tenant.switch(tenant) do
      puts "#{tenant} -> #{to_delete.count} songs"
    end
  end
end

desc "Remove incomplete music"
task remove_incomplete_music_real: :environment do
  Apartment.tenant_names.each do |tenant|
    Apartment::Tenant.switch(tenant) do
      to_delete.destroy_all
    end
  end
end

def to_delete
  Song.where(song_file_name: nil)
end
