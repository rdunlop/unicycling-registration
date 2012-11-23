require 'spec_helper'

describe Payment do
  before(:each) do
    @pay = FactoryGirl.create(:payment)
  end

  it "can be created by FactoryGirl" do
    @pay.valid?.should == true
  end

  it "defaults completed to false" do
    p = Payment.new
    p.completed.should == false
  end

  it "defaults cancelled to false" do
    p = Payment.new
    p.cancelled.should == false
  end

  it "Requires user" do
    @pay.user = nil
    @pay.valid?.should == false
  end

  it "has payment_details" do
    pd = FactoryGirl.create(:payment_detail, :payment => @pay)
    @pay.payment_details.should == [pd]
  end

  it "saves associated details when the payment is saved" do
    pay = FactoryGirl.build(:payment)
    pd = pay.payment_details.build()
    pd.registrant = FactoryGirl.create(:registrant)
    pd.amount = 100
    PaymentDetail.all.count.should == 0
    pay.save
    PaymentDetail.all.count.should == 1
  end
end
