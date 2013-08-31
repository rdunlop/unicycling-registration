require 'spec_helper'

describe RegistrantExpenseItem do
  before(:each) do
    @rei = FactoryGirl.create(:registrant_expense_item)
    @ei = @rei.expense_item
    @ei.cost = 20
    @ei.save
  end
  it "can be created by factory" do
    @rei.valid?.should == true
  end
  it "must have registrant" do
    @rei.registrant_id = nil
    @rei.valid?.should == false
  end
  it "must have expense_item" do
    @rei.expense_item_id = nil
    @rei.valid?.should == false
  end

  it "displays a cost_string" do
    @rei.cost_s.should == "$20.00 USD"
  end
  describe "when the item is free" do
    before(:each) do
      @rei.free = true
      @rei.save
    end

    it "displays the cost string as free" do
      @rei.cost_s.should == "Free"
    end

    it "has a cost of 0" do
      @rei.cost.should == 0
    end

    it "has 0 taxes" do
      @rei.tax.should == 0
    end
  end
  it "must associate with the registrant" do
    @reg = FactoryGirl.create(:registrant)
    @rei = FactoryGirl.create(:registrant_expense_item, :registrant => @reg)
    @rei.registrant.should == @reg
  end
  it "must associate with the expense_item" do
    @item = FactoryGirl.create(:expense_item)
    @rei = FactoryGirl.create(:registrant_expense_item, :expense_item => @item)
    @rei.expense_item.should == @item
  end

  describe "with an expense_item with a limited number available" do
    before(:each) do
      @ei = FactoryGirl.create(:expense_item, :maximum_available => 2)
    end

    it "allows creating a registrant expense_item" do
      @rei = FactoryGirl.build(:registrant_expense_item, :expense_item => @ei)
      @rei.valid?.should == true
    end

    it "allows creating the maximum amount" do
      @rei = FactoryGirl.build(:registrant_expense_item, :expense_item => @ei)
      @rei.valid?.should == true
      @rei.save!

      @rei2 = FactoryGirl.build(:registrant_expense_item, :expense_item => @ei)
      @rei2.valid?.should == true
      @rei2.save!
    end

    it "doesn't allow creating more than the maxiumum" do
      @rei = FactoryGirl.create(:registrant_expense_item, :expense_item => @ei)
      @rei2 = FactoryGirl.create(:registrant_expense_item, :expense_item => @ei)
      @ei.reload

      reg = @rei2.registrant
      reg.reload
      @rei3 = reg.registrant_expense_items.build({:expense_item_id => @ei.id})
      reg.valid?.should == false
    end
  end
end
