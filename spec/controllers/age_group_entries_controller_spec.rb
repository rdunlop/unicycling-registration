require 'spec_helper'

describe AgeGroupEntriesController do
  before(:each) do
    sign_in FactoryGirl.create(:admin_user)
    @age_group_type = FactoryGirl.create(:age_group_type)
    @ws = FactoryGirl.create(:wheel_size)
  end

  # This should return the minimal set of attributes required to create a valid
  # AgeGroupEntry. As you add validations to AgeGroupEntry, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { :short_description => "All Ages",
      :gender => "Male",
      :wheel_size_id => @ws.id
    }
  end

  describe "GET index" do
    it "assigns all age_group_entries as @age_group_entries" do
      age_group_entry = FactoryGirl.create(:age_group_entry, :age_group_type => @age_group_type)
      get :index, {:age_group_type_id => @age_group_type.id}
      assigns(:age_group_entries).should eq([age_group_entry])
    end
  end

  describe "GET show" do
    it "assigns the requested age_group_entry as @age_group_entry" do
      age_group_entry = FactoryGirl.create(:age_group_entry)
      get :show, {:id => age_group_entry.to_param}
      assigns(:age_group_entry).should eq(age_group_entry)
    end
  end

  describe "GET edit" do
    it "assigns the requested age_group_entry as @age_group_entry" do
      age_group_entry = FactoryGirl.create(:age_group_entry)
      get :edit, {:id => age_group_entry.to_param}
      assigns(:age_group_entry).should eq(age_group_entry)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new AgeGroupEntry" do
        expect {
          post :create, {:age_group_entry => valid_attributes, :age_group_type_id => @age_group_type.id}
        }.to change(AgeGroupEntry, :count).by(1)
      end

      it "assigns a newly created age_group_entry as @age_group_entry" do
        post :create, {:age_group_entry => valid_attributes, :age_group_type_id => @age_group_type.id}
        assigns(:age_group_entry).should be_a(AgeGroupEntry)
        assigns(:age_group_entry).should be_persisted
      end

      it "redirects to the created age_group_entry" do
        post :create, {:age_group_entry => valid_attributes, :age_group_type_id => @age_group_type.id}
        response.should redirect_to(age_group_type_age_group_entries_path(@age_group_type))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved age_group_entry as @age_group_entry" do
        # Trigger the behavior that occurs when invalid params are submitted
        AgeGroupEntry.any_instance.stub(:valid?).and_return(false)
        AgeGroupEntry.any_instance.stub(:errors).and_return("something")
        post :create, {:age_group_entry => { "short_description" => "invalid value" }, :age_group_type_id => @age_group_type.id}
        assigns(:age_group_entry).should be_a_new(AgeGroupEntry)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        AgeGroupEntry.any_instance.stub(:valid?).and_return(false)
        AgeGroupEntry.any_instance.stub(:errors).and_return("something")
        post :create, {:age_group_entry => { "short_description" => "invalid value" }, :age_group_type_id => @age_group_type.id}
        response.should render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested age_group_entry" do
        age_group_entry = FactoryGirl.create(:age_group_entry)
        # Assuming there are no other age_group_entries in the database, this
        # specifies that the AgeGroupEntry created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        AgeGroupEntry.any_instance.should_receive(:update_attributes).with({ "short_description" => "mine" })
        put :update, {:id => age_group_entry.to_param, :age_group_entry => { "short_description" => "mine" }}
      end

      it "assigns the requested age_group_entry as @age_group_entry" do
        age_group_entry = FactoryGirl.create(:age_group_entry)
        put :update, {:id => age_group_entry.to_param, :age_group_entry => valid_attributes}
        assigns(:age_group_entry).should eq(age_group_entry)
      end

      it "redirects to the age_group_entry" do
        age_group_entry = FactoryGirl.create(:age_group_entry)
        put :update, {:id => age_group_entry.to_param, :age_group_entry => valid_attributes}
        response.should redirect_to(age_group_type_age_group_entries_path(age_group_entry.age_group_type))
      end
    end

    describe "with invalid params" do
      it "assigns the age_group_entry as @age_group_entry" do
        age_group_entry = FactoryGirl.create(:age_group_entry)
        # Trigger the behavior that occurs when invalid params are submitted
        AgeGroupEntry.any_instance.stub(:valid?).and_return(false)
        AgeGroupEntry.any_instance.stub(:errors).and_return("something")
        put :update, {:id => age_group_entry.to_param, :age_group_entry => { "short_description" => "invalid value" }}
        assigns(:age_group_entry).should eq(age_group_entry)
      end

      it "re-renders the 'edit' template" do
        age_group_entry = FactoryGirl.create(:age_group_entry)
        # Trigger the behavior that occurs when invalid params are submitted
        AgeGroupEntry.any_instance.stub(:valid?).and_return(false)
        AgeGroupEntry.any_instance.stub(:errors).and_return("something")
        put :update, {:id => age_group_entry.to_param, :age_group_entry => { "short_description" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested age_group_entry" do
      age_group_entry = FactoryGirl.create(:age_group_entry)
      expect {
        delete :destroy, {:id => age_group_entry.to_param}
      }.to change(AgeGroupEntry, :count).by(-1)
    end

    it "redirects to the age_group_entries list" do
      age_group_entry = FactoryGirl.create(:age_group_entry)
      delete :destroy, {:id => age_group_entry.to_param}
      response.should redirect_to(age_group_type_age_group_entries_path(age_group_entry.age_group_type))
    end
  end

end
