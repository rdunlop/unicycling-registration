Rails.application.configure do
  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.

  # Additional assets to precompile
  config.assets.precompile += %w( pdf.css dev.css naucc_2013.css naucc_2014.css naucc_2015.css unicon_17.css )
end
