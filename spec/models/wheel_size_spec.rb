# == Schema Information
#
# Table name: wheel_sizes
#
#  id          :integer          not null, primary key
#  position    :integer
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe WheelSize do
  before(:each) do
    @ws = FactoryGirl.create(:wheel_size)
  end
  it "is valid" do
    @ws.valid?.should == true
  end

  it "requires a position" do
    @ws.position = nil
    @ws.valid?.should == false
  end

  it "requires a description" do
    @ws.description = nil
    @ws.valid?.should == false
  end

  it "returns the wheel sizes in position order" do
    @ws3 = FactoryGirl.create(:wheel_size, :position => 3)
    @ws2 = FactoryGirl.create(:wheel_size, :position => 2)
    WheelSize.all.should == [@ws3, @ws2, @ws]
  end

  it "returns the description as the to_s" do
    @ws.to_s.should == @ws.description
  end
end
