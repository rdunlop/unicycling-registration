require 'spec_helper'

describe EventsController do
  before do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end

  # This should return the minimal set of attributes required to create a valid
  # Event. As you add validations to Event, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      name: "Event Name"
    }
  end

  describe "as a normal user" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read summary" do
      get :summary
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET summary" do
    it "assigns all events as @events" do
      event = FactoryGirl.create(:event)
      get :summary, {}
      expect(response).to be_success
      expect(assigns(:events)).to eq([event])
    end
    describe "With competitors and non-competitors" do
      before(:each) do
        @comp1 = FactoryGirl.create(:competitor)
        @comp2 = FactoryGirl.create(:competitor)
        @non_comp1 = FactoryGirl.create(:noncompetitor)
      end
      it "sets the number of registrants as @num_registrants" do
        get :summary, {}
        expect(assigns(:num_registrants)).to eq(3)
      end
      it "sets the number of competitors as @num_competitors" do
        get :summary, {}
        expect(assigns(:num_competitors)).to eq(2)
      end
      it "sets the number of non_competitors as @num_noncompetitors" do
        get :summary, {}
        expect(assigns(:num_noncompetitors)).to eq(1)
      end
    end
  end
end
