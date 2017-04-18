require 'spec_helper'

describe RegistrationCostEntry do
  let(:registration_cost) { FactoryGirl.build(:registration_cost, :competitor) }
  let(:registration_cost_entry) { FactoryGirl.build(:registration_cost_entry, registration_cost: registration_cost) }

  it "is valid from FactoryGirl" do
    expect(registration_cost_entry.valid?).to eq(true)
  end

  it "must have an expense_item" do
    registration_cost_entry.expense_item = nil
    expect(registration_cost_entry).not_to be_valid
  end

  context "as a competitor type" do
    let(:registration_cost) { FactoryGirl.build(:registration_cost, :competitor) }

    it "can have ages" do
      registration_cost_entry.min_age = 10
      expect(registration_cost_entry).to be_valid
    end
  end

  context "as a noncompetitor type" do
    let(:registration_cost) { FactoryGirl.build(:registration_cost, :noncompetitor) }

    it "Cannot have ages" do
      registration_cost_entry.min_age = 10
      expect(registration_cost_entry).not_to be_valid
    end
  end

  describe "with associated expense_items" do
    it "removes the expense item on RegistrationCost deletion" do
      registration_cost_entry.save!
      expect do
        registration_cost_entry.destroy
      end.to change(ExpenseItem, :count).by(-1)
    end

    describe "when the expense_item has a payment" do
      before do
        registration_cost_entry.save!
        FactoryGirl.create :payment_detail, expense_item: registration_cost_entry.expense_item
      end

      it "can't remove the RegistrationCost on deletion" do
        expect { registration_cost_entry.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end
  end

  describe "#valid_for" do
    let(:min_age) { nil }
    let(:max_age) { nil }
    let(:registration_cost_entry) { FactoryGirl.build(:registration_cost_entry, min_age: min_age, max_age: max_age) }

    def do_action(age)
      registration_cost_entry.valid_for?(age)
    end

    context "when entry has no age" do
      it "is valid for any age" do
        expect(do_action(4)).to be_truthy
      end
    end

    context "when entry has a max age" do
      let(:max_age) { 10 }
      it "is valid below" do
        expect(do_action(5)).to be_truthy
      end

      it "is not valid above" do
        expect(do_action(15)).to be_falsey
      end
    end

    context "when entry has a min age" do
      let(:min_age) { 10 }
      it "is valid above" do
        expect(do_action(15)).to be_truthy
      end

      it "is not valid below" do
        expect(do_action(5)).to be_falsey
      end
    end

    context "when entry has a min and max age" do
      let(:min_age) { 10 }
      let(:max_age) { 40 }
      it "is valid between" do
        expect(do_action(15)).to be_truthy
      end

      it "is not valid outside" do
        expect(do_action(5)).to be_falsey
        expect(do_action(50)).to be_falsey
      end
    end
  end
end

# == Schema Information
#
# Table name: registration_cost_entries
#
#  id                   :integer          not null, primary key
#  registration_cost_id :integer          not null
#  expense_item_id      :integer          not null
#  min_age              :integer
#  max_age              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_registration_cost_entries_on_registration_cost_id  (registration_cost_id)
#
