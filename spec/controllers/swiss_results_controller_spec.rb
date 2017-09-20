require 'spec_helper'

describe SwissResultsController do
  before(:each) do
    @competition = FactoryGirl.create(:timed_competition, uses_lane_assignments: true)
    director = FactoryGirl.create(:user)
    director.add_role(:director, @competition.event)
    @user = director
    sign_in director
    @reg = FactoryGirl.create(:registrant)
    @competitor = FactoryGirl.create(:event_competitor, competition: @competition)
    @competitor.members.first.update_attribute(:registrant_id, @reg.id)
    @lane_assignment = FactoryGirl.create(:lane_assignment, competition: @competition, competitor: @competitor)
  end

  describe "GET index" do
    before { get :index, params: { user_id: @user.id, competition_id: @competition.id } }

    it "renders" do
      expect(response).to be_success
    end
  end

  describe "POST import" do
    describe "with valid params" do
      let(:test_file_name) { fixture_path + "/swiss_heat.tsv" }
      let(:test_file) { Rack::Test::UploadedFile.new(test_file_name, "text/plain") }

      it "calls the creator" do
        allow_any_instance_of(Importers::SwissResultImporter).to receive(:process).and_return(true)
        post :import, params: { heat: 1, heats: "on", user_id: @user.id, competition_id: @competition.id, file: test_file }

        expect(flash[:notice]).to match(/Successfully imported/)
      end
    end

    describe "with invalid params" do
      describe "when the file is missing" do
        def do_action
          post :import, params: { user_id: @user.id, heat: 1, competition_id: @competition.id, file: nil }
        end

        it "returns an error" do
          do_action
          assert_match(/Please specify a file/, flash[:alert])
        end
      end
    end
  end

  describe "POST approve" do
    describe "with valid params" do
      it "calls the creator" do
        post :approve, params: { user_id: @user.id, competition_id: @competition.id }

        expect(flash[:notice]).to match(/Added 0 rows to Competition/)
      end
    end
  end

  describe "PUT #dq_single" do
    let!(:result) { FactoryGirl.create(:time_result, competitor: @competitor) }

    it "removes all heat lane rsults" do
      put :dq_single, params: { user_id: @user.id, competition_id: @competition.id, swiss_result_id: result.id }
      expect(result.reload.status).to eq("DQ")
    end
  end
end
