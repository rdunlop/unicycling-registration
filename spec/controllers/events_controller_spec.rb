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
      response.should redirect_to(root_path)
    end
  end


  describe "POST create_director" do
    it "creates a new director" do
      user = FactoryGirl.create(:user)
      event = FactoryGirl.create(:event)
      post :create_director, {:user_id => user.id, :id => event.id}
      User.with_role(:director, event).should == [user]
    end
  end

  describe "DELETE director" do
    it "can delete a director" do
      user = FactoryGirl.create(:user)
      event = FactoryGirl.create(:event)
      user.add_role :director, event
      delete :destroy_director, {:user_id => user.id, :id => event.id}
      User.with_role(:director, event).should == []
    end
  end

  describe "GET summary" do
    it "assigns all events as @events" do
      event = FactoryGirl.create(:event)
      get :summary, {}
      response.should be_success
      assigns(:events).should eq([event])
    end
    describe "With competitors and non-competitors" do
      before(:each) do
        @comp1 = FactoryGirl.create(:competitor)
        @comp2 = FactoryGirl.create(:competitor)
        @non_comp1 = FactoryGirl.create(:noncompetitor)
      end
      it "sets the number of registrants as @num_registrants" do
        get :summary, {}
        assigns(:num_registrants).should == 3
      end
      it "sets the number of competitors as @num_competitors" do
        get :summary, {}
        assigns(:num_competitors).should == 2
      end
      it "sets the number of non_competitors as @num_noncompetitors" do
        get :summary, {}
        assigns(:num_noncompetitors).should == 1
      end
    end
  end
end
