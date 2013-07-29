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

  it "cannot have the same heat/lane twice for a single competition" do
    la2 = FactoryGirl.build(:lane_assignemnt, :heat => @la.heat, :lane => @la.lane, :competition => @la.competition)
    la2.valid?.should == false
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
