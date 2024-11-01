if Rails.env.production? || Rails.env.stage?
  WickedPdf.config = {
    exe_path: '/usr/local/bin/wkhtmltopdf',
    enable_local_file_access: true
  }
end
