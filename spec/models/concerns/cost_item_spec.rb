require 'spec_helper'

class Event
  include CostItem
end

describe "CostItem" do
  let(:model) { Event.new }
  let(:expense_item) { FactoryBot.create(:expense_item) }

  it "Can be associated with an expense item" do
    expect(model.expense_item).to eq(nil)
    model.expense_item = expense_item
    expect(model.expense_item).to eq(expense_item)
  end

  describe "#has_cost?" do
    describe "when it does NOT have an associated expense_item" do
      it { expect(model).not_to have_cost }
    end

    describe "when it has an associated expense_item" do
      before { model.expense_item = expense_item }

      it { expect(model).to have_cost }
    end
  end
end
