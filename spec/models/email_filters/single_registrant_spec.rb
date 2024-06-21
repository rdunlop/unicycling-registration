require 'spec_helper'

describe EmailFilters::SingleRegistrant do
  describe "myself" do
    before do
      @reg_1 = FactoryBot.create(:competitor)
      @reg_2 = FactoryBot.create(:competitor)
    end

    it "can create a list" do
      @filter = described_class.new(reg_1.id)
      expect(@filter.filtered_user_emails).to match_array([@reg_1.user.email])
      expect(@filter.filtered_registrant_emails).to match_array([@reg_1.email])
    end
  end
end
