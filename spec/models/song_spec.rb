require 'spec_helper'

describe Song do
  let(:song) { FactoryGirl.build_stubbed(:song) }
  it "must be valid by default" do
    song.valid?.should == true
  end
  it "must have an event" do
    song.event = nil
    song.valid?.should == false
  end

  it "must have a description" do
    song.event = FactoryGirl.build_stubbed(:event)
    song.description = nil
    song.valid?.should == false
  end
end
