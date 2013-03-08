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
      post 'feedback'
      response.should redirect_to(welcome_help_path)
    end
    it "sends a message" do
      ActionMailer::Base.deliveries.clear
      post :feedback, { :feedback => "Hello werld" }
      num_deliveries = ActionMailer::Base.deliveries.size
      num_deliveries.should == 1
    end
  end
end
