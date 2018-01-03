# == Schema Information
#
# Table name: two_attempt_entries
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  competition_id :integer
#  bib_number     :integer
#  minutes_1      :integer
#  minutes_2      :integer
#  seconds_1      :integer
#  status_1       :string(255)      default("active")
#  seconds_2      :integer
#  thousands_1    :integer
#  thousands_2    :integer
#  status_2       :string(255)      default("active")
#  is_start_time  :boolean          default(FALSE), not null
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  index_two_attempt_entries_ids  (competition_id,is_start_time,id)
#

require 'spec_helper'

describe TwoAttemptEntriesController do
  before(:each) do
    @admin_user = FactoryGirl.create(:super_admin_user)
    sign_in @admin_user
    @competition = FactoryGirl.create(:timed_competition, uses_lane_assignments: true)
  end
  let(:two_attempt_entry) { FactoryGirl.create(:two_attempt_entry, user: @admin_user, competition: @competition) }

  def valid_attributes
    {
      bib_number: 123,
      is_start_time: false,
      first_attempt: {
        facade_hours: 0,
        facade_minutes: 20,
        facade_hundreds: 30
      },
      second_attempt: {
        facade_hours: 1,
        facade_minutes: 30,
        facade_hundreds: 40
      }
    }
  end

  describe "GET index" do
    it "renders" do
      get :index, params: { user_id: @admin_user.id, competition_id: @competition }
      expect(response).to be_success
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new TwoAttemptEntry" do
        expect do
          post :create, xhr: true, params: { two_attempt_entry: valid_attributes, user_id: @admin_user.id, competition_id: @competition.id }
        end.to change(TwoAttemptEntry, :count).by(1)
      end

      it "creates a new TwoAttemptEntry with start_time" do
        post :create, xhr: true, params: { two_attempt_entry: valid_attributes.merge(is_start_time: true), user_id: @admin_user.id, competition_id: @competition.id }
        expect(TwoAttemptEntry.last.is_start_time).to be_truthy
      end

      it "redirects to the user's two_attempt_entrys" do
        post :create, xhr: true, params: { two_attempt_entry: valid_attributes, user_id: @admin_user.id, competition_id: @competition.id }
        expect(response).to be_success
      end
    end

    describe "with invalid params" do
      it "does not create a new two_attempt_entry" do
        # Trigger the behavior that occurs when invalid params are submitted
        # allow_any_instance_of(TwoAttemptEntry).to receive(:save).and_return(false)
        expect do
          post :create, xhr: true, params: { two_attempt_entry: { "raw_data" => "invalid value" }, user_id: @admin_user.id, competition_id: @competition.id }
        end.not_to change(TwoAttemptEntry, :count)
      end
    end
  end

  describe "GET display_csv" do
    it "renders" do
      get :display_csv, params: { user_id: @admin_user.id, competition_id: @competition.id }
      expect(response).to be_success
    end
  end

  describe "GET proof" do
    it "renders" do
      get :proof, params: { user_id: @admin_user.id, competition_id: @competition.id }
      expect(response).to be_success
    end
  end

  describe "POST approve" do
    it "redirects to the competitions' results page" do
      competition = FactoryGirl.create(:timed_competition)
      reg = FactoryGirl.create(:competitor)
      @config = FactoryGirl.create(:event_configuration, :with_usa)
      import = FactoryGirl.create(:two_attempt_entry, competition: competition, bib_number: reg.bib_number)
      request.env["HTTP_REFERER"] = data_entry_user_competition_import_results_path(import.user, competition)
      post :approve, params: { user_id: import.user, competition_id: competition.id }
      expect(response).to redirect_to(data_entry_user_competition_import_results_path(import.user, competition))
    end
  end

  describe "POST import" do
    let(:competition) { FactoryGirl.create(:timed_competition) }
    let(:reg) { FactoryGirl.create(:competitor) }
    let(:import) { FactoryGirl.create(:two_attempt_entry, competition: competition, bib_number: reg.bib_number) }

    describe "with valid params" do
      let(:test_file_name) { fixture_path + "/swiss_heat.tsv" }
      let(:test_file) { Rack::Test::UploadedFile.new(test_file_name, "text/plain") }

      it "calls the creator" do
        allow_any_instance_of(Importers::TwoAttemptEntryImporter).to receive(:process).and_return(true)
        post :import_csv, params: { user_id: import.user.id, competition_id: @competition.id, file: test_file }

        expect(flash[:notice]).to match(/Successfully imported/)
      end
    end

    describe "with invalid params" do
      describe "when the file is missing" do
        def do_action
          post :import_csv, params: { user_id: import.user.id, competition_id: @competition.id, file: nil }
        end

        it "returns an error" do
          do_action
          assert_match(/Please specify a file/, flash[:alert])
        end
      end
    end
  end

  describe "GET edit" do
    it "show the two_attempt_entry form" do
      get :edit, params: { id: two_attempt_entry.to_param }

      assert_select "form", action: two_attempt_entry_path(two_attempt_entry), method: "post" do
        assert_select "select#two_attempt_entry_bib_number", name: "two_attempt_entry[bib_number]"
        assert_select "input#two_attempt_entry_first_attempt_minutes", name: "two_attempt_entry[first_attempt][minutes]"
        assert_select "input#two_attempt_entry_first_attempt_seconds", name: "two_attempt_entry[first_attempt][seconds]"
        assert_select "input#two_attempt_entry_first_attempt_thousands", name: "two_attempt_entry[first_attempt][thousands]"
        assert_select "select#two_attempt_entry_first_attempt_status", name: "two_attempt_entry[first_attempt][status]"
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested two_attempt_entry" do
        expect do
          put :update, params: { id: two_attempt_entry.to_param, two_attempt_entry: valid_attributes.merge(bib_number: 1211) }
        end.to change { two_attempt_entry.reload.bib_number }
      end

      it "redirects to the two_attempt_entry" do
        put :update, params: { id: two_attempt_entry.to_param, two_attempt_entry: valid_attributes }
        expect(response).to redirect_to(user_competition_two_attempt_entries_path(@admin_user, @competition, is_start_times: two_attempt_entry.is_start_time))
      end
    end

    describe "with invalid params" do
      it "does not update the two_attempt_entry" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TwoAttemptEntry).to receive(:save).and_return(false)
        expect do
          put :update, params: { id: two_attempt_entry.to_param, two_attempt_entry: { first_attempt: { status: "invalid value" } } }
        end.not_to change { two_attempt_entry.reload.status_1 }
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TwoAttemptEntry).to receive(:save).and_return(false)
        put :update, params: { id: two_attempt_entry.to_param, two_attempt_entry: { first_attempt: { status: "invalid value" } } }
        assert_select "h1", "Editing two attempt entry"
      end
    end
  end

  describe "DELETE destroy" do
    before :each do
      request.env["HTTP_REFERER"] = data_entry_user_competition_import_results_path(@admin_user, @competition)
    end
    it "destroys the requested two_attempt_entry" do
      im_result = FactoryGirl.create(:two_attempt_entry, user: @admin_user, competition: @competition)
      expect do
        delete :destroy, params: { id: im_result.to_param }
      end.to change(TwoAttemptEntry, :count).by(-1)
    end

    it "redirects to the two_attempt_entrys list" do
      delete :destroy, params: { id: two_attempt_entry.to_param }
      expect(response).to redirect_to(data_entry_user_competition_import_results_path(@admin_user, @competition))
    end
  end
end
