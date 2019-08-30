module Organization
  class Iuf < None
    def title
      "IUF"
    end

    def information_partial
      "/organization_memberships/details/iuf"
    end

    def automated_checking_class
      MembershipChecker::Iuf
    end

    def active_membership_required?
      true
    end

    def allow_manual_member_number_entry?
      false
    end

    def membership_site_url
      Rails.configuration.iuf_membership_url
    end
  end
end
