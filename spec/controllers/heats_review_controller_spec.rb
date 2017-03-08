require 'spec_helper'

describe HeatReviewController do
  before(:each) do
    @competition = FactoryGirl.create(:timed_competition, uses_lane_assignments: true)
    director = FactoryGirl.create(:user)
    director.add_role(:director, @competition.event)
    sign_in director
    @reg = FactoryGirl.create(:registrant)
    @competitor = FactoryGirl.create(:event_competitor, competition: @competition)
    @competitor.members.first.update_attribute(:registrant_id, @reg.id)
    @lane_assignment = FactoryGirl.create(:lane_assignment, competition: @competition, competitor: @competitor)
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
      expect(response).to be_success
    end
  end

  describe "POST import_lif" do
    describe "with valid params" do
      let(:test_file) { "stubbed" }

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
    let!(:result) { FactoryGirl.create(:heat_lane_result, competition: @competition) }

    it "removes all heat lane rsults" do
      expect do
        delete :destroy, params: { competition_id: @competition.id, heat: result.heat }
      end.to change(HeatLaneResult, :count).by(-1)
    end
  end
end
