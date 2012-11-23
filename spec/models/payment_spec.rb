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
end
