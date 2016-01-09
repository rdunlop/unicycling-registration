require 'spec_helper'

describe CreatesRegistrationCost do
  let(:comp_expense_item) { ExpenseItem.new cost: 100, tax: 0 }
  let(:reg_period) { FactoryGirl.build :registration_cost, expense_item: comp_expense_item }

  def perform
    described_class.new(reg_period).perform
  end

  describe "when no expense_group exists" do
    it "creates a expense_group" do
      expect { perform }.to change(ExpenseGroup, :count).by(1)
    end

    it "creates a non-visible expense_group" do
      perform
      expect(ExpenseGroup.last).not_to be_visible
    end
  end

  describe "when an expense_group exists" do
    before do
      FactoryGirl.create :expense_group, :registration
    end

    it "doesn't create another expense_group" do
      expect { perform }.not_to change(ExpenseGroup, :count)
    end

    it "creates two new expense items" do
      expect { perform }.to change(ExpenseItem, :count).by(1)
    end
  end
end
