require 'spec_helper'

describe HeatAssignmentCreator do
  let(:competition) { FactoryGirl.create(:timed_competition) }
  let(:event) { competition.event }
  let(:age_group_type) { competition.age_group_type }
  let(:lanes) { 2 }
  let!(:competitor1) { FactoryGirl.create(:event_competitor, competition: competition) }
  let!(:competitor2) { FactoryGirl.create(:event_competitor, competition: competition) }
  let!(:competitor3) { FactoryGirl.create(:event_competitor, competition: competition) }

  def perform
    described_class.new(competition, lanes).perform
  end

  describe "with no age groups" do
    it "doesn't create any lane assignments" do
      expect{ perform }.not_to change(LaneAssignment, :count)
    end
  end

  describe "with a single age group" do
    let!(:age_group_entry) { FactoryGirl.create(:age_group_entry, age_group_type: age_group_type) }

    it "assigns the competitors by their returned order" do
      expect{ perform }.to change(LaneAssignment, :count).by(3)
      expect(LaneAssignment.first.heat).to eq(1)
      expect(LaneAssignment.first.lane).to eq(1)
      expect(LaneAssignment.first.competitor).to eq(competitor1)

      expect(LaneAssignment.second.heat).to eq(1)
      expect(LaneAssignment.second.lane).to eq(2)
      expect(LaneAssignment.second.competitor).to eq(competitor2)

      expect(LaneAssignment.last.heat).to eq(2)
      expect(LaneAssignment.last.lane).to eq(1)
      expect(LaneAssignment.last.competitor).to eq(competitor3)
    end

    describe "when all competitors have best times" do
      before do
        FactoryGirl.create(:registrant_best_time, registrant: competitor1.registrants.first, value: 300)
        FactoryGirl.create(:registrant_best_time, registrant: competitor2.registrants.first, value: 200)
        FactoryGirl.create(:registrant_best_time, registrant: competitor3.registrants.first, value: 100)
      end
      it "assigns in descending order of best times" do
        perform
        expect(competitor1.lane_assignments.first.heat).to eq(1)
        expect(competitor1.lane_assignments.first.lane).to eq(1)

        expect(competitor2.lane_assignments.first.heat).to eq(1)
        expect(competitor2.lane_assignments.first.lane).to eq(2)

        expect(competitor3.lane_assignments.first.heat).to eq(2)
        expect(competitor3.lane_assignments.first.lane).to eq(1)
      end
    end

    describe "when only some competitors have best times" do
      before do
        FactoryGirl.create(:registrant_best_time, registrant: competitor1.registrants.first, value: 300, event: event)
        FactoryGirl.create(:registrant_best_time, registrant: competitor2.registrants.first, value: 200, event: event)
      end
      it "assigns those without best times first" do
        perform

        expect(competitor3.lane_assignments.first.heat).to eq(1)
        expect(competitor3.lane_assignments.first.lane).to eq(1)

        expect(competitor1.lane_assignments.first.heat).to eq(1)
        expect(competitor1.lane_assignments.first.lane).to eq(2)

        expect(competitor2.lane_assignments.first.heat).to eq(2)
        expect(competitor2.lane_assignments.first.lane).to eq(1)
      end
    end
  end

  xdescribe "with 2 age groups" do
  end
end
