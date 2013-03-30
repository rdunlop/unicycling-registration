require 'spec_helper'

describe TimeResultsController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
    @event = FactoryGirl.create(:event)
    @event_category = @event.event_categories.first
    @act = FactoryGirl.create(:age_group_type)
    @reg = FactoryGirl.create(:competitor)
  end

  # This should return the minimal set of attributes required to create a valid
  # EventCategory. As you add validations to EventCategory, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      disqualified: false,
      minutes: 0,
      seconds: 1,
      thousands: 2,
      registrant_id: @reg.id
    }
  end

  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read time_results" do
      get :index, {:event_category_id => @event_category.id}
      response.should redirect_to(root_path)
    end
  end


  describe "GET index" do
    it "assigns all time_results as @time_results" do
      time_result = TimeResult.create! valid_attributes.merge({:event_category_id => @event_category.id})
      get :index, {:event_category_id => @event_category.id}
      assigns(:time_results).should eq([time_result])
    end
    it "assigns a new time_result" do
      get :index, {:event_category_id => @event_category.id}
      assigns(:time_result).should be_a_new(TimeResult)
    end
  end

  describe "GET edit" do
    it "assigns the requested time_result as @time_result" do
      time_result = TimeResult.create! valid_attributes.merge({:event_category_id => @event_category.id})
      get :edit, {:id => time_result.id}
      assigns(:time_result).should eq(time_result)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TimeResult" do
        expect {
          post :create, {:event_category_id => @event_category.id, :time_result => valid_attributes}
        }.to change(TimeResult, :count).by(1)
      end

      it "assigns a newly created event_category as @event_category" do
        post :create, {:event_category_id => @event_category.id, :time_result => valid_attributes}
        assigns(:time_result).should be_a(TimeResult)
        assigns(:time_result).should be_persisted
      end

      it "redirects to the created event_category" do
        post :create, {:event_category_id => @event_category.id, :time_result => valid_attributes}
        response.should redirect_to(event_category_time_results_path(@event_category))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event_category as @event_category" do
        # Trigger the behavior that occurs when invalid params are submitted
        TimeResult.any_instance.stub(:save).and_return(false)
        post :create, {:event_category_id => @event_category.id, :time_result => {}}
        assigns(:time_result).should be_a_new(TimeResult)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        TimeResult.any_instance.stub(:save).and_return(false)
        post :create, {:event_category_id => @event_category.id, :time_result => {}}
        response.should render_template("index")
      end
      it "loads the time_results" do
        TimeResult.any_instance.stub(:save).and_return(false)
        post :create, {:event_category_id => @event_category.id, :time_result => {}}
        assigns(:time_results).should == []
      end
      it "loads the event_category" do
        TimeResult.any_instance.stub(:save).and_return(false)
        post :create, {:event_category_id => @event_category.id, :time_result => {}}
        assigns(:event_category).should == @event_category
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested time_result" do
        time_result = TimeResult.create! valid_attributes.merge({:event_category_id => @event_category.id})
        # Assuming there are no other event_categories in the database, this
        # specifies that the EventCategory created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        TimeResult.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => time_result.to_param, :time_result => {'these' => 'params'}}
      end

      it "redirects to the event_category time results" do
        time_result = TimeResult.create! valid_attributes.merge({:event_category_id => @event_category.id})
        put :update, {:id => time_result.to_param, :time_result => valid_attributes}
        response.should redirect_to(event_category_time_results_path(@event_category))
      end
    end

    describe "with invalid params" do
      it "assigns the time_result as @time_result" do
        time_result = TimeResult.create! valid_attributes.merge({:event_category_id => @event_category.id})
        # Trigger the behavior that occurs when invalid params are submitted
        TimeResult.any_instance.stub(:save).and_return(false)
        put :update, {:id => time_result.to_param, :time_result => {}}
        assigns(:time_result).should eq(time_result)
      end

      it "re-renders the 'edit' template" do
        time_result = TimeResult.create! valid_attributes.merge({:event_category_id => @event_category.id})
        # Trigger the behavior that occurs when invalid params are submitted
        TimeResult.any_instance.stub(:save).and_return(false)
        put :update, {:id => time_result.to_param, :time_result => {}}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested time_result" do
      time_result = FactoryGirl.create(:time_result, :event_category => @event_category)
      expect {
        delete :destroy, {:id => time_result.to_param}
      }.to change(TimeResult, :count).by(-1)
    end

    it "redirects to the event_categories' time_results list" do
      time_result = FactoryGirl.create(:time_result, :event_category => @event_category)
      event_category = time_result.event_category
      delete :destroy, {:id => time_result.to_param}
      response.should redirect_to(event_category_time_results_path(event_category))
    end
  end

end
