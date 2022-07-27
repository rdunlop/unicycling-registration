require 'spec_helper'

describe EmailFilters::AllUserAllReg do
  describe "with one confirmed account, and one with unpaid registrant" do
    before do
      @reg_period = FactoryBot.create(:registration_cost)
      @reg = FactoryBot.create(:competitor)
      @user = FactoryBot.create(:user)
    end

    it "lists email addresses of all users when confirmed_accounts (with registrants) selected and all registrants" do
      @filter = described_class.new
      expect(@filter.filtered_user_emails).to match_array([@reg.user.email])
      expect(@filter.filtered_registrant_emails).to match_array([@reg.email])
    end
  end
end
