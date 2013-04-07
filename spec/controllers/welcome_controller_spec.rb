require 'spec_helper'

describe WelcomeController do

  describe "GET 'help'" do
    it "returns http success" do
      get 'help'
      response.should be_success
    end
  end

  describe "POST feedback" do
    it "returns http success" do
      post 'feedback', {:contact_form => { :feedback => "Hello WorlD"}}
      response.should redirect_to(welcome_help_path)
    end
    it "sends a message" do
      ActionMailer::Base.deliveries.clear
      post :feedback, { :contact_form => {:feedback => "Hello werld" }}
      num_deliveries = ActionMailer::Base.deliveries.size
      num_deliveries.should == 1
    end
    it "when no user signed in, has placeholder for email and registrants" do
      post :feedback, {:contact_form => { :feedback => "Hello werld" }}
      @cf = assigns(:contact_form)
      @cf.feedback.should == "Hello werld"
      @cf.username.should == "not-signed-in"
      @cf.registrants.should == "unknown"
    end

    describe "when the user is signed in, and has registrants" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
        @registrant = FactoryGirl.create(:competitor, :user => @user)
      end

      it "includes the user's e-mail (and names of registrants)" do
        post :feedback, {:contact_form => { :feedback => "Hello werld" }}
        @cf = assigns(:contact_form)
        @cf.feedback.should == "Hello werld"
        @cf.username.should == @user.email
        @cf.registrants.should == @registrant.name
      end
    end
  end
end
