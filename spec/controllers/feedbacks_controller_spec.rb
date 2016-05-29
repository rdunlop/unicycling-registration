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
      post :create, feedback: { message: "Hello WorlD", entered_email: "robin@dunlopweb.com"}
      expect(response).to redirect_to(new_feedback_path)
    end

    it "returns an error when no message" do
      post :create, feedback: { message: nil }
      expect(response).to render_template(:new)
    end

    it "sends a message" do
      ActionMailer::Base.deliveries.clear
      post :create, feedback: { message: "Hello werld", entered_email: "robin@dunlopweb.com" }
      num_deliveries = ActionMailer::Base.deliveries.size
      expect(num_deliveries).to eq(1)
    end

    it "when no user signed in, has placeholder for email and registrants" do
      post :create, feedback: { message: "Hello werld" }
      @cf = assigns(:feedback)
      expect(@cf.message).to eq("Hello werld")
      expect(@cf.username).to eq("not-signed-in")
      expect(@cf.user_first_registrant_name).to eq("unknown")
    end

    describe "when the user is signed in, and has registrants" do
      before(:each) do
        sign_in user
        @registrant = FactoryGirl.create(:competitor, user: user)
      end

      it "assigns the feedback object when feedback error" do
        post :create, feedback: { message: nil }
        expect(assigns(:feedback)).to be
      end

      it "includes the user's e-mail (and names of registrants)" do
        post :create, feedback: { message: "Hello werld" }
        @cf = assigns(:feedback)
        expect(@cf.message).to eq("Hello werld")
        expect(@cf.username).to eq(user.email)
        expect(@cf.user_first_registrant_name).to eq(@registrant.name)
      end
    end
  end
end
