module Organization
  class Usa < None
    def title
      "USA"
    end

    def information_partial
      "/organization_memberships/details/usa"
    end

    def automated_checking_class
      MembershipChecker::Usa
    end

    def allow_manual_member_number_entry?
      true
    end

    def membership_site_url
      "https://unicyclingsocietyofamerica.wildapricot.org/join-us"
    end
  end
end
