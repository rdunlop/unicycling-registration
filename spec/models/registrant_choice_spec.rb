require 'spec_helper'

describe RegistrantChoice do
  before(:each) do
    @rc = FactoryGirl.create(:registrant_choice)
  end
  it "is valid from FactoryGirl" do
    @rc.valid?.should == true
  end
  it "requires an event_choice" do
    @rc.event_choice = nil
    @rc.valid?.should == false
  end

  it "requires a registrant" do
    @rc.registrant = nil
    @rc.valid?.should == false
  end
end
