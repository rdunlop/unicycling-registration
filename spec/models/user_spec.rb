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

  it "can sum the amount owing from all registrants" do
    @user.total_owing.should == 0
  end
  describe "with a registration period" do
    before(:each) do
      @rp = FactoryGirl.create(:registration_period, :competitor_cost => 100, :noncompetitor_cost => 40)
    end

    it "calculates the cost of a competitor" do
      @comp = FactoryGirl.create(:competitor, :user => @user)
      @user.total_owing.should == 100
    end
    it "calculates the cost of a noncompetitor" do
      @comp = FactoryGirl.create(:noncompetitor, :user => @user)
      @user.total_owing.should == 40
    end
  end
end
