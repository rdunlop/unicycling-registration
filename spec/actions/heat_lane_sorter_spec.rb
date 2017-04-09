require 'spec_helper'

describe HeatLaneSorter do
  let(:competition) { FactoryGirl.create(:timed_competition) }
  let!(:lane_1_1) { FactoryGirl.create(:lane_assignment, heat: 1, lane: 1, competition: competition) }
  let!(:lane_1_2) { FactoryGirl.create(:lane_assignment, heat: 1, lane: 2, competition: competition) }
  let!(:lane_1_3) { FactoryGirl.create(:lane_assignment, heat: 1, lane: 3, competition: competition) }
  let!(:lane_1_4) { FactoryGirl.create(:lane_assignment, heat: 1, lane: 4, competition: competition) }
  let!(:lane_2_1) { FactoryGirl.create(:lane_assignment, heat: 2, lane: 1, competition: competition) }
  let!(:lane_2_2) { FactoryGirl.create(:lane_assignment, heat: 2, lane: 2, competition: competition) }
  let!(:lane_2_3) { FactoryGirl.create(:lane_assignment, heat: 2, lane: 3, competition: competition) }
  let!(:lane_2_4) { FactoryGirl.create(:lane_assignment, heat: 2, lane: 4, competition: competition) }

  let(:new_lanes) do
    [
      lane_1_1.id,
      lane_1_2.id,
      lane_1_3.id,
      lane_2_1.id,
      lane_2_2.id,
      lane_2_3.id,
      lane_1_4.id, # moved to end of list
      lane_2_4.id
    ]
  end

  before do
    subject.sort
  end

  context "When moving lanes" do
    let(:subject) { described_class.new(new_lanes) }

    it "renumbers to new position" do
      expect(lane_2_1.reload.heat).to eq(1)
      expect(lane_2_1.reload.lane).to eq(4)
      expect(lane_1_4.reload.heat).to eq(2)
      expect(lane_1_4.reload.lane).to eq(3)
    end
  end

  context "when moving lanes" do
    let(:subject) { described_class.new(new_lanes, move_lane: true) }

    it "renumbers to new position" do
      expect(lane_2_1.reload.heat).to eq(2)
      expect(lane_2_1.reload.lane).to eq(1)
      expect(lane_1_4.reload.heat).to eq(2)
      expect(lane_1_4.reload.lane).to eq(3)
    end
  end
end
