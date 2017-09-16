CarrierWave.configure do |config|
  if Rails.application.secrets.aws_access_key
    config.storage = :aws
    config.aws_credentials = {
      access_key_id: Rails.application.secrets.aws_access_key,
      secret_access_key: Rails.application.secrets.aws_secret_access_key,
      region: Rails.application.secrets.aws_region
    }
    config.aws_bucket = Rails.application.secrets.aws_bucket
    config.aws_acl = 'public-read'

    config.aws_attributes = {
      cache_control: 'max-age=315576000'
    }

    # config.max_file_size            = 40.megabytes
    # config.will_include_content_type = true
  else
    config.storage = :file
  end

  if Rails.env.test?
    config.enable_processing = false
  end
end
