CarrierWave.configure do |config|
  if ENV['AWS_ACCESS_KEY'].present?
    config.storage = :fog
    config.fog_credentials = {
        provider: "AWS",
        aws_access_key_id: ENV['AWS_ACCESS_KEY'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
        #region: "us-west-1",
        #endpoint: "http://robind.s3-us-west-2.amazonaws.com"
    }
    config.fog_directory = ENV['AWS_BUCKET']
    config.fog_attributes = {
        'Cache-Control' => 'max-age=315576000'
    }
  else
    config.storage = :file
  end
end
