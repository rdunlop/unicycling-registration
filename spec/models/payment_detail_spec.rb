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

  it "must have a registrant" do
    @pd.registrant = nil
    @pd.valid?.should == false
  end

  it "must have an amount" do
    @pd.amount = nil
    @pd.valid?.should == false
  end
end
