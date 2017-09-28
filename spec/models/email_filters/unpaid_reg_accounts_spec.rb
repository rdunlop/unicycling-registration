require 'spec_helper'

describe EmailFilters::UnpaidRegAccounts do
  describe "with one confirmed account, and one with unpaid registrant" do
    before(:each) do
      @reg_period = FactoryGirl.create(:registration_cost)
      @reg = FactoryGirl.create(:competitor)
      @user = FactoryGirl.create(:user)
    end

    it "lists email addresses only of the user with unpaid registrants" do
      @filter = described_class.new
      expect(@filter.filtered_user_emails).to match_array([@reg.user.email])
    end

    it "doesn't list the user twice if they have 2 registrants to pay for" do
      @reg2 = FactoryGirl.create(:competitor, user: @reg.user)
      @filter = described_class.new
      expect(@filter.filtered_user_emails).to match_array([@reg.user.email])
    end
  end
end
