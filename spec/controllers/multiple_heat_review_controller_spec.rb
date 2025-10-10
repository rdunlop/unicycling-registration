require 'spec_helper'

describe MultipleHeatReviewController do
  before do
    @competition = FactoryBot.create(:timed_competition, uses_lane_assignments: true)
    director = FactoryBot.create(:user)
    director.add_role(:director, @competition.event)
    sign_in director
    @reg = FactoryBot.create(:registrant)
    @competitor = FactoryBot.create(:event_competitor, competition: @competition)
    @competitor.members.first.update_attribute(:registrant_id, @reg.id)
    @lane_assignment = FactoryBot.create(:lane_assignment, competition: @competition, competitor: @competitor)
  end

  describe "GET index" do
    before { get :index, params: { competition_id: @competition.id } }

    it do
      header = "Review Data for #{@competition.name}"
      assert_select "h1", text: header
    end
  end

  describe "POST import_lif_files" do
    describe "with valid params" do
      let(:test_file_name) { "#{fixture_path}/test2.lif" }
      let(:test_file) { Rack::Test::UploadedFile.new(test_file_name, "text/plain") }

      it "calls the creator" do
        allow_any_instance_of(Importers::HeatLaneLifImporter).to receive(:process).and_return(true)
        post :import_lif_files, params: { competition_id: @competition.id, files: [test_file] }

        expect(flash[:notice]).to match(/Successfully imported/)
      end
    end

    describe "with invalid params" do
      describe "when the file is missing" do
        def do_action
          post :import_lif_files, params: { competition_id: @competition.id, file: nil }
        end

        it "returns an error" do
          do_action
          assert_match(/Please specify at least a file/, flash[:alert])
        end
      end
    end
  end

  describe "POST approve_results" do
    describe "with valid params" do
      let(:test_file) { "stubbed" }

      it "calls the creator" do
        post :approve_results, params: { competition_id: @competition.id }

        expect(flash[:notice]).to match(/Added results/)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:result) { FactoryBot.create(:heat_lane_result, competition: @competition) }

    it "removes all heat lane results" do
      expect do
        delete :destroy, params: { competition_id: @competition.id }
      end.to change(HeatLaneResult, :count).by(-1)
    end
  end
end
