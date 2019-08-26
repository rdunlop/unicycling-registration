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
  end
end
