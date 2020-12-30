Aws.config.update(
  region: Rails.configuration.aws_region,
  credentials: Aws::Credentials.new(
    Rails.configuration.aws_access_key,
    Rails.configuration.aws_secret_access_key
  )
)
