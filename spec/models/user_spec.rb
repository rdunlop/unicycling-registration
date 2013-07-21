require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  it "can be created by factory girl" do
    @user.valid?.should == true
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

    it "determines if the user has a related minor" do
      @user.has_minor?.should == false
    end
    it "says no_minors if there are none" do
      FactoryGirl.create(:event_configuration, :start_date => Date.today)
      @reg4 = FactoryGirl.create(:minor_competitor, :user => @user, :birthday => Date.today - 10.years)
      @user.has_minor?.should == true
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

  describe "confirmation e-mail" do
    it "sends an e-mail" do
      ActionMailer::Base.deliveries.clear
      user = FactoryGirl.create(:user)
      num_deliveries = ActionMailer::Base.deliveries.size
      num_deliveries.should == 1
    end

    it "doesn't send an e-mail when skip configured" do
      ActionMailer::Base.deliveries.clear
      ENV['MAIL_SKIP_CONFIRMATION'] = "true"
      user = FactoryGirl.build(:user)
      user.valid?.should == true
      num_deliveries = ActionMailer::Base.deliveries.size
      num_deliveries.should == 0
    end
  end
end
