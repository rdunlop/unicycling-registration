require 'spec_helper'

describe Admin::RegistrantsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in @admin_user
  end


  describe "GET index" do
    it "assigns all registrants as @registrants" do
      registrant = FactoryGirl.create(:competitor)
      other_reg = FactoryGirl.create(:registrant)
      get :index, {}
      assigns(:registrants).should =~[registrant, other_reg]
    end
  end

  describe "POST undelete" do
    it "un-deletes a deleted registration" do
      registrant = FactoryGirl.create(:competitor, :deleted => true)
      post :undelete, {:id => registrant.id }
      registrant.reload
      registrant.deleted.should == false
    end

    it "redirects to the index" do
      registrant = FactoryGirl.create(:competitor, :deleted => true)
      post :undelete, {:id => registrant.id }
      response.should redirect_to(admin_registrants_path)
    end

    describe "as a normal user" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end
      it "Cannot undelete a user" do
        registrant = FactoryGirl.create(:competitor, :deleted => true)
        post :undelete, {:id => registrant.id }
        registrant.reload
        registrant.deleted.should == true
      end
    end
  end

  describe "POST send_email" do
    it "can send an e-mail" do
      ActionMailer::Base.deliveries.clear
      post :send_email, { :email => {:subject => "Hello werld", :body => "This is the body", :email_addresses => ["robin@dunlopweb.com", "robin+1@dunlopweb.com"] }}
      num_deliveries = ActionMailer::Base.deliveries.size
      num_deliveries.should == 1
      message = ActionMailer::Base.deliveries.first
      message.bcc.count.should == 2
    end

    it "breaks apart large requests into multiple smaller requests" do
      ActionMailer::Base.deliveries.clear
      addresses = []
      50.times do |n|
        addresses << "robin+#{n}@dunlopweb.com"
      end
      post :send_email, { :email => {:subject => "Hello werld", :body => "This is the body", :email_addresses => addresses }}
      num_deliveries = ActionMailer::Base.deliveries.size
      num_deliveries.should == 2

      first_message = ActionMailer::Base.deliveries.first
      first_message.bcc.count.should == 30

      second_message = ActionMailer::Base.deliveries.second
      second_message.bcc.count.should == 20
    end
  end
end
