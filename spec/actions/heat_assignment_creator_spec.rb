require 'spec_helper'

describe HeatAssignmentCreator do
  let(:competition) { FactoryBot.create(:timed_competition) }
  let(:event) { competition.event }
  let(:age_group_type) { competition.age_group_type }
  let(:lanes) { 2 }
  let!(:competitor1) { FactoryBot.create(:event_competitor, competition: competition) }
  let!(:competitor2) { FactoryBot.create(:event_competitor, competition: competition) }
  let!(:competitor3) { FactoryBot.create(:event_competitor, competition: competition) }

  def perform
    calculator = HeatLaneCalculator.new(lanes)
    described_class.new(competition, calculator).perform
  end

  describe "with no age groups" do
    it "doesn't create any lane assignments" do
      expect { perform }.not_to change(LaneAssignment, :count)
    end
  end

  describe "with a single age group" do
    let!(:age_group_entry) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type) }

    before do
      competition.reload # to load the age_group_entries
    end

    it "assigns the competitors by their returned order" do
      expect { perform }.to change(LaneAssignment, :count).by(3)
      competitor1_lane_assignment = LaneAssignment.find_by(competitor: competitor1)
      expect(competitor1_lane_assignment.heat).to eq(1)
      expect(competitor1_lane_assignment.lane).to eq(2)

      competitor2_lane_assignment = LaneAssignment.find_by(competitor: competitor2)
      expect(competitor2_lane_assignment.heat).to eq(1)
      expect(competitor2_lane_assignment.lane).to eq(1)

      competitor3_lane_assignment = LaneAssignment.find_by(competitor: competitor3)
      expect(competitor3_lane_assignment.heat).to eq(2)
      expect(competitor3_lane_assignment.lane).to eq(1)
    end

    describe "when all competitors have best times" do
      before do
        FactoryBot.create(:registrant_best_time, registrant: competitor1.registrants.first, value: 300)
        FactoryBot.create(:registrant_best_time, registrant: competitor2.registrants.first, value: 200)
        FactoryBot.create(:registrant_best_time, registrant: competitor3.registrants.first, value: 100)
      end

      it "assigns in descending order of best times" do
        perform
        competitor1_lane_assignment = LaneAssignment.find_by(competitor: competitor1)
        competitor2_lane_assignment = LaneAssignment.find_by(competitor: competitor2)
        competitor3_lane_assignment = LaneAssignment.find_by(competitor: competitor3)
        expect(competitor1_lane_assignment.heat).to eq(1)
        expect(competitor1_lane_assignment.lane).to eq(2)

        expect(competitor2_lane_assignment.heat).to eq(1)
        expect(competitor2_lane_assignment.lane).to eq(1)

        expect(competitor3_lane_assignment.heat).to eq(2)
        expect(competitor3_lane_assignment.lane).to eq(1)
      end
    end

    describe "when only some competitors have best times" do
      before do
        FactoryBot.create(:registrant_best_time, registrant: competitor1.registrants.first, value: 300, event: event)
        FactoryBot.create(:registrant_best_time, registrant: competitor2.registrants.first, value: 200, event: event)
      end

      it "assigns those without best times first" do
        perform

        competitor1_lane_assignment = LaneAssignment.find_by(competitor: competitor1)
        competitor2_lane_assignment = LaneAssignment.find_by(competitor: competitor2)
        competitor3_lane_assignment = LaneAssignment.find_by(competitor: competitor3)
        expect(competitor3_lane_assignment.heat).to eq(1)
        expect(competitor3_lane_assignment.lane).to eq(2)

        expect(competitor1_lane_assignment.heat).to eq(1)
        expect(competitor1_lane_assignment.lane).to eq(1)

        expect(competitor2_lane_assignment.heat).to eq(2)
        expect(competitor2_lane_assignment.lane).to eq(1)
      end
    end
  end

  xdescribe "with 2 age groups" do
  end
end
