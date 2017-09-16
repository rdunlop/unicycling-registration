class ImportedFileUploader < TenantUploader
  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{subdomain}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process :save_content_type_in_model

  def save_content_type_in_model
    model.content_type = file.content_type if file.content_type
  end
end
