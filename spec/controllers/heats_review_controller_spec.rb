require 'spec_helper'

describe HeatReviewController do
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

    it "assigns @max_heat" do
      assert_select "a", text: "Heat 1"
    end
  end

  describe "GET show" do
    before { get :show, params: { competition_id: @competition.id, heat: @lane_assignment.heat } }

    it do
      expect(response).to be_successful
    end
  end

  describe "POST import_lif" do
    describe "with valid params" do
      let(:test_file_name) { "#{fixture_path}/test2.lif" }
      let(:test_file) { Rack::Test::UploadedFile.new(test_file_name, "text/plain") }

      it "calls the creator" do
        allow_any_instance_of(Importers::HeatLaneLifImporter).to receive(:process).and_return(true)
        post :import_lif, params: { heat: 1, competition_id: @competition.id, file: test_file }

        expect(flash[:notice]).to match(/Successfully imported/)
      end
    end

    describe "with invalid params" do
      describe "when the file is missing" do
        def do_action
          post :import_lif, params: { heat: 1, competition_id: @competition.id, file: nil }
        end

        it "returns an error" do
          do_action
          assert_match(/Please specify a file/, flash[:alert])
        end
      end
    end
  end

  describe "POST import_lif_from_url" do
    describe "with valid params" do
      let(:test_file_name) { "#{fixture_path}/test2.lif" }

      it "calls the creator" do
        # Create a mock to avoid fetching a real file
        file_url = "https://example.com/heat-01.lif"
        test_file = []
        test_file.define_singleton_method(:path) do
          :test_file_name
        end
        allow(Down).to receive(:download).with(file_url).and_return(test_file)
        allow(FileUtils).to receive(:remove).with(test_file).and_return(nil)

        allow_any_instance_of(Importers::HeatLaneLifImporter).to receive(:process).and_return(true)
        post :import_lif_from_url, params: { heat: 1, competition_id: @competition.id, file_url: file_url }

        expect(flash[:notice]).to match(/Successfully imported/)
      end
    end

    describe "with invalid params" do
      describe "when the file URL is missing" do
        it "returns an error" do
          post :import_lif_from_url, params: { heat: 1, competition_id: @competition.id, file_url: nil }
          assert_match(/Please specify a file URL/, flash[:alert])
        end
      end

      describe "when the file does not exist" do
        it "returns an error" do
          file_url = "https://path-to-a-non-existing-file.uda.com"
          allow(Down).to receive(:download).with(file_url).and_throw(StandardError)

          post :import_lif_from_url, params: { heat: 1, competition_id: @competition.id, file_url: file_url }
          assert_match(/Error importing file. Does it exist at specified location/, flash[:alert])
        end
      end
    end
  end

  describe "POST approve_heat" do
    describe "with valid params" do
      let(:test_file) { "stubbed" }

      it "calls the creator" do
        post :approve_heat, params: { heat: 1, competition_id: @competition.id }

        expect(flash[:notice]).to match(/Added Heat/)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:result) { FactoryBot.create(:heat_lane_result, competition: @competition) }

    it "removes all heat lane rsults" do
      expect do
        delete :destroy, params: { competition_id: @competition.id, heat: result.heat }
      end.to change(HeatLaneResult, :count).by(-1)
    end
  end
end
