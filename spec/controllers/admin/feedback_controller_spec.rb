require 'spec_helper'

describe Admin::FeedbackController do
  let(:user) { FactoryGirl.create(:payment_admin) }
  let!(:feedback) { FactoryGirl.create(:feedback) }
  let!(:resolved_feedback) { FactoryGirl.create(:feedback, :resolved) }

  before(:each) do
    sign_in user
  end

  describe "#index" do
    it "can list the feedback" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "#show" do
    context "a unresolved feedback" do
      it "can show the feedback" do
        get :show, params: { id: feedback.id }
        expect(response).to be_successful
      end
    end

    context "a resolved feedback" do
      it "can show the feedback" do
        get :show, params: { id: resolved_feedback.id }
        expect(response).to be_successful
      end
    end
  end

  describe "#resolve" do
    context "with good params" do
      it "can resolve the feedback" do
        expect do
          put :resolve, params: { id: feedback.id, feedback: { resolution: "This is done" } }
        end.to change{ feedback.reload.status }.to("resolved")
      end
    end

    context "missing the resolution" do
      it "re-renders the show view" do
        put :resolve, params: { id: feedback.id }
        expect(response).to redirect_to(admin_feedback_path(feedback))
      end
    end
  end

  context "as a super-admin" do
    let(:user) { FactoryGirl.create(:super_admin_user) }
    describe "#new" do
      it "displays" do
        get :new
        expect(response).to be_successful
      end
    end

    describe "#create" do
      it "creates new feedback" do
        expect do
          post :create, params: { feedback: { entered_email: "test@example.com", message: "help me obi-wan" } }
        end.to change(Feedback, :count).by(1)
      end
    end
  end
end
