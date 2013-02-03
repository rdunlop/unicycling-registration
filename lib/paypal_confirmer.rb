require 'net/http'

class PaypalConfirmer

  def initialize(params, raw_post)
    @params = params
    @raw = raw_post
  end

  def valid?
    base_page_url = EventConfiguration.paypal_base_url
    uri = URI.parse(base_page_url + '/cgi-bin/webscr?cmd=_notify-validate')

    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 60
    http.read_timeout = 60
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl = true

    if Rails.env.test?
      true
    else
      response = http.post(uri.request_uri, @raw,
                           'Content-Length' => "#{@raw.size}",
                           'User-Agent' => "My custom user agent"
                          ).body

                          raise StandardError.new("Faulty paypal result: #{response}") unless ["VERIFIED", "INVALID"].include?(response)
                          raise StandardError.new("Invalid IPN: #{response}") unless response == "VERIFIED"

                          true
    end
  end

  def completed?
    @params["payment_status"] == "Completed"
  end

  def correct_paypal_account?
    @params["receiver_email"] == ENV["PAYPAL_ACCOUNT"].downcase
  end

  def transaction_id
    @params["txn_id"]
  end

  def payment_amount
    # Replace with mc_gross? (for non-USD currency payments?)
    @params["payment_gross"]
  end

  def order_number
    @params["invoice"]
  end
end
