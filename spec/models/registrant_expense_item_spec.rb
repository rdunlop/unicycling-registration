require 'spec_helper'

describe RegistrantExpenseItem do
  before(:each) do
    @rei = FactoryGirl.create(:registrant_expense_item)
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
end
