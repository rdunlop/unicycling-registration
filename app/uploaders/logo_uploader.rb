# encoding: utf-8

class LogoUploader < TenantUploader
  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog
  include CarrierWaveDirect::Uploader

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{subdomain}/uploads/logo"
  end
end
