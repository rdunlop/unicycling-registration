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

  describe "when neither declined nor accepeted" do
    before(:each) do
      @ara.declined = false
      @ara.accepted_readonly = false
    end
    it "has a new status" do
      @ara.status.should == "New"
    end
  end
  describe "when it is accepted" do
    before(:each) do
      @ara.accepted_readonly = true
    end
    it "has an Accepted status" do
      @ara.status.should == "Accepted"
    end
  end
  describe "when it is declined" do
    before(:each) do
      @ara.declined = true
    end
    it "has a Declined status" do
      @ara.status.should == "Declined"
    end
    it "even when also accepted" do
      @ara.accepted_readonly = true
      @ara.status.should == "Declined"
    end
  end
end
