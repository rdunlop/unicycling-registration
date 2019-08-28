module Organization
  class Usa < None
    def title
      "USA"
    end

    def information_partial
      "usa"
    end

    def automated_checking_class
      MembershipChecker::Usa
    end

    def allow_manual_member_number_entry?
      true
    end
  end
end
