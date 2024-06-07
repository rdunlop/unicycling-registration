require 'spec_helper'

describe EmailFilters::Country do
  describe "with a registrant in usa" do
    before do
      @reg_usa = FactoryBot.create(:competitor)
      @reg_not_usa = FactoryBot.create(:competitor, contact_detail: FactoryBot.create(:contact_detail, :german))
    end

    it "can create a list via the event id" do
      @filter = described_class.new("US")
      expect(@filter.filtered_user_emails).to match_array([@reg_usa.user.email])
    end
  end
end
