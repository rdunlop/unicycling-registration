require 'spec_helper'

describe CreatesRegistrationCost do
  let(:comp_expense_item) { ExpenseItem.new cost: 100, tax: 0 }
  let(:rce) { RegistrationCostEntry.new(expense_item: comp_expense_item) }
  let(:reg_period) { FactoryBot.build :registration_cost, :without_entries, registration_cost_entries: [rce] }

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
      FactoryBot.create :expense_group, :registration
    end

    it "doesn't create another expense_group" do
      expect { perform }.not_to change(ExpenseGroup, :count)
    end

    it "creates one new expense items" do
      expect { perform }.to change(ExpenseItem, :count).by(1)
    end
  end

  describe "when registration_cost is saved and is being updated" do
    before { perform }

    it "updates the name of the expense_item" do
      existing_rce = reg_period.registration_cost_entries.first
      existing_rce.min_age = 10
      perform
      expect(comp_expense_item.reload.name).to eq("competitor - #{reg_period.name} (Ages 10+)")
    end
  end
end
