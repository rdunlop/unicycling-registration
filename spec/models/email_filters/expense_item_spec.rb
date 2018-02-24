require 'spec_helper'

describe EmailFilters::ExpenseItem do
  describe "with a registrant who has paid for an item" do
    before do
      @reg = FactoryBot.create(:competitor)
      @ei = FactoryBot.create(:expense_item)
      paid_payment = FactoryBot.create(:payment, :completed)
      FactoryBot.create(:payment_detail, payment: paid_payment, registrant: @reg, line_item: @ei)
      @reg_not_paid_item = FactoryBot.create(:competitor)
      FactoryBot.create(:payment_detail, registrant: @reg_not_paid_item, line_item: @ei)
    end

    it "can create a list via the expense item id" do
      @filter = described_class.new(@ei.id)
      expect(@filter.filtered_user_emails).to match_array([@reg.user.email])
    end
  end
end
