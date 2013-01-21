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
  describe "with an expense_item" do
    before(:each) do
      @rp = FactoryGirl.create(:registration_period)
    end

    it "calculates the cost of a competitor" do
      @comp = FactoryGirl.create(:competitor, :user => @user)
      @user.total_owing.should == 100
    end
    it "calculates the cost of a noncompetitor" do
      @comp = FactoryGirl.create(:noncompetitor, :user => @user)
      @user.total_owing.should == 50
    end
  end

  describe "with related registrants" do
    before(:each) do
      @reg1 = FactoryGirl.create(:competitor, :user => @user)
      @reg2 = FactoryGirl.create(:noncompetitor, :user => @user)
      @reg3 = FactoryGirl.create(:competitor, :user => @user)

      @reg1.first_name = "holly"
      @reg1.save
    end
    it "orders the registrants by id" do
      @user.registrants.should == [@reg1, @reg2, @reg3]
    end
  end

  describe "with 3 users" do
    before(:each) do
      @b = FactoryGirl.create(:user, :email => "b@b.com")
      @a = FactoryGirl.create(:admin_user, :email => "a@a.com")
      @c = FactoryGirl.create(:super_admin_user, :email => "c@c.com")
    end

    it "lists them in alphabetical order" do
      User.all.should == [@a, @b, @c, @user]
    end
  end
end
