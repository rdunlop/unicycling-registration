require 'spec_helper'

describe ImportResultsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in @admin_user
    @competition = FactoryGirl.create(:competition)
  end
  let (:import_result) { FactoryGirl.create(:import_result, :user => @admin_user) }

  # This should return the minimal set of attributes required to create a valid
  # ImportResult. As you add validations to ImportResult, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "raw_data" => "MyString",
     "competition_id" => @competition.id}
  end

  describe "GET index" do
    it "assigns all import_results as @import_results" do
      im_result = FactoryGirl.create(:import_result, :user => @admin_user)
      get :index, {:user_id => @admin_user.id}
      assigns(:import_results).should eq([im_result])
    end
  end

  describe "GET edit" do
    it "assigns the requested import_result as @import_result" do
      get :edit, {:id => import_result.to_param}
      assigns(:import_result).should eq(import_result)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ImportResult" do
        expect {
          post :create, {:import_result => valid_attributes, :user_id => @admin_user.id}
        }.to change(ImportResult, :count).by(1)
      end

      it "assigns a newly created import_result as @import_result" do
        post :create, {:import_result => valid_attributes, :user_id => @admin_user.id}
        assigns(:import_result).should be_a(ImportResult)
        assigns(:import_result).should be_persisted
      end

      it "redirects to the user's import_results" do
        post :create, {:import_result => valid_attributes, :user_id => @admin_user.id}
        response.should redirect_to(user_import_results_path(@admin_user))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved import_result as @import_result" do
        # Trigger the behavior that occurs when invalid params are submitted
        ImportResult.any_instance.stub(:save).and_return(false)
        post :create, {:import_result => { "raw_data" => "invalid value" }, :user_id => @admin_user.id}
        assigns(:import_result).should be_a_new(ImportResult)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ImportResult.any_instance.stub(:save).and_return(false)
        post :create, {:import_result => { "raw_data" => "invalid value" }, :user_id => @admin_user.id}
        response.should render_template("index")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested import_result" do
        # Assuming there are no other import_results in the database, this
        # specifies that the ImportResult created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        ImportResult.any_instance.should_receive(:update_attributes).with({ "raw_data" => "MyString" })
        put :update, {:id => import_result.to_param, :import_result => { "raw_data" => "MyString" }}
      end

      it "assigns the requested import_result as @import_result" do
        put :update, {:id => import_result.to_param, :import_result => valid_attributes}
        assigns(:import_result).should eq(import_result)
      end

      it "redirects to the import_result" do
        put :update, {:id => import_result.to_param, :import_result => valid_attributes}
        response.should redirect_to(user_import_results_path(@admin_user))
      end
    end

    describe "with invalid params" do
      it "assigns the import_result as @import_result" do
        # Trigger the behavior that occurs when invalid params are submitted
        ImportResult.any_instance.stub(:save).and_return(false)
        put :update, {:id => import_result.to_param, :import_result => { "raw_data" => "invalid value" }}
        assigns(:import_result).should eq(import_result)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ImportResult.any_instance.stub(:save).and_return(false)
        put :update, {:id => import_result.to_param, :import_result => { "raw_data" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested import_result" do
      im_result = FactoryGirl.create(:import_result, :user => @admin_user)
      expect {
        delete :destroy, {:id => im_result.to_param}
      }.to change(ImportResult, :count).by(-1)
    end

    it "redirects to the import_results list" do
      delete :destroy, {:id => import_result.to_param}
      response.should redirect_to(user_import_results_path(@admin_user))
    end
  end

end
