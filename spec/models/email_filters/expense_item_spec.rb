require 'spec_helper'

describe EmailFilters::ExpenseItem do
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
      @filter = described_class.new(@ei.id)
      expect(@filter.filtered_user_emails).to match_array([@reg.user.email])
    end
  end
end
