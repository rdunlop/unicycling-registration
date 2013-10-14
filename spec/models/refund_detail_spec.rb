require 'spec_helper'

describe RefundDetail do
  before(:each) do
    @rd = FactoryGirl.create(:refund_detail)
  end

  it "has a valid rd from factoryGirl" do
    @rd.valid?.should == true
  end

  it "requires a payment_detail" do
    @rd.payment_detail = nil
    @rd.valid?.should == false
  end
end
