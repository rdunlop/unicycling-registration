require 'spec_helper'

describe LaneAssignment do
  before(:each) do
    @la = FactoryGirl.create(:lane_assignment)
  end
  it "has a valid factory" do
    @la.valid?.should == true
  end

  it "must have a heat" do
    @la.heat = nil
    @la.valid?.should == false
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
