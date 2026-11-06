# == Schema Information
#
# Table name: lane_assignments
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  heat           :integer
#  lane           :integer
#  created_at     :datetime
#  updated_at     :datetime
#  competitor_id  :integer
#
# Indexes
#
#  index_lane_assignments_on_competition_id                    (competition_id)
#  index_lane_assignments_on_competition_id_and_heat_and_lane  (competition_id,heat,lane) UNIQUE
#

require 'spec_helper'

describe HeatsController do
  before do
    @competition = FactoryBot.create(:timed_competition, uses_lane_assignments: true)
    director = FactoryBot.create(:user)
    director.add_role(:director, @competition.event)
    sign_in director
    @reg = FactoryBot.create(:registrant)
    @competitor = FactoryBot.create(:event_competitor, competition: @competition)
    @competitor.members.first.update_attribute(:registrant_id, @reg.id)
  end

  describe "GET index" do
    before do
      allow_any_instance_of(Competitor).to receive(:best_time).and_return("2:20")
      get :index, params: { competition_id: @competition.id }
    end

    it "shows all competitors" do
      assert_select "td", @competitor.age.to_s
    end

    it "displays the best time for each competitor" do
      assert_select "td", "2:20"
    end
  end

  describe "GET new" do
    it "shows the requested lane_assignment form" do
      get :new, params: { competition_id: @competition.id }
      expect(response).to be_successful
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "calls the heat assignment creatorcreates" do
        allow_any_instance_of(HeatAssignmentCreator).to receive(:perform).and_return(true)
        post :create, params: { lanes: 1, competition_id: @competition.id, lane_order: "1 2 3 4 5 6 7 8" }

        expect(flash[:notice]).to match(/Created Heats/)
      end
    end

    describe "with invalid params" do
      describe "when the lane_number is invalid" do
        def do_action
          post :create, params: { competition_id: @competition.id, lanes: 0, lane_order: "1 2 3 4 5 6 7 8" }
        end

        it "returns an error" do
          do_action
          expect(flash[:alert]).to match(/Invalid number of lanes/)
        end

        it "doesn't change the number of lane assignments" do
          expect do
            do_action
          end.not_to change(LaneAssignment, :count)
        end
      end

      describe "when there are existing lane assignments" do
        before { allow_any_instance_of(Competition).to receive(:lane_assignments).and_return(["thing"]) }

        it "returns an error" do
          post :create, params: { competition_id: @competition.id, lanes: 5, lane_order: "1 2 3 4 5 6 7 8" }
          expect(flash[:alert]).to match(/Cannot auto-assign with existing Lane Assignments/)
        end
      end
    end
  end

  describe "with combined age groups" do
    let!(:entry_1) { FactoryBot.create(:age_group_entry, age_group_type: @competition.age_group_type, start_age: 0, end_age: 10) }
    let!(:entry_2) { FactoryBot.create(:age_group_entry, age_group_type: @competition.age_group_type, start_age: 11, end_age: 20) }
    let(:other_competitor) { FactoryBot.create(:event_competitor, competition: @competition) }
    let(:combination) { @competition.age_group_combinations.first }
    let!(:lane_assignment) { FactoryBot.create(:lane_assignment, competitor: @competitor, competition: @competition, heat: 1, lane: 1) }
    let!(:other_lane_assignment) { FactoryBot.create(:lane_assignment, competitor: other_competitor, competition: @competition, heat: 1, lane: 2) }

    before do
      @competitor.update_column(:age_group_entry_id, entry_1.id)
      other_competitor.update_column(:age_group_entry_id, entry_2.id)
      new_combination = @competition.age_group_combinations.create!
      new_combination.age_group_combination_entries.create!(age_group_entry: entry_1)
      new_combination.age_group_combination_entries.create!(age_group_entry: entry_2)
    end

    describe "GET set_sort" do
      render_views

      it "lists the lane assignments of every entry of the combination" do
        get :set_sort, params: { competition_id: @competition.id, age_group_id: combination.to_age_group_param }

        expect(response).to be_successful
        expect(response.body).to include("age_group_entry_#{lane_assignment.id}", "age_group_entry_#{other_lane_assignment.id}")
      end

      it "does not find a combined entry on its own" do
        expect do
          get :set_sort, params: { competition_id: @competition.id, age_group_id: entry_1.to_age_group_param }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "POST sort" do
      it "accepts the combination" do
        post :sort, params: { competition_id: @competition.id, age_group_id: combination.to_age_group_param, age_group_entry: [lane_assignment.id, other_lane_assignment.id] }, format: :js

        expect(response).to be_successful
      end
    end
  end

  describe "#destroy_all" do
    before { FactoryBot.create(:lane_assignment, competitor: @competitor, competition: @competition) }

    it "removes all lane assignments" do
      expect do
        delete :destroy_all, params: { competition_id: @competition.id }
      end.to change(LaneAssignment, :count).by(-1)
    end
  end
end
