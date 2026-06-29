# checks the Unicycling Society Of America (USA)
# WildApricot membership database
#
# When USA mode is enabled, we query the USA database through the wildapricot
# API to determine if the registrant is a member as of the competition-start-date
#
module MembershipChecker
  class Usa
    attr_reader :first_name, :last_name, :birthdate
    attr_reader :manual_member_number, :wildapricot_member_number

    def initialize(first_name:, last_name:, birthdate:, manual_member_number:, system_member_number:)
      @first_name = first_name
      @last_name = last_name
      @birthdate = birthdate
      @manual_member_number = manual_member_number
      @wildapricot_member_number = system_member_number
    end

    def current_member?
      return false if contacts.count.zero?

      active_matched_contact.present?
    end

    # When a match is found, store the WildApricot ID found as the "system_member_number"
    def current_system_id
      matched_contact = active_matched_contact

      return nil unless matched_contact

      matched_contact["Id"] # This is the wildapricot ID
    end

    private

    def contacts
      return [] if Rails.env.test?

      # If a system_member_number is specified, search ONLY by that
      if wildapricot_member_number.present?
        search_contacts(filter_by_wildapricot_id)
      else
        # If system_member_number not is specified, Search by fname/lname/bday
        result = search_contacts(filter_by_name_bday)
        if result.none?
          # Then search for usa via manual_member_number (if specified)
          result = search_contacts(filter_by_old_usa_membership_id)
        end
        if result.none?
          # Search as if the manual_member_number is a wildapricot ID
          result = search_contacts(filter_by_manual_id_as_wildapricot_id)
        end

        result
      end
    end

    def active_matched_contact
      @active_matched_contact ||= contacts.detect do |contact|
        contact_is_member?(contact)
      end
    end

    def search_contacts(filter_string)
      uri = URI("https://api.wildapricot.org/v2.1/accounts/#{account_id}/contacts")
      uri.query = URI.encode_www_form("$async" => "false", "$top" => "10", "$filter" => filter_string)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{token}"
        http.request(request)
      end

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)["Contacts"]
      else
        []
      end
    end

    def filter_by_name_bday
      basic_filter = "'FirstName' eq '#{first_name}' " \
                     " and 'LastName' eq '#{last_name}' "
      if birthdate.present?
        # allow for spectator, which has no birthday.
        basic_filter + " and 'Birth Date' eq '#{birthdate.strftime('%Y-%m-%d')}'"
      else
        basic_filter
      end
    end

    def filter_by_old_usa_membership_id
      "'Old Member ID' eq '#{manual_member_number}'" \
      " and 'LastName' eq '#{last_name}'"
    end

    def filter_by_manual_id_as_wildapricot_id
      "'ID' eq '#{manual_member_number}' " \
      " and 'LastName' eq '#{last_name}'"
    end

    def filter_by_wildapricot_id
      "'ID' eq '#{wildapricot_member_number}'"
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
      renewal_field = contact_hash["FieldValues"].detect { |field| field["FieldName"] == "Renewal due" }
      return false unless renewal_field

      Date.parse(renewal_field["Value"]) < Date.current + 5.months
    end

    def token
      return @token if @token

      uri = URI("https://oauth.wildapricot.org/auth/token")
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/x-www-form-urlencoded"
        request["Authorization"] = basic_auth
        request.body = "grant_type=client_credentials&scope=auto"
        http.request(request)
      end

      if response.is_a?(Net::HTTPSuccess)
        @token = JSON.parse(response.body)["access_token"]
      else
        raise "Unable to authorize with WildApricot"
      end
    end

    def basic_auth
      "Basic #{Base64.strict_encode64("APIKEY:#{api_key}")}"
    end

    def account_id
      Rails.configuration.usa_wildapricot_account_id
    end

    def api_key
      Rails.configuration.usa_wildapricot_api_key
    end
  end
end
