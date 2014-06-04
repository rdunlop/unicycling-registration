CarrierWave.configure do |config|
  if ENV['AWS_ACCESS_KEY'].present?
    config.storage = :fog
    config.fog_credentials = {
        provider: "AWS",
        aws_access_key_id: ENV['AWS_ACCESS_KEY'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    }
    config.fog_directory = ENV['AWS_BUCKET']
    config.fog_attributes = {
        'Cache-Control' => 'max-age=315576000'
    }

    config.max_file_size             = 40.megabytes
    config.will_include_content_type = true
  else
    config.storage = :file
  end
end
