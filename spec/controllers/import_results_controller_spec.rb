require 'spec_helper'

describe ImportResultsController do
  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in @admin_user
    @competition = FactoryGirl.create(:timed_competition)
  end
  let(:import_result) { FactoryGirl.create(:import_result, :user => @admin_user, :competition => @competition) }

  # This should return the minimal set of attributes required to create a valid
  # ImportResult. As you add validations to ImportResult, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    { "raw_data" => "MyString" }
  end

  describe "GET index" do
    it "assigns all import_results as @import_results" do
      im_result = FactoryGirl.create(:import_result, :user => @admin_user, :competition => @competition)
      get :index, {:user_id => @admin_user.id, :competition_id => @competition.id}
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
          post :create, {:import_result => valid_attributes, :user_id => @admin_user.id, :competition_id => @competition.id}
        }.to change(ImportResult, :count).by(1)
      end

      it "creates a new ImportResult with start_time" do
        post :create, {:import_result => valid_attributes.merge(:is_start_time => true), :user_id => @admin_user.id, :competition_id => @competition.id}
        expect(ImportResult.last.is_start_time).to be_truthy
      end

      it "assigns a newly created import_result as @import_result" do
        post :create, {:import_result => valid_attributes, :user_id => @admin_user.id, :competition_id => @competition.id}
        assigns(:import_result).should be_a(ImportResult)
        assigns(:import_result).should be_persisted
      end

      it "redirects to the user's import_results" do
        post :create, {:import_result => valid_attributes, :user_id => @admin_user.id, :competition_id => @competition.id}
        response.should redirect_to(user_competition_import_results_path(@admin_user, @competition))
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
        response.should redirect_to(user_competition_import_results_path(@admin_user, @competition))
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
      im_result = FactoryGirl.create(:import_result, :user => @admin_user, :competition => @competition)
      expect {
        delete :destroy, {:id => im_result.to_param}
      }.to change(ImportResult, :count).by(-1)
    end

    it "redirects to the import_results list" do
      delete :destroy, {:id => import_result.to_param}
      response.should redirect_to(user_competition_import_results_path(@admin_user, @competition))
    end
  end

 describe "when importing data" do
    it "creates a competitor" do
      @reg = FactoryGirl.create(:registrant, :bib_number => 101)
      test_image = fixture_path + '/sample_time_results_bib_101.txt'
      sample_input = Rack::Test::UploadedFile.new(test_image, "text/plain")

      post :import_csv, {:file => sample_input, :user_id => @admin_user.id, :competition_id => @competition.id}

      ImportResult.count.should == 1
      ir = ImportResult.first
      ir.bib_number.should == 101
      ir.minutes.should == 1
      ir.seconds.should == 2
      ir.thousands.should == 300
      ir.disqualified.should == false
      ir.competition.should == @competition
    end

    it "can import start times" do
      @reg = FactoryGirl.create(:registrant, :bib_number => 101)
      test_image = fixture_path + '/sample_time_results_bib_101.txt'
      sample_input = Rack::Test::UploadedFile.new(test_image, "text/plain")

      post :import_csv, {:file => sample_input, :user_id => @admin_user.id, :competition_id => @competition.id, :start_times => true}

      ImportResult.count.should == 1
      ir = ImportResult.first
      ir.is_start_time.should == true
    end

    it "creates a dq competitor" do
      @reg = FactoryGirl.create(:registrant, :bib_number => 101)
    end
    it "creates a dq competitor" do
      @reg = FactoryGirl.create(:registrant, :bib_number => 101)
      test_image = fixture_path + '/sample_time_results_bib_101_dq.txt'
      sample_input = Rack::Test::UploadedFile.new(test_image, "text/plain")

      post :import_csv, {:file => sample_input, :user_id => @admin_user.id, :competition_id => @competition.id}

      ImportResult.count.should == 1
      ImportResult.first.disqualified.should == true
    end

    it "can process lif files" do
      @reg = FactoryGirl.create(:registrant, :bib_number => 101)
      @competitor = FactoryGirl.create(:event_competitor, :competition => @competition)
      member = FactoryGirl.create(:member, :competitor => @competitor, :registrant => @reg)
      @lane_ass = FactoryGirl.create(:lane_assignment, :competition => @competition, :registrant => @reg, :heat => 1, :lane => 1)
      test_image = fixture_path + '/800m14.lif'
      sample_input = Rack::Test::UploadedFile.new(test_image, "text/plain")

      post :import_lif, {:file => sample_input, :user_id => @admin_user.id, :competition_id => @competition.id}

      response.should redirect_to(user_competition_import_results_path(@admin_user, @competition))
    end
  end


  describe "POST publish_to_competition" do
    it "redirects to the competitions' results page" do
      competition = FactoryGirl.create(:competition, :scoring_class => "Distance")
      import = FactoryGirl.create(:import_result, :competition => competition)
      post :publish_to_competition, {:user_id => import.user, :competition_id => competition.id}
      response.should redirect_to(scores_competition_path(competition))
    end
  end

  describe "DELETE destroy_all" do
    it "redirects to the import competition page" do
      competition = FactoryGirl.create(:competition, :scoring_class => "Distance")
      import = FactoryGirl.create(:import_result, :competition => competition)
      delete :destroy_all, {:user_id => import.user, :competition_id => competition.id}
      response.should redirect_to(user_competition_import_results_path(import.user, competition))
    end
  end
end
