CarrierWave.configure do |config|
  if Rails.configuration.aws_access_key.present?
    config.storage = :aws
    config.aws_credentials = {
      access_key_id: Rails.configuration.aws_access_key,
      secret_access_key: Rails.configuration.aws_secret_access_key,
      region: Rails.configuration.aws_region
    }
    config.aws_bucket = Rails.configuration.aws_bucket
    config.aws_acl = 'private'

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
