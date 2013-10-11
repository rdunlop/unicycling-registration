require 'spec_helper'

describe Refund do
  before(:each) do
    @refund = FactoryGirl.create(:refund)
  end

  it "creates a valid from factoryGirl" do
    @refund.valid?.should == true
  end

  it "requires a user" do
    @refund.user = nil
    @refund.valid?.should == false
  end

  it "requires a note" do
    @refund.note = nil
    @refund.valid?.should == false
    @refund.note = ""
    @refund.valid?.should == false
  end
end
