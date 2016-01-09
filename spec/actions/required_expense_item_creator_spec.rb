require 'spec_helper'

describe RequiredExpenseItemCreator do
  before(:each) do
    @reg = FactoryGirl.create(:competitor)
  end

  describe "with a registration_cost" do
    before(:each) do
      @comp_exp = FactoryGirl.create(:expense_item, cost: 100)
      @noncomp_exp = FactoryGirl.create(:expense_item, cost: 50)
      @comp_reg_cost = FactoryGirl.create(:registration_cost, :competitor,
                                          start_date: Date.new(2010, 01, 01), end_date: Date.new(2022, 01, 01),
                                          expense_item: @comp_exp)
      @noncomp_reg_cost = FactoryGirl.create(:registration_cost, :noncompetitor,
                                             start_date: Date.new(2010, 01, 01), end_date: Date.new(2022, 01, 01),
                                             expense_item: @noncomp_exp)
    end

    describe "as a non-Competitor" do
      before(:each) do
        @noncomp = FactoryGirl.build_stubbed(:noncompetitor)
        @noncomp.create_associated_required_expense_items
      end
      it "should owe different cost" do
        expect(@noncomp.amount_owing).to eq(50)
      end
      it "retrieves the non-comp registration_item" do
        expect(@noncomp.registrant_expense_items.first.expense_item).to eq(@noncomp_exp)
      end
      it "lists the item as an owing_expense_item" do
        expect(@noncomp.owing_expense_items).to eq([@noncomp_exp])
      end
    end

    describe "as a Competitor" do
      before(:each) do
        @comp = FactoryGirl.create(:competitor)
      end
      it "retrieves the comp registration_item" do
        expect(@comp.registrant_expense_items.first.expense_item).to eq(@comp_exp)
      end
      it "lists the item as an owing_expense_item" do
        expect(@comp.owing_registrant_expense_items.first.expense_item).to eq(@comp_exp)
      end
    end

    describe "as a spectator" do
      let(:spectator) { FactoryGirl.create(:spectator) }

      specify { expect(spectator.registrant_expense_items.count).to eq(0) }
      specify { expect(spectator.owing_registrant_expense_items.count).to eq(0) }
    end
  end

  describe "with an expense_group marked as 'required' created BEFORE the registrant" do
    before(:each) do
      @eg = FactoryGirl.create(:expense_group, competitor_required: true)
      @ei = FactoryGirl.create(:expense_item, expense_group: @eg)
      @reg2 = FactoryGirl.create(:competitor)
    end

    it "should include this expense_item in the list of owing_registrant_expense_items" do
      expect(@reg2.owing_registrant_expense_items.last.expense_item).to eq(@ei)
      expect(@reg2.owing_registrant_expense_items.last.system_managed).to eq(true)
    end
  end
end
