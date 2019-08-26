# checks the International Unicycling Federation (IUF)
# membership database
#
# When IUF mode is enabled, we query the IUF database through an API
# to determine if the registrant is a member
#
module MembershipChecker
  class Iuf
    attr_reader :first_name, :last_name, :birthdate
    attr_reader :manual_member_number, :iuf_member_number

    def initialize(first_name:, last_name:, birthdate:, manual_member_number:, system_member_number:)
      @first_name = first_name
      @last_name = last_name
      @birthdate = birthdate
      @manual_member_number = manual_member_number
      @iuf_member_number = system_member_number
    end

    def current_member?
      false
    end

    # When a match is found, store the IUF ID found as the "system_member_number"
    def current_system_id
      nil
    end

    private

    def api_url
      Rails.configuration.iuf_membership_api_url
    end
  end
end
