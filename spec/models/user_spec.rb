require 'spec_helper'

describe User do
  it "can be created by factory girl" do
    user = FactoryGirl.create(:user)
    user.valid?.should == true
  end
end
