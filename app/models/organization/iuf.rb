module Organization
  class Iuf < None
    def title
      "IUF"
    end

    def information_partial
      "iuf"
    end

    def automated_checking_class
      MembershipChecker::Iuf
    end
  end
end
