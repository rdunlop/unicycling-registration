require 'spec_helper'

describe TimeResultsController do
  before(:each) do
    sign_in FactoryGirl.create(:super_admin_user)
    @competition = FactoryGirl.create(:competition)
    @competitor = FactoryGirl.create(:event_competitor, :competition => @competition)
    @competition = @competitor.competition
  end

  # This should return the minimal set of attributes required to create a valid
  # EventCategory. As you add validations to EventCategory, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      status: nil,
      minutes: 0,
      seconds: 1,
      thousands: 2,
      competitor_id: @competitor.id
    }
  end

  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read time_results" do
      get :index, {:competition_id => @competition.id}
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET index" do
    it "assigns all time_results as @time_results" do
      time_result = TimeResult.create! valid_attributes
      get :index, {:competition_id => @competition.id}
      expect(assigns(:time_results)).to eq([time_result])
    end
    it "assigns a new time_result" do
      get :index, {:competition_id => @competition.id}
      expect(assigns(:time_result)).to be_a_new(TimeResult)
    end
  end

  describe "GET edit" do
    it "assigns the requested time_result as @time_result" do
      time_result = TimeResult.create! valid_attributes
      get :edit, {:id => time_result.id}
      expect(assigns(:time_result)).to eq(time_result)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TimeResult" do
        expect {
          post :create, {:competition_id => @competition.id, :time_result => valid_attributes}
        }.to change(TimeResult, :count).by(1)
      end

      it "assigns a newly created time_result as @time_result" do
        post :create, {:competition_id => @competition.id, :time_result => valid_attributes}
        expect(assigns(:time_result)).to be_a(TimeResult)
        expect(assigns(:time_result)).to be_persisted
      end

      it "redirects to the created time_result" do
        post :create, {:competition_id => @competition.id, :time_result => valid_attributes}
        expect(response).to redirect_to(competition_time_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event_category as @event_category" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TimeResult).to receive(:save).and_return(false)
        post :create, {:competition_id => @competition.id, :time_result => {status: "DQ"}}
        expect(assigns(:time_result)).to be_a_new(TimeResult)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TimeResult).to receive(:save).and_return(false)
        post :create, {:competition_id => @competition.id, :time_result => {status: "DQ"}}
        expect(response).to render_template("index")
      end
      it "loads the time_results" do
        allow_any_instance_of(TimeResult).to receive(:save).and_return(false)
        post :create, {:competition_id => @competition.id, :time_result => {status: "DQ"}}
        expect(assigns(:time_results)).to eq([])
      end
      it "loads the event" do
        allow_any_instance_of(TimeResult).to receive(:save).and_return(false)
        post :create, {:competition_id => @competition.id, :time_result => {status: "DQ"}}
        expect(assigns(:competition)).to eq(@competition)
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested time_result" do
        time_result = TimeResult.create! valid_attributes
        # Assuming there are no other event_categories in the database, this
        # specifies that the EventCategory created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(TimeResult).to receive(:update_attributes).with({})
        put :update, {:id => time_result.to_param, :time_result => {'these' => 'params'}}
      end

      it "redirects to the event time results" do
        time_result = TimeResult.create! valid_attributes
        put :update, {:id => time_result.to_param, :time_result => valid_attributes}
        expect(response).to redirect_to(competition_time_results_path(@competition))
      end
    end

    describe "with invalid params" do
      it "assigns the time_result as @time_result" do
        time_result = TimeResult.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TimeResult).to receive(:save).and_return(false)
        put :update, {:id => time_result.to_param, :time_result => {status: "DQ"}}
        expect(assigns(:time_result)).to eq(time_result)
      end

      it "re-renders the 'edit' template" do
        time_result = TimeResult.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TimeResult).to receive(:save).and_return(false)
        put :update, {:id => time_result.to_param, :time_result => {status: "DQ"}}
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested time_result" do
      time_result = FactoryGirl.create(:time_result)
      expect {
        delete :destroy, {:id => time_result.to_param}
      }.to change(TimeResult, :count).by(-1)
    end

    it "redirects to the event's time_results list" do
      time_result = FactoryGirl.create(:time_result)
      competition = time_result.competition
      delete :destroy, {:id => time_result.to_param}
      expect(response).to redirect_to(competition_time_results_path(competition))
    end
  end

end
