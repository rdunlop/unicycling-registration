# Production and the docker images install the official wkhtmltox package here.
# The binary bundled with the wkhtmltopdf-binary gem does not support every OS (e.g. Debian 13),
# so prefer the system one whenever it exists, and fall back to the gem's otherwise.
system_wkhtmltopdf = '/usr/local/bin/wkhtmltopdf'
if Rails.env.production? || Rails.env.stage? || File.executable?(system_wkhtmltopdf)
  WickedPdf.config = {
    exe_path: system_wkhtmltopdf,
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
