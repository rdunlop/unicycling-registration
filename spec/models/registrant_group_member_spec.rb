require 'spec_helper'

describe RegistrantGroupMember do
  before(:each) do
    @rgm= FactoryGirl.create(:registrant_group_member)
    @rg = @rgm.registrant_group
  end

  it "has a valid factory" do
    @rgm.valid?.should == true
  end

  it "registrant is required" do
    @rgm.registrant = nil
    @rgm.valid?.should == false
  end

  it "registrant_group is required" do
    @rgm.registrant_group = nil
    @rgm.valid?.should == false
  end
end
