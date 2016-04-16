require 'spec_helper'

describe Admin::FeedbackController do
  before(:each) do
    @user = FactoryGirl.create(:convention_admin_user)
    sign_in @user
  end
  let!(:feedback) { FactoryGirl.create(:feedback) }
  let!(:resolved_feedback) { FactoryGirl.create(:feedback, :resolved) }

  describe "#index" do
    it "can list the feedback" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "#show" do
    context "a unresolved feedback" do
      it "can show the feedback" do
        get :show, id: feedback.id
        expect(response).to be_successful
      end
    end

    context "a resolved feedback" do
      it "can show the feedback" do
        get :show, id: resolved_feedback.id
        expect(response).to be_successful
      end
    end
  end

  describe "#resolve" do
    context "with good params" do
      it "can resolve the feedback" do
        expect do
          put :resolve, id: feedback.id, feedback: { resolution: "This is done" }
        end.to change{ feedback.reload.status }.to("resolved")
      end
    end

    context "missing the resolution" do
      it "re-renders the show view" do
        put :resolve, id: feedback.id
        expect(response).to redirect_to(admin_feedback_path(feedback))
      end
    end
  end
end
