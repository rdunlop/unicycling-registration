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
  it "must have a value for the has_details field" do
    @item.has_details = nil
    @item.valid?.should == false
  end
  it "should have a default of no details" do
    item = ExpenseItem.new
    item.has_details.should == false
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
    end

    it "counts this entry as a selected_item when the payment is complete" do
      pay = @payment.payment
      pay.completed = true
      pay.save!
      @item.num_selected_items.should == 1
    end
  end

  describe "with associated registrant_expense_items" do
    before(:each) do
      @rei = FactoryGirl.create(:registrant_expense_item, :expense_item => @item)
    end
    
    it "should count the entry as a selected_item" do
      @item.num_selected_items.should == 1
    end
  end
end
