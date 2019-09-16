module Organization
  # This is the default organization, when no organization is selected
  class None
    def title
      "None"
    end

    def information_partial; end

    def automated_checking?
      automated_checking_class.present?
    end

    def automated_checking_class; end

    def active_membership_required?
      false
    end

    def allow_manual_member_number_entry?
      false
    end

    def membership_site_url; end
  end
end
