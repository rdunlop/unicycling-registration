require 'spec_helper'

describe PaymentDetail do
  before(:each) do
    @pd = FactoryGirl.create(:payment_detail)
  end

  it "can be cerated by factory" do
    @pd.valid?.should == true
  end

  it "must have a payment" do
    @pd.payment = nil
    @pd.valid?.should == false
  end

  it "does not allow negative amounts" do
    @pd.amount = -1
    @pd.valid?.should == false
  end

  it "must have a registrant" do
    @pd.registrant = nil
    @pd.valid?.should == false
  end

  it "must have an amount" do
    @pd.amount = nil
    @pd.valid?.should == false
  end
  it "must have an item" do
    @pd.expense_item = nil
    @pd.valid?.should == false
  end

  it "marks the amount as negative if it is a refund" do
    @pd.refund = true
    @pd.amount = 10
    @pd.cost.should == -10
  end

  it "is not a refund by default" do
    pay = PaymentDetail.new
    pay.refund.should == false
  end

  it "is not scoped as completed if not completed" do
    @pd.payment.completed.should == false
    PaymentDetail.completed.should == []
  end
  it "is scoped as completed when payment is completed" do
    pay = @pd.payment
    pay.completed = true
    pay.save!
    PaymentDetail.completed.should == [@pd]
  end
end
