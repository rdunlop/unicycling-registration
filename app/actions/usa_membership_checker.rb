# checks the Unicycling Society Of America (USA)
# WildApricot membership database
class UsaMembershipChecker

  attr_reader :first_name, :last_name, :birthdate

  def initialize(first_name, last_name, birthdate)
    @first_name = first_name
    @last_name = last_name
    @birthdate = birthdate
  end

  def current_member?
    return false if contacts.count.zero?

    contacts.any? do |contact|
      contact_is_member?(contact)
    end
  end

  def contacts
    conn = Faraday.new(url: "https://api.wildapricot.org") do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end

    response = conn.get do |req|
      req.headers["authorization"] = "Bearer #{token}"
      req.url("/v2.1/accounts/#{account_id}/contacts")
      req.params["$async"] = "false"
      req.params["$top"] = "10"
      req.params["$filter"] = filter_string
    end

    if response.success?
      JSON.parse(response.body)["Contacts"]
    else
      raise "Unable to fetch from wildapricot"
    end
  end

  def filter_string
    "'FirstName' eq '#{first_name}' " \
    " and 'LastName' eq '#{last_name}' " \
    " and 'Birth Date' eq '#{birthdate.strftime("%Y-%m-%d")}'"
  end

  def contact_is_member?(contact_hash)
    contact_hash["MembershipEnabled"] &&
    contact_hash["Status"] == "Active" &&
    !suspended?(contact_hash)
  end

  def suspended?(contact_hash)
    suspended_element = contact_hash["FieldValues"].detect do |field|
      field["FieldName"] == "Suspended member"
    end

    suspended_element["Value"]
  end

  # Unused method
  def renewing?(contact_hash)
    renewal_field = contact_hash["FieldValues"].detect{|field| field["FieldName"] == "Renewal due"}
    return false unless renewal_field

    Date.parse(renewal_field["Value"]) < Date.current + 5.months
  end

  private

  def token
    return @token if @token

    conn = Faraday.new(url: "https://oauth.wildapricot.org") do |faraday|
      faraday.request :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
    response = conn.post do |req|
      req.url("/auth/token")
      req.headers["Content-type"] = "Application/x-www-form-urlencoded"
      req.headers["Authorization"] = basic_auth
      req.body = "grant_type=client_credentials&scope=auto"
    end

    if response.success?
      @token = JSON.parse(response.body)["access_token"]
    else
      raise "Unable to authorize with WildApricot"
    end
  end

  def basic_auth
    "Basic #{Base64.encode64("APIKEY:#{api_key}")}"
  end

  def account_id
    Rails.application.secrets.usa_wildapricot_account_id
  end

  def api_key
    Rails.application.secrets.usa_wildapricot_apikey
  end
end
