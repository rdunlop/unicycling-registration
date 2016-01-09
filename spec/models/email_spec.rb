require 'spec_helper'

describe Email do
  before(:each) do
    @email = FactoryGirl.build(:email)
  end
  it "is initially valid" do
    expect(@email.valid?).to eq(true)
  end
  it "must have a subject" do
    @email.subject = nil
    expect(@email.valid?).to eq(false)
  end
  describe "with one confirmed account, and one with unpaid registrant" do
    before(:each) do
      @reg_period = FactoryGirl.create(:registration_cost)
      @reg = FactoryGirl.create(:competitor)
      @user = FactoryGirl.create(:user)
    end

    it "lists email addresses of all users when confirmed_accounts selected" do
      @email.confirmed_accounts = true
      expect(@email.filtered_user_emails).to match_array([@reg.user.email, @user.email])
    end

    it "lists email addresses only of the user with unpaid registrants" do
      @email.unpaid_reg_accounts = true
      expect(@email.filtered_user_emails).to match_array([@reg.user.email])
    end

    it "doesn't list the user twice if they have 2 registrants to pay for" do
      @reg2 = FactoryGirl.create(:competitor, user: @reg.user)
      @email.unpaid_reg_accounts = true
      expect(@email.filtered_user_emails).to match_array([@reg.user.email])
    end
  end
end
