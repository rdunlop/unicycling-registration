require 'spec_helper'

class Event
  include CostItem
end

describe "CostItem" do
  let(:model) { Event.new }
  let(:expense_item) { FactoryGirl.create(:expense_item) }

  it "Can be associated with an expense item" do
    expect(model.expense_item).to eq(nil)
    model.expense_item = expense_item
    expect(model.expense_item).to eq(expense_item)
  end

  describe "#has_cost?" do
    describe "when it does NOT have an associated expense_item" do
      it { expect(model.has_cost?).to be_falsey }
    end

    describe "when it has an associated expense_item" do
      before { model.expense_item = expense_item }
      it { expect(model.has_cost?).to be_truthy }
    end
  end
end
