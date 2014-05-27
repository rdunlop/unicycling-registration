# == Schema Information
#
# Table name: lane_assignments
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  heat           :integer
#  lane           :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  competitor_id  :integer
#

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
    la2 = FactoryGirl.build(:lane_assignment, :heat => @la.heat, :lane => @la.lane, :competition => @la.competition)
    la2.valid?.should == false
  end

  it "can have different lanes in the same heat/competition" do
    la2 = FactoryGirl.build(:lane_assignment, :heat => @la.heat, :lane => @la.lane + 1, :competition => @la.competition)
    la2.valid?.should == true
  end

  it "can have the same lane in different heats in the same competition" do
    la2 = FactoryGirl.build(:lane_assignment, :heat => @la.heat + 1, :lane => @la.lane, :competition => @la.competition)
    la2.valid?.should == true
  end
end
