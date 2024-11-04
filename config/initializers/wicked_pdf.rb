if Rails.env.production? || Rails.env.stage?
  WickedPdf.config = {
    exe_path: '/usr/local/bin/wkhtmltopdf',
    enable_local_file_access: true
  }
end

class WickedPdf
  class Binary
    def retrieve_binary_version
      stdin, stdout, stderr = Open3.popen3(@path + ' -V') # rubocop:disable Style/StringConcatenation
      # must close these, or else this command hangs
      stdin.close
      stderr.close
      parse_version_string(stdout.gets(nil))
    rescue StandardError
      default_version
    end
  end
end
