require 'spec_helper'

describe AdditionalRegistrantAccess do
  before(:each) do
    @ara = FactoryGirl.create(:additional_registrant_access)
  end
  it "can be created from factorygirl" do
    @ara.valid?.should == true
  end
  it "must have a registrant" do
    @ara.registrant = nil
    @ara.valid?.should == false
  end

  it "must have a user" do
    @ara.user = nil
    @ara.valid?.should == false
  end
  
  it "is declined:false by default" do
    ara = AdditionalRegistrantAccess.new
    ara.declined.should == false
  end
  
  it "is accepted_readonly:false by default" do
    ara = AdditionalRegistrantAccess.new
    ara.accepted_readonly.should == false
  end
end
