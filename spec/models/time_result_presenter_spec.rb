require 'spec_helper'

describe TimeResultPresenter do
  before(:each) do
    @tr = TimeResultPresenter.new(62123)
  end
  it "has the correct thousands" do
    expect(@tr.thousands).to eq(123)
  end
  it "has the correct seconds" do
    expect(@tr.seconds).to eq(2)
  end
  it "has the correct minutes" do
    expect(@tr.minutes).to eq(1)
  end
end
