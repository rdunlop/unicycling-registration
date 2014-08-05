require 'spec_helper'

describe EmailsController do
  before(:each) do
    @user = FactoryGirl.create(:admin_user)
    sign_in @user
  end

  describe "POST send_email" do
    it "can send an e-mail" do
      FactoryGirl.create(:user)
      ActionMailer::Base.deliveries.clear
      post :create, { :email => {:subject => "Hello werld", :body => "This is the body", :confirmed_accounts => true, competition_id: [] }}
      num_deliveries = ActionMailer::Base.deliveries.size
      num_deliveries.should == 1
      message = ActionMailer::Base.deliveries.first
      message.bcc.count.should == 2
    end

    it "breaks apart large requests into multiple smaller requests" do
      50.times do |n|
        FactoryGirl.create(:user)
      end
      ActionMailer::Base.deliveries.clear
      post :create, { :email => {:subject => "Hello werld", :body => "This is the body", :confirmed_accounts => true, competition_id: [] }}
      num_deliveries = ActionMailer::Base.deliveries.size
      num_deliveries.should == 2

      first_message = ActionMailer::Base.deliveries.first
      first_message.bcc.count.should == 30

      second_message = ActionMailer::Base.deliveries.second
      second_message.bcc.count.should == 21
    end
  end
end
