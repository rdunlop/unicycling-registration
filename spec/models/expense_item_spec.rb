# == Schema Information
#
# Table name: expense_items
#
#  id                     :integer          not null, primary key
#  position               :integer
#  created_at             :datetime
#  updated_at             :datetime
#  expense_group_id       :integer
#  has_details            :boolean          default(FALSE), not null
#  maximum_available      :integer
#  has_custom_cost        :boolean          default(FALSE), not null
#  maximum_per_registrant :integer          default(0)
#  cost_cents             :integer
#  tax_cents              :integer          default(0), not null
#  cost_element_id        :integer
#  cost_element_type      :string
#
# Indexes
#
#  index_expense_items_expense_group_id                          (expense_group_id)
#  index_expense_items_on_cost_element_type_and_cost_element_id  (cost_element_type,cost_element_id) UNIQUE
#

require 'spec_helper'

describe ExpenseItem do
  before(:each) do
    @item = FactoryGirl.create(:expense_item)
  end

  it "can have the same position but in different expense_groups" do
    eg1 = FactoryGirl.create(:expense_group)
    eg2 = FactoryGirl.create(:expense_group)
    ei1 = FactoryGirl.create(:expense_item, expense_group: eg1)
    ei2 = FactoryGirl.create(:expense_item, expense_group: eg2)
    expect(ei1.position).to eq(ei2.position)
    expect(ei2.valid?).to eq(true)
  end

  it "must have tax" do
    @item.tax_cents = nil
    expect(@item.valid?).to eq(false)
  end

  it "can create from factory" do
    expect(@item.valid?).to eq(true)
  end

  describe "With a tax percent of 0" do
    it "has a tax of 0" do
      expect(@item.tax).to eq(0.to_money)
    end

    it "has a total_cost equal to the cost" do
      expect(@item.total_cost).to eq(@item.cost)
    end
  end

  describe "With a tax percentage of 5%" do
    before(:each) do
      @item.cost = 100
      @item.tax = 5
    end

    it "has a tax of $5" do
      expect(@item.tax).to eq(5.to_money)
    end

    it "has a total_cost of 5+100" do
      expect(@item.total_cost).to eq(105.to_money)
    end
  end

  describe "with a tax percentage of 5%" do
    it "has no fractional-penny results" do
      @item.cost = 17
      @item.tax = 0.94
      expect(@item.total_cost).to eq(17.94.to_money)
    end
  end

  it "must have a name" do
    @item.name = nil
    expect(@item.valid?).to eq(false)
  end
  it "by default has a normal cost" do
    expect(@item.has_custom_cost).to eq(false)
  end
  it "must have a cost" do
    @item.cost_cents = nil
    expect(@item.valid?).to eq(false)
  end
  it "must have a value for the has_details field" do
    @item.has_details = nil
    expect(@item.valid?).to eq(false)
  end
  it "should have a default of no details" do
    item = ExpenseItem.new
    expect(item.has_details).to eq(false)
  end

  it "should default to a tax of 0" do
    item = ExpenseItem.new
    expect(item.tax).to eq(0.to_money)
  end

  it "must have a tax >= 0" do
    @item.tax = -1
    expect(@item).to be_invalid
  end

  it "must have an expense group" do
    @item.expense_group = nil
    expect(@item.valid?).to eq(false)
  end

  it "should have a decent description" do
    expect(@item.to_s).to eq(@item.expense_group.to_s + " - " + @item.name)
  end

  describe "when an associated payment has been created" do
    before(:each) do
      @payment = FactoryGirl.create(:payment_detail, expense_item: @item)
      @item.reload
    end

    it "should not be able to destroy this item" do
      expect(ExpenseItem.all.count).to eq(1)
      expect { @item.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
      expect(ExpenseItem.all.count).to eq(1)
    end

    it "does not count this entry as a selected_item when the payment is incomplete" do
      expect(@payment.payment.completed).to eq(false)
      expect(@item.num_selected_items).to eq(0)
      expect(@item.num_paid).to eq(0)
      expect(@item.total_amount_paid).to eq(0.to_money)
    end

    it "counts this entry as a selected_item when the payment is complete" do
      pay = @payment.payment
      pay.completed = true
      pay.save!
      expect(@item.num_selected_items).to eq(1)
      expect(@item.num_paid).to eq(1)
      expect(@item.total_amount_paid).to eq(9.99.to_money)
    end
  end

  describe "with an expense_group set for 'noncompetitor_required'" do
    before(:each) do
      @rg = FactoryGirl.create(:expense_group, noncompetitor_required: true)
    end

    it "can have a first item" do
      @re = FactoryGirl.build(:expense_item, expense_group: @rg)
      expect(@re.valid?).to eq(true)
    end

    it "cannot have a second item" do
      @re = FactoryGirl.create(:expense_item, expense_group: @rg)
      @rg.reload
      @re2 = FactoryGirl.build(:expense_item, expense_group: @rg)
      expect(@re2.valid?).to eq(false)
    end
  end

  describe "with an expense_group set for registration_items" do
    before(:each) do
      @rg = FactoryGirl.create(:expense_group, :registration)
    end

    it "isn't user_manageable" do
      @re = FactoryGirl.create(:expense_item, expense_group: @rg)
      expect(ExpenseItem.user_manageable).to eq([@item])
      expect(ExpenseItem.all).to match_array([@re, @item])
    end
  end

  describe "with an expense_group set for 'competitor_required'" do
    before(:each) do
      @rg = FactoryGirl.create(:expense_group, competitor_required: true)
    end

    it "can have a first item" do
      @re = FactoryGirl.build(:expense_item, expense_group: @rg)
      expect(@re.valid?).to eq(true)
    end

    it "cannot have a second item" do
      @re = FactoryGirl.create(:expense_item, expense_group: @rg)
      @rg.reload
      @re2 = FactoryGirl.build(:expense_item, expense_group: @rg)
      expect(@re2.valid?).to eq(false)
    end
    describe "with a pre-existing registrant" do
      before(:each) do
        @reg = FactoryGirl.create(:competitor)
      end

      it "creates a registrant_expense_item" do
        expect(@reg.registrant_expense_items.count).to eq(0)
        @re = FactoryGirl.create(:expense_item, expense_group: @rg)
        @reg.reload
        expect(@reg.registrant_expense_items.count).to eq(1)
        expect(@reg.registrant_expense_items.first.expense_item).to eq(@re)
      end
      it "does not create extra entries if the expense_item is updated" do
        expect(@reg.registrant_expense_items.count).to eq(0)
        @re = FactoryGirl.create(:expense_item, expense_group: @rg)
        @re.save
        @reg.reload
        expect(@reg.registrant_expense_items.count).to eq(1)
        expect(@reg.registrant_expense_items.first.expense_item).to eq(@re)
      end
    end
  end

  describe "with associated registrant_expense_items" do
    before(:each) do
      @rei = FactoryGirl.create(:registrant_expense_item, expense_item: @item)
    end

    it "should count the entry as a selected_item" do
      expect(@item.num_selected_items).to eq(1)
      expect(@item.num_unpaid).to eq(1)
    end

    describe "when the registrant is deleted" do
      before(:each) do
        reg = @rei.registrant
        reg.deleted = true
        reg.save!
      end

      it "should not count the expense_item as num_unpaid" do
        expect(@item.num_unpaid).to eq(0)
      end
    end

    describe "when the registrant is not completed filling out their registration form" do
      before(:each) do
        reg = @rei.registrant
        reg.status = "events"
        reg.save!
      end

      it "should not count the expense_item as num_unpaid" do
        expect(@item.num_unpaid).to eq(0)
      end

      it "should count the expense_item as num_unpaid when option is selected" do
        expect(@item.num_unpaid(include_incomplete_registrants: true)).to eq(1)
      end
    end
  end

  describe "when associated with an event" do
    let(:event) { FactoryGirl.create(:event, name: "The Event") }
    let(:expense_item) { FactoryGirl.create(:expense_item, cost_element: event) }

    it "describes the name of the expense_item based on the name of the event" do
      expect(expense_item.to_s).to eq("The Event")
    end
  end

  describe "when a registration has a registration_cost" do
    before(:each) do
      @comp_reg_cost = FactoryGirl.create(:registration_cost, :competitor, expense_item: @item)
      @noncomp_reg_cost = FactoryGirl.create(:registration_cost, :noncompetitor)
      @nc_item = @noncomp_reg_cost.expense_item
    end
    describe "with a single competitor" do
      before(:each) do
        @reg = FactoryGirl.create(:competitor)
      end
      it "should list the item as un_paid" do
        expect(@item.num_unpaid).to eq(1)
        expect(@nc_item.num_unpaid).to eq(0)
      end
    end
    describe "with a single non_competitor" do
      before(:each) do
        @nc_reg = FactoryGirl.create(:noncompetitor)
      end

      it "counts the nc item only" do
        expect(@nc_item.num_unpaid).to eq(1)
        expect(@item.num_unpaid).to eq(0)
      end
    end
  end
end
