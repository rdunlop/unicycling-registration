require 'spec_helper'

describe RegistrantGroupsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in @admin_user
  end

  # This should return the minimal set of attributes required to create a valid
  # RegistrantGroup. As you add validations to RegistrantGroup, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "name" => "MyString" }
  end

  describe "GET index" do
    it "assigns all registrant_groups as @registrant_groups" do
      registrant_group = RegistrantGroup.create! valid_attributes
      get :index, {}
      assigns(:registrant_groups).should eq([registrant_group])
    end
  end

  describe "GET show" do
    it "assigns the requested registrant_group as @registrant_group" do
      registrant_group = RegistrantGroup.create! valid_attributes
      get :show, {:id => registrant_group.to_param}
      assigns(:registrant_group).should eq(registrant_group)
    end
  end

  describe "GET new" do
    it "assigns a new registrant_group as @registrant_group" do
      get :new, {}
      assigns(:registrant_group).should be_a_new(RegistrantGroup)
    end
  end

  describe "GET edit" do
    it "assigns the requested registrant_group as @registrant_group" do
      registrant_group = RegistrantGroup.create! valid_attributes
      get :edit, {:id => registrant_group.to_param}
      assigns(:registrant_group).should eq(registrant_group)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new RegistrantGroup" do
        expect {
          post :create, {:registrant_group => valid_attributes}
        }.to change(RegistrantGroup, :count).by(1)
      end

      it "assigns a newly created registrant_group as @registrant_group" do
        post :create, {:registrant_group => valid_attributes}
        assigns(:registrant_group).should be_a(RegistrantGroup)
        assigns(:registrant_group).should be_persisted
      end

      it "redirects to the created registrant_group" do
        post :create, {:registrant_group => valid_attributes}
        response.should redirect_to(RegistrantGroup.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved registrant_group as @registrant_group" do
        # Trigger the behavior that occurs when invalid params are submitted
        RegistrantGroup.any_instance.stub(:save).and_return(false)
        post :create, {:registrant_group => { "name" => "invalid value" }}
        assigns(:registrant_group).should be_a_new(RegistrantGroup)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        RegistrantGroup.any_instance.stub(:save).and_return(false)
        post :create, {:registrant_group => { "name" => "invalid value" }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested registrant_group" do
        registrant_group = RegistrantGroup.create! valid_attributes
        # Assuming there are no other registrant_groups in the database, this
        # specifies that the RegistrantGroup created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        RegistrantGroup.any_instance.should_receive(:update_attributes).with({ "name" => "MyString" })
        put :update, {:id => registrant_group.to_param, :registrant_group => { "name" => "MyString" }}
      end

      it "assigns the requested registrant_group as @registrant_group" do
        registrant_group = RegistrantGroup.create! valid_attributes
        put :update, {:id => registrant_group.to_param, :registrant_group => valid_attributes}
        assigns(:registrant_group).should eq(registrant_group)
      end

      it "redirects to the registrant_group" do
        registrant_group = RegistrantGroup.create! valid_attributes
        put :update, {:id => registrant_group.to_param, :registrant_group => valid_attributes}
        response.should redirect_to(registrant_group)
      end
    end

    describe "with invalid params" do
      it "assigns the registrant_group as @registrant_group" do
        registrant_group = RegistrantGroup.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        RegistrantGroup.any_instance.stub(:save).and_return(false)
        put :update, {:id => registrant_group.to_param, :registrant_group => { "name" => "invalid value" }}
        assigns(:registrant_group).should eq(registrant_group)
      end

      it "re-renders the 'edit' template" do
        registrant_group = RegistrantGroup.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        RegistrantGroup.any_instance.stub(:save).and_return(false)
        put :update, {:id => registrant_group.to_param, :registrant_group => { "name" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested registrant_group" do
      registrant_group = RegistrantGroup.create! valid_attributes
      expect {
        delete :destroy, {:id => registrant_group.to_param}
      }.to change(RegistrantGroup, :count).by(-1)
    end

    it "redirects to the registrant_groups list" do
      registrant_group = RegistrantGroup.create! valid_attributes
      delete :destroy, {:id => registrant_group.to_param}
      response.should redirect_to(registrant_groups_url)
    end
  end

end
