# Be sure to restart your server when you modify this file.
# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# importmap-rails adds app/javascript to Sprockets' asset *paths* (so files can be
# found) but does not add individual files to the precompile list. Without this,
# Stimulus controllers 404 in production/staging where config.assets.compile = false.
Rails.application.config.assets.precompile += Dir.glob("app/javascript/controllers/**/*.js").map { |f| f.sub("app/javascript/", "") }
