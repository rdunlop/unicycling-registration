Aws.config.update(
  region: Rails.application.secrets.aws_region,
  credentials: Aws::Credentials.new(
    Rails.application.secrets.aws_access_key,
    Rails.application.secrets.aws_secret_access_key
  )
)
