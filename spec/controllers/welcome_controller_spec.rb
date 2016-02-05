require 'spec_helper'

describe WelcomeController do
  describe "GET 'help'" do
    it "returns http success" do
      get :help
      expect(response).to be_success
    end
  end

  describe "GET index" do
    describe "when there is a 'Home' page" do
      let!(:home_page) { FactoryGirl.create(:page, :home) }

      it "redirects to homepage" do
        get :index
        expect(response).to redirect_to(page_path(home_page.slug))
      end
    end

    describe "when there is no 'Home' page" do
      it "redirects to log_in page" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # handle case where a machine queries for a non-locale
  describe "GET 'humans.txt'" do
    it "returns 404-not-found" do
      @user = FactoryGirl.create(:user)
      sign_in @user
      expect do
        get :index, locale: 'humans', format: 'txt'
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "POST feedback" do
    it "returns http success" do
      post 'feedback', contact_form: { feedback: "Hello WorlD", email: "robin@dunlopweb.com"}
      expect(response).to redirect_to(contact_us_welcome_path)
    end
    it "returns an error when no feedback" do
      post "feedback", contact_form: {feedback: nil}
      expect(response).to render_template("contact_us")
    end
    it "sends a message" do
      ActionMailer::Base.deliveries.clear
      post :feedback, contact_form: {feedback: "Hello werld", email: "robin@dunlopweb.com" }
      num_deliveries = ActionMailer::Base.deliveries.size
      expect(num_deliveries).to eq(1)
    end
    it "when no user signed in, has placeholder for email and registrants" do
      post :feedback, contact_form: { feedback: "Hello werld" }
      @cf = assigns(:contact_form)
      expect(@cf.feedback).to eq("Hello werld")
      expect(@cf.username).to eq("not-signed-in")
      expect(@cf.registrants).to eq("unknown")
    end

    describe "when the user is signed in, and has registrants" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
        @registrant = FactoryGirl.create(:competitor, user: @user)
      end
      it "assigns the user object when feedback error" do
        post "feedback", contact_form: {feedback: nil}
        expect(assigns(:user)).to eq(@user)
      end

      it "includes the user's e-mail (and names of registrants)" do
        post :feedback, contact_form: { feedback: "Hello werld" }
        @cf = assigns(:contact_form)
        expect(@cf.feedback).to eq("Hello werld")
        expect(@cf.username).to eq(@user.email)
        expect(@cf.registrants).to eq(@registrant.name)
      end
    end
  end

  describe "GET usa_membership" do
    describe "with USA enabled" do
      let!(:event_configuration) { FactoryGirl.create(:event_configuration, :with_usa) }

      it "returns http success" do
        get :usa_membership
        expect(response).to be_success
      end
    end

    it "returns http success" do
      get :usa_membership
      expect(response).to be_success
    end
  end
end
