require 'spec_helper'

describe ExpenseGroup do
  before(:each) do
    @group = FactoryGirl.create(:expense_group)
  end
  it "can be created by the factory" do
    @group.valid?.should == true
  end
  it "must have a name" do
    @group.group_name = nil
    @group.valid?.should == false
  end
  it "must have a visible setting of true or false" do
    @group.visible = nil
    @group.valid?.should == false

    @group.visible = true
    @group.valid?.should == true
  end
  it "should have a nice to_s" do
    @group.to_s.should == @group.group_name
  end

  it "should only list the visible groups" do
    @group2 = FactoryGirl.create(:expense_group, :visible => true)
    ExpenseGroup.visible.all == [@group]
  end

  it "can have an expense_group without a free_option value" do
    @group.competitor_free_options = nil
    @group.valid?.should == true
  end
  it "can have an expense_group without a free_option value" do
    @group.noncompetitor_free_options = nil
    @group.valid?.should == true
  end

  describe "with expense_items" do
    before(:each) do
      @item2 = FactoryGirl.create(:expense_item, :expense_group => @group, :position => 2)
      @item1 = FactoryGirl.create(:expense_item, :expense_group => @group, :position => 1)
    end
    it "orders the items by position" do
      @group.expense_items.should == [@item1, @item2]
    end
  end

  describe "with multiple expense groups" do
    before(:each) do
      @group.position = 1
      @group.visible = false
      @group.save
      @group3 = FactoryGirl.create(:expense_group, :position => 3)
      @group2 = FactoryGirl.create(:expense_group, :position => 2)
      @group4 = FactoryGirl.create(:expense_group, :position => 4)
    end

    it "lists them in order" do
      ExpenseGroup.all.should == [@group, @group2, @group3, @group4]
    end

    it "lists the 'visible' ones in order" do
      ExpenseGroup.visible.should == [@group2, @group3, @group4]
    end
  end


end
