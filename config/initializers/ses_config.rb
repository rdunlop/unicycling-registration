AWS.config( access_key_id: Rails.application.secrets.aws_access_key,
            secret_access_key: Rails.application.secrets.aws_secret_access_key,
            region: Rails.application.secrets.aws_region)
