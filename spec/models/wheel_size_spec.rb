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
    expect(@ws.valid?).to eq(true)
  end

  it "requires a position" do
    @ws.position = nil
    expect(@ws.valid?).to eq(false)
  end

  it "requires a description" do
    @ws.description = nil
    expect(@ws.valid?).to eq(false)
  end

  it "returns the wheel sizes in position order" do
    @ws3 = FactoryGirl.create(:wheel_size, :position => 3)
    @ws2 = FactoryGirl.create(:wheel_size, :position => 2)
    expect(WheelSize.all).to eq([@ws3, @ws2, @ws])
  end

  it "returns the description as the to_s" do
    expect(@ws.to_s).to eq(@ws.description)
  end
end
