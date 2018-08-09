# == Schema Information
#
# Table name: import_results
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  raw_data            :string(255)
#  bib_number          :integer
#  minutes             :integer
#  seconds             :integer
#  thousands           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  competition_id      :integer
#  points              :decimal(6, 3)
#  details             :string(255)
#  is_start_time       :boolean          default(FALSE), not null
#  number_of_laps      :integer
#  status              :string(255)
#  comments            :text
#  comments_by         :string(255)
#  heat                :integer
#  lane                :integer
#  number_of_penalties :integer
#
# Indexes
#
#  index_import_results_on_user_id  (user_id)
#  index_imported_results_user_id   (user_id)
#

require 'spec_helper'

describe ImportResultsController do
  before(:each) do
    @admin_user = FactoryBot.create(:super_admin_user)
    sign_in @admin_user
    @competition = FactoryBot.create(:timed_competition, uses_lane_assignments: true)
  end
  let(:import_result) { FactoryBot.create(:import_result, user: @admin_user, competition: @competition) }

  # This should return the minimal set of attributes required to create a valid
  # ImportResult. As you add validations to ImportResult, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      details: "100pts",
      points: 1,
      bib_number: 123,
      minutes: 1,
      seconds: 2,
      thousands: 3
    }
  end

  describe "GET edit" do
    it "show the import_result form" do
      get :edit, params: { id: import_result.to_param }

      assert_select "form", action: import_result_path(import_result), method: "post" do
        assert_select "select#import_result_bib_number", name: "import_result[bib_number]"
        assert_select "input#import_result_minutes", name: "import_result[minutes]"
        assert_select "input#import_result_seconds", name: "import_result[seconds]"
        assert_select "input#import_result_thousands", name: "import_result[thousands]"
        assert_select "select#import_result_status", name: "import_result[status]"
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ImportResult" do
        expect do
          post :create, params: { import_result: valid_attributes, user_id: @admin_user.id, competition_id: @competition.id }
        end.to change(ImportResult, :count).by(1)
      end

      it "creates a new ImportResult with start_time" do
        post :create, params: { import_result: valid_attributes.merge(is_start_time: true), user_id: @admin_user.id, competition_id: @competition.id }
        expect(ImportResult.last.is_start_time).to be_truthy
      end

      it "redirects to the user's import_results" do
        post :create, params: { import_result: valid_attributes, user_id: @admin_user.id, competition_id: @competition.id }
        expect(response).to redirect_to(data_entry_user_competition_import_results_path(@admin_user, @competition, is_start_times: false))
      end
    end

    describe "with invalid params" do
      it "does not create a new import_result" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ImportResult).to receive(:save).and_return(false)
        expect do
          post :create, params: { import_result: { "raw_data" => "invalid value" }, user_id: @admin_user.id, competition_id: @competition.id }
        end.not_to change(ImportResult, :count)
      end

      it "re-renders the 'index' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ImportResult).to receive(:save).and_return(false)
        post :create, params: { import_result: { "raw_data" => "invalid value" }, user_id: @admin_user.id, competition_id: @competition.id }
        assert_select "h1", "Data Recording Form - Entry Form (One Attempt per line)"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested import_result" do
        expect do
          put :update, params: { id: import_result.to_param, import_result: valid_attributes.merge(bib_number: 1211) }
        end.to change { import_result.reload.bib_number }
      end

      it "redirects to the import_result" do
        put :update, params: { id: import_result.to_param, import_result: valid_attributes }
        expect(response).to redirect_to(data_entry_user_competition_import_results_path(@admin_user, @competition, is_start_times: import_result.is_start_time))
      end
    end

    describe "with invalid params" do
      it "does not update the import_result" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ImportResult).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: import_result.to_param, import_result: { raw_data: "invalid value" } }
        end.not_to change { import_result.reload.raw_data }
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ImportResult).to receive(:save).and_return(false)
        put :update, params: { id: import_result.to_param, import_result: { raw_data: "invalid value" } }
        assert_select "h1", "Editing import_result"
      end
    end
  end

  describe "DELETE destroy" do
    before :each do
      request.env["HTTP_REFERER"] = data_entry_user_competition_import_results_path(@admin_user, @competition)
    end
    it "destroys the requested import_result" do
      im_result = FactoryBot.create(:import_result, user: @admin_user, competition: @competition)
      expect do
        delete :destroy, params: { id: im_result.to_param }
      end.to change(ImportResult, :count).by(-1)
    end

    it "redirects to the import_results list" do
      delete :destroy, params: { id: import_result.to_param }
      expect(response).to redirect_to(data_entry_user_competition_import_results_path(@admin_user, @competition))
    end
  end

  describe "POST approve" do
    it "redirects to the competitions' results page" do
      competition = FactoryBot.create(:timed_competition)
      reg = FactoryBot.create(:competitor)
      @config = FactoryBot.create(:event_configuration, :with_usa)
      import = FactoryBot.create(:import_result, competition: competition, bib_number: reg.bib_number)
      request.env["HTTP_REFERER"] = data_entry_user_competition_import_results_path(import.user, competition)
      post :approve, params: { user_id: import.user, competition_id: competition.id }
      expect(response).to redirect_to(data_entry_user_competition_import_results_path(import.user, competition))
    end
  end

  describe "DELETE destroy_all" do
    it "redirects to the import competition page" do
      competition = FactoryBot.create(:timed_competition)
      import = FactoryBot.create(:import_result, competition: competition)
      request.env["HTTP_REFERER"] = data_entry_user_competition_import_results_path(import.user, competition)
      delete :destroy_all, params: { user_id: import.user, competition_id: competition.id }
      expect(response).to redirect_to(data_entry_user_competition_import_results_path(import.user, competition))
    end
  end

  describe "GET display_chip" do
    context "when the data includes registrants which exist" do
    end

    context "when the data includes a registrant ID which we don't have" do
      let(:competition) { FactoryBot.create(:timed_competition, import_results_into_other_competition: true) }
      let!(:import_result) { FactoryBot.create(:import_result, bib_number: "123", competition: competition) }

      it "displays the page" do
        get :display_chip, params: { competition_id: competition.id, user_id: import_result.user }
        expect(response).to be_successful
      end
    end
  end
end
