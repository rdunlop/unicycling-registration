require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  it "can be created by factory girl" do
    @user.valid?.should == true
  end

  it "has a value for the admin" do
    @user.admin = nil
    @user.valid?.should == false
  end

  it "has a value for the super_admin" do
    @user.super_admin = nil
    @user.valid?.should == false
  end

  it "has false for admin/super_admin by default" do
    user = User.new
    user.admin.should == false
    user.super_admin.should == false
  end
end
