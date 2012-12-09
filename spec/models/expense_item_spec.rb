require 'spec_helper'

describe ExpenseItem do
  before(:each) do
    @item = FactoryGirl.create(:expense_item)
  end

  it "can create from factory" do
    @item.valid?.should == true
  end

  it "must have a name" do
    @item.name = nil
    @item.valid?.should == false
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
  it "should have a decent description" do
    @item.to_s.should == @item.name
  end
end
