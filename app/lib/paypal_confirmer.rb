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

    unless Rails.env.test?
      response = http.post(uri.request_uri, @raw,
                           'Content-Length' => @raw.size.to_s,
                           'User-Agent' => "My custom user agent"
                          ).body

      raise StandardError.new("Faulty paypal result: #{response}") unless ["VERIFIED", "INVALID"].include?(response)
      raise StandardError.new("Invalid IPN: #{response}") unless response == "VERIFIED"
    end

    true
  end

  def completed?
    @params["payment_status"] == "Completed"
  end

  def correct_paypal_account?
    @params["receiver_email"] == EventConfiguration.singleton.paypal_account.downcase
  end

  def transaction_id
    @params["txn_id"]
  end

  def payment_amount
    # (for non-USD currency payments)
    @params["mc_gross"].to_f
  end

  def order_number
    return "No Invoice number" if @params["invoice"].nil?
    @params["invoice"]
  end

  def payment_date
    @params["payment_date"]
  end
end
