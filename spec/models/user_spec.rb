# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#

require 'spec_helper'

describe User do
  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  it "can be created by factory girl" do
    @user.valid?.should == true
  end

  it "can specify a custom name" do
    expect(@user.to_s).to eq(@user.email)
    @user.name = "Robin"
    expect(@user.to_s).to eq("Robin")
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
    describe "only users with registrants" do
      before(:each) do
        @other_user = FactoryGirl.create(:user)
      end

      it "lists only users who have registranst" do
        User.all_with_registrants.should == [@user]
      end
    end
    describe "with a user who is not confirmed" do
      before(:each) do
        u = FactoryGirl.create(:user)
        u.confirmed_at = nil
        u.save!
      end
      it "should not list the non-confirmed user" do
        User.confirmed.should == [@user]
      end
    end

    it "orders the registrants by bib_number" do
      # @reg2, being a non-competitor, is a higher bib_number than the other two compeittors
      @user.registrants.active.should == [@reg1, @reg3, @reg2]
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
end
