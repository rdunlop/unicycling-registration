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

  describe "with a registrant signed up for an event" do
    before do
      @reg = FactoryGirl.create(:competitor)
      resu = FactoryGirl.create(:registrant_event_sign_up, registrant: @reg)
      @reg_not_signed_up = FactoryGirl.create(:competitor)
      @event = resu.event
    end

    it "can create a list via the event id" do
      @email.event_id = @event.id
      expect(@email.filtered_user_emails).to match_array([@reg.user.email])
    end
  end

  describe "with a registrant who has paid for an item" do
    before do
      @reg = FactoryGirl.create(:competitor)
      @ei = FactoryGirl.create(:expense_item)
      paid_payment = FactoryGirl.create(:payment, :completed)
      FactoryGirl.create(:payment_detail, payment: paid_payment, registrant: @reg, expense_item: @ei)
      @reg_not_paid_item = FactoryGirl.create(:competitor)
      FactoryGirl.create(:payment_detail, registrant: @reg_not_paid_item, expense_item: @ei)
    end

    it "can create a list via the expense item id" do
      @email.expense_item_id = @ei.id
      expect(@email.filtered_user_emails).to match_array([@reg.user.email])
    end
  end
end
