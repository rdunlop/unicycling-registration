require 'spec_helper'

describe ImportResultsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in @admin_user
    @competition = FactoryGirl.create(:timed_competition, uses_lane_assignments: true)
  end
  let(:import_result) { FactoryGirl.create(:import_result, :user => @admin_user, :competition => @competition) }

  # This should return the minimal set of attributes required to create a valid
  # ImportResult. As you add validations to ImportResult, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "details" => "100pts", "rank" => "1", "bib_number" => "123",  }
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
          post :create, {:import_result => valid_attributes, :user_id => @admin_user.id, :competition_id => @competition.id}
        }.to change(ImportResult, :count).by(1)
      end

      it "creates a new ImportResult with start_time" do
        post :create, {:import_result => valid_attributes.merge(is_start_time: true), :user_id => @admin_user.id, :competition_id => @competition.id}
        expect(ImportResult.last.is_start_time).to be_truthy
      end

      it "assigns a newly created import_result as @import_result" do
        post :create, {:import_result => valid_attributes, :user_id => @admin_user.id, :competition_id => @competition.id}
        assigns(:import_result).should be_a(ImportResult)
        assigns(:import_result).should be_persisted
      end

      it "redirects to the user's import_results" do
        post :create, {:import_result => valid_attributes, :user_id => @admin_user.id, :competition_id => @competition.id}
        response.should redirect_to(data_entry_user_competition_import_results_path(@admin_user, @competition, is_start_times: false))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved import_result as @import_result" do
        # Trigger the behavior that occurs when invalid params are submitted
        ImportResult.any_instance.stub(:save).and_return(false)
        post :create, {:import_result => { "raw_data" => "invalid value" }, :user_id => @admin_user.id, :competition_id => @competition.id}
        assigns(:import_result).should be_a_new(ImportResult)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        ImportResult.any_instance.stub(:save).and_return(false)
        post :create, {:import_result => { "raw_data" => "invalid value" }, :user_id => @admin_user.id, :competition_id => @competition.id}
        response.should render_template("data_entry")
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
        response.should redirect_to(data_entry_user_competition_import_results_path(@admin_user, @competition, is_start_times: import_result.is_start_time))
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
    before :each do
      request.env["HTTP_REFERER"] = data_entry_user_competition_import_results_path(@admin_user, @competition)
    end
    it "destroys the requested import_result" do
      im_result = FactoryGirl.create(:import_result, :user => @admin_user, :competition => @competition)
      expect {
        delete :destroy, {:id => im_result.to_param}
      }.to change(ImportResult, :count).by(-1)
    end

    it "redirects to the import_results list" do
      delete :destroy, {:id => import_result.to_param}
      response.should redirect_to(data_entry_user_competition_import_results_path(@admin_user, @competition))
    end
  end

  describe "POST approve" do
    it "redirects to the competitions' results page" do
      competition = FactoryGirl.create(:timed_competition)
      reg = FactoryGirl.create(:competitor)
      import = FactoryGirl.create(:import_result, :competition => competition, bib_number: reg.bib_number)
      post :approve, {:user_id => import.user, :competition_id => competition.id}
      response.should redirect_to(result_competition_path(competition))
    end
  end

  describe "DELETE destroy_all" do
    it "redirects to the import competition page" do
      competition = FactoryGirl.create(:timed_competition)
      import = FactoryGirl.create(:import_result, :competition => competition)
      request.env["HTTP_REFERER"] = data_entry_user_competition_import_results_path(import.user, competition)
      delete :destroy_all, {:user_id => import.user, :competition_id => competition.id}
      response.should redirect_to(data_entry_user_competition_import_results_path(import.user, competition))
    end
  end
end
