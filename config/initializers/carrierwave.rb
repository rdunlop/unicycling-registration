CarrierWave.configure do |config|
  if Rails.application.secrets.aws_access_key
    config.storage = :fog
    config.fog_credentials = {
        provider: "AWS",
        aws_access_key_id: Rails.application.secrets.aws_access_key,
        aws_secret_access_key: Rails.application.secrets.aws_secret_access_key
    }
    config.fog_directory = Rails.application.secrets.aws_bucket
    config.fog_attributes = {
        'Cache-Control' => 'max-age=315576000'
    }

    config.max_file_size             = 40.megabytes
    config.will_include_content_type = true
  else
    config.storage = :file
  end
end
