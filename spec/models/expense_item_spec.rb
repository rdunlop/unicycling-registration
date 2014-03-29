# == Schema Information
#
# Table name: expense_items
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  description            :string(255)
#  cost                   :decimal(, )
#  export_name            :string(255)
#  position               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  expense_group_id       :integer
#  has_details            :boolean
#  details_label          :string(255)
#  maximum_available      :integer
#  tax_percentage         :decimal(5, 3)    default(0.0)
#  has_custom_cost        :boolean          default(FALSE)
#  maximum_per_registrant :integer          default(0)
#

require 'spec_helper'

describe ExpenseItem do
  before(:each) do
    @item = FactoryGirl.create(:expense_item)
  end

  it "must have a tax_percentage" do
    @item.tax_percentage = nil
    @item.valid?.should == false
  end

  it "can create from factory" do
    @item.valid?.should == true
  end

  describe "With a tax percent of 0" do
    it "has a tax of 0" do
      @item.tax.should == 0
    end

    it "has a total_cost equal to the cost" do
      @item.total_cost.should == @item.cost
    end
  end

  describe "With a tax percentage of 5%" do
    before(:each) do
      @item.cost = 100
      @item.tax_percentage = 5
    end

    it "has a tax of 5$" do
      @item.tax.should == 5
    end

    it "has a total_cost of 5+100" do
      @item.total_cost.should == 105
    end

    describe "with a fractional tax_percentage" do
      before(:each) do
        @item.tax_percentage = 14.975
      end
      it "rounds up the taxes to the next penny" do
        @item.tax.should == 14.98
      end
      it "rounds up to the next penny even for small fractions" do
        @item.tax_percentage = 14.001
        @item.tax.should == 14.01
      end
    end
  end

  it "must have a name" do
    @item.name = nil
    @item.valid?.should == false
  end
  it "by default has a normal cost" do
    @item.has_custom_cost.should == false
  end
  it "must have a description" do
    @item.description = nil
    @item.valid?.should == false
  end
  it "must have a position" do
    @item.position = nil
    @item.valid?.should == false
  end
  it "must have a cost" do
    @item.cost = nil
    @item.valid?.should == false
  end
  it "must have a value for the has_details field" do
    @item.has_details = nil
    @item.valid?.should == false
  end
  it "should have a default of no details" do
    item = ExpenseItem.new
    item.has_details.should == false
  end

  it "should default to a tax_percentage of 0" do
    item = ExpenseItem.new
    item.tax_percentage.should == 0
  end

  it "must have a tax percentage >= 0" do
    @item.tax_percentage = -1
    @item.valid?.should == false
  end

  it "must have an expense group" do
    @item.expense_group = nil
    @item.valid?.should == false
  end

  it "should have a decent description" do
    @item.to_s.should == @item.expense_group.to_s + " - " + @item.name
  end

  describe "when an associated payment has been created" do
    before(:each) do
      @payment = FactoryGirl.create(:payment_detail, :expense_item => @item)
      @item.reload
    end

    it "should not be able to destroy this item" do
      ExpenseItem.all.count.should == 1
      @item.destroy
      ExpenseItem.all.count.should == 1
    end

    it "does not count this entry as a selected_item when the payment is incomplete" do
      @payment.payment.completed.should == false
      @item.num_selected_items.should == 0
      @item.num_paid.should == 0
    end

    it "counts this entry as a selected_item when the payment is complete" do
      pay = @payment.payment
      pay.completed = true
      pay.save!
      @item.num_selected_items.should == 1
      @item.num_paid.should == 1
    end
  end

  describe "with an expense_group set for 'noncompetitor_required'" do
    before(:each) do
      @rg = FactoryGirl.create(:expense_group, :noncompetitor_required => true)
    end

    it "can have a first item" do
      @re = FactoryGirl.build(:expense_item, :expense_group => @rg)
      @re.valid?.should == true
    end 

    it "cannot have a second item" do
      @re = FactoryGirl.create(:expense_item, :expense_group => @rg)
      @rg.reload
      @re2 = FactoryGirl.build(:expense_item, :expense_group => @rg)
      @re2.valid?.should == false
    end
  end

  describe "with an expense_group set for 'competitor_required'" do
    before(:each) do
      @rg = FactoryGirl.create(:expense_group, :competitor_required => true)
    end

    it "can have a first item" do
      @re = FactoryGirl.build(:expense_item, :expense_group => @rg)
      @re.valid?.should == true
    end 

    it "cannot have a second item" do
      @re = FactoryGirl.create(:expense_item, :expense_group => @rg)
      @rg.reload
      @re2 = FactoryGirl.build(:expense_item, :expense_group => @rg)
      @re2.valid?.should == false
    end 
    describe "with a pre-existing registrant" do
      before(:each) do
        @reg = FactoryGirl.create(:competitor)
      end

      it "creates a registrant_expense_item" do
        @reg.registrant_expense_items.count.should == 0
        @re = FactoryGirl.create(:expense_item, :expense_group => @rg)
        @reg.reload
        @reg.registrant_expense_items.count.should == 1
        @reg.registrant_expense_items.first.expense_item.should == @re
      end
      it "does not create extra entries if the expense_item is updated" do
        @reg.registrant_expense_items.count.should == 0
        @re = FactoryGirl.create(:expense_item, :expense_group => @rg)
        @re.save
        @reg.reload
        @reg.registrant_expense_items.count.should == 1
        @reg.registrant_expense_items.first.expense_item.should == @re
      end
    end
  end

  describe "with associated registrant_expense_items" do
    before(:each) do
      @rei = FactoryGirl.create(:registrant_expense_item, :expense_item => @item)
    end

    it "should count the entry as a selected_item" do
      @item.num_selected_items.should == 1
      @item.num_unpaid.should == 1
    end

    describe "when the registrant is deleted" do
      before(:each) do
        reg = @rei.registrant
        reg.deleted = true
        reg.save
      end

      it "should not count the expense_item as num_unpaid" do
        @item.num_unpaid.should == 0
      end
    end
  end

  describe "when a registration has a registration_period" do
    before(:each) do
      @rp = FactoryGirl.create(:registration_period, :competitor_expense_item => @item)
      @nc_item = @rp.noncompetitor_expense_item
    end
    describe "with a single competitor" do
      before(:each) do
        @reg = FactoryGirl.create(:competitor)
      end
      it "should list the item as un_paid" do
        @item.num_unpaid.should == 1
        @nc_item.num_unpaid.should == 0
      end
    end
    describe "with a single non_competitor" do
      before(:each) do
        @nc_reg = FactoryGirl.create(:noncompetitor)
      end

      it "counts the nc item only" do
        @nc_item.num_unpaid.should == 1
        @item.num_unpaid.should == 0
      end
    end
  end
end
