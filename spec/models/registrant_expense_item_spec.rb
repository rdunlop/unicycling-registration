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
  it "is initial not paid_for" do
    @rei.paid_for?.should == false
  end
  describe "when a payment has been made" do
    before(:each) do
      @item = FactoryGirl.create(:expense_item)
      @rei = FactoryGirl.create(:registrant_expense_item, :expense_item => @item)
      @reg = @rei.registrant
      @pd = FactoryGirl.create(:payment_detail, :registrant => @reg, :expense_item => @item, :amount => @item.cost)
      @payment = @pd.payment
      @payment.completed = true
      @payment.save
    end
    it "is paid_for" do
      @rei.paid_for?.should == true
    end
  end
end
