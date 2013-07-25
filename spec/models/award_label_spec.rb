require 'spec_helper'

describe AwardLabel do
  before(:each) do
    @al = FactoryGirl.create(:award_label)
  end

  it "has a valid factory" do
    @al.valid?.should == true
  end

  it "must have a registrant" do
    @al.registrant_id = nil
    @al.valid?.should == false
  end

  it "must have a user" do
    @al.user_id = nil
    @al.valid?.should == false
  end

  it "must have a place" do
    @al.place = nil
    @al.valid?.should == false
  end

  it "must have a positive place" do
    @al.place = 0
    @al.valid?.should == false
  end

end
