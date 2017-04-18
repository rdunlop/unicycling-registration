# == Schema Information
#
# Table name: registration_costs
#
#  id              :integer          not null, primary key
#  start_date      :date
#  end_date        :date
#  registrant_type :string           not null
#  onsite          :boolean          default(FALSE), not null
#  current_period  :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_registration_costs_on_current_period                      (current_period)
#  index_registration_costs_on_registrant_type_and_current_period  (registrant_type,current_period)
#

require 'spec_helper'

describe RegistrationCost do
  let(:registration_cost) { FactoryGirl.build(:registration_cost, :competitor, start_date: Date.new(2012, 11, 3), end_date: Date.new(2012, 11, 7)) }

  it "is valid from FactoryGirl" do
    expect(registration_cost.valid?).to eq(true)
  end

  it "must have a start date" do
    registration_cost.start_date = nil
    expect(registration_cost.valid?).to eq(false)
  end

  it "must have an end date" do
    registration_cost.end_date = nil
    expect(registration_cost.valid?).to eq(false)
  end

  it "must have onsite set" do
    registration_cost.onsite = nil
    expect(registration_cost.valid?).to eq(false)
  end

  it "is not onsite by default" do
    rp = RegistrationCost.new
    expect(rp.onsite).to eq(false)
  end

  it "can determine the last online registration period" do
    registration_cost.save!
    expect(RegistrationCost.last_online_period).to eq(registration_cost)
  end

  describe "with associated expense_items" do
    it "removes the expense item on RegistrationCost deletion" do
      registration_cost.save!
      expect do
        registration_cost.destroy
      end.to change(ExpenseItem, :count).by(-1)
    end

    describe "when the expense_item has a payment" do
      before do
        registration_cost.save!
        FactoryGirl.create :payment_detail, expense_item: registration_cost.expense_items.first
      end

      it "can't remove the RegistrationCost on deletion" do
        expect { registration_cost.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end
  end

  describe "with existing periods" do
    let!(:comp_registration_cost1) { FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2012, 1, 1), end_date: Date.new(2012, 2, 2)) }
    let!(:noncomp_registration_cost1) { FactoryGirl.create(:registration_cost, :noncompetitor, start_date: Date.new(2012, 1, 1), end_date: Date.new(2012, 2, 2)) }
    let!(:comp_registration_cost2) { FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2012, 02, 3), end_date: Date.new(2012, 4, 4)) }
    let!(:noncomp_registration_cost2) { FactoryGirl.create(:registration_cost, :noncompetitor, start_date: Date.new(2012, 2, 3), end_date: Date.new(2012, 4, 4)) }

    it "can retrieve only the competitor periods" do
      expect(RegistrationCost.for_type("competitor")).to match_array([comp_registration_cost1, comp_registration_cost2])
    end

    it "can retrieve only the noncompetitor periods" do
      expect(RegistrationCost.for_type("noncompetitor")).to match_array([noncomp_registration_cost1, noncomp_registration_cost2])
    end

    it "can retrieve the expense items for only a set of the registration_costs" do
      expect(RegistrationCost.for_type("competitor").all_registration_expense_items).to match_array([
                                                                                                      comp_registration_cost1.expense_items.first,
                                                                                                      comp_registration_cost2.expense_items.first
                                                                                                    ])
      expect(RegistrationCost.for_type("noncompetitor").all_registration_expense_items).to match_array([
                                                                                                         noncomp_registration_cost1.expense_items.first,
                                                                                                         noncomp_registration_cost2.expense_items.first
                                                                                                       ])
    end

    it "can retrieve period" do
      expect(RegistrationCost.relevant_period("competitor", Date.new(2012, 1, 15))).to eq(comp_registration_cost1)
    end

    it "gets nil for missing section" do
      expect(RegistrationCost.relevant_period("competitor", Date.new(2010, 1, 1))).to be_nil
    end

    it "returns the first registration period INCLUDING the day AFTER the period ends" do
      expect(RegistrationCost.relevant_period("competitor", Date.new(2012, 2, 3))).to eq(comp_registration_cost1)
    end

    it "returns the second registration period +2 days after the first period ends" do
      expect(RegistrationCost.relevant_period("competitor", Date.new(2012, 2, 4))).to eq(comp_registration_cost2)
    end

    it "disregards onsite registration periods for last_online_period" do
      registration_cost.onsite = true
      registration_cost.save!
      expect(RegistrationCost.for_type("competitor").last_online_period).to eq(comp_registration_cost2)
    end
    describe "with more registration periods" do
      let!(:comp_registration_cost0) { FactoryGirl.create(:registration_cost, :competitor, start_date: Date.new(2010, 2, 3), end_date: Date.new(2010, 4, 4)) }

      it "returns the periods in ascending date order" do
        registration_cost.save!
        expect(RegistrationCost.for_type("competitor").all).to eq([comp_registration_cost0, comp_registration_cost1, comp_registration_cost2, registration_cost])
      end
    end

    it "can identify the current period" do
      expect(comp_registration_cost1.current_period?(Date.new(2012, 1, 14))).to eq(true)
      expect(comp_registration_cost2.current_period?(Date.new(2012, 1, 14))).to eq(false)
      expect(noncomp_registration_cost1.current_period?(Date.new(2012, 1, 14))).to eq(true)
      expect(noncomp_registration_cost2.current_period?(Date.new(2012, 1, 14))).to eq(false)
    end
    it "can identify past periods" do
      expect(comp_registration_cost1.past_period?(Date.new(2012, 2, 20))).to eq(true)
      expect(comp_registration_cost2.past_period?(Date.new(2012, 2, 20))).to eq(false)
      expect(noncomp_registration_cost1.past_period?(Date.new(2012, 2, 20))).to eq(true)
      expect(noncomp_registration_cost2.past_period?(Date.new(2012, 2, 20))).to eq(false)
    end
  end
end
