# == Schema Information
#
# Table name: feedbacks
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  entered_email  :string
#  message        :text
#  status         :string           default("new"), not null
#  resolved_at    :datetime
#  resolved_by_id :integer
#  resolution     :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'spec_helper'

describe FeedbacksController do
  let(:user) { FactoryGirl.create(:user) }

  describe "GET #new" do
    it "renders" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    it "returns http success" do
      post :create, params: { feedback: { message: "Hello WorlD", entered_email: "robin@dunlopweb.com"} }
      expect(response).to redirect_to(new_feedback_path)
    end

    it "returns an error when no message" do
      post :create, params: { feedback: { message: nil } }
      assert_select "h1", "Contact Us"
    end

    it "sends a message" do
      ActionMailer::Base.deliveries.clear
      post :create, params: { feedback: { message: "Hello werld", entered_email: "robin@dunlopweb.com" } }
      num_deliveries = ActionMailer::Base.deliveries.size
      expect(num_deliveries).to eq(1)
    end

    describe "when the user is signed in, and has registrants" do
      before(:each) do
        sign_in user
        @registrant = FactoryGirl.create(:competitor, user: user)
      end

      it "shows the feedback new page when feedback error" do
        post :create, params: { feedback: { message: nil } }
        assert_select "h1", "Contact Us"
      end

      it "sends a message" do
        ActionMailer::Base.deliveries.clear
        post :create, params: { feedback: { message: "Hello werld" } }
        num_deliveries = ActionMailer::Base.deliveries.size
        expect(num_deliveries).to eq(1)
      end
    end
  end
end
