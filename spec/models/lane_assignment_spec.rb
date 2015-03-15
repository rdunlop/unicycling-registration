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

describe LaneAssignment do

  describe "with an existing lane assignment" do
    before(:each) do
      @la = FactoryGirl.create(:lane_assignment)
    end
    it "has a valid factory" do
      expect(@la.valid?).to eq(true)
    end

    it "must have a heat" do
      @la.heat = nil
      expect(@la.valid?).to eq(false)
    end

    it "cannot have the same heat/lane twice for a single competition" do
      la2 = FactoryGirl.build(:lane_assignment, :heat => @la.heat, :lane => @la.lane, :competition => @la.competition)
      expect(la2.valid?).to eq(false)
    end

    it "can have different lanes in the same heat/competition" do
      la2 = FactoryGirl.build(:lane_assignment, :heat => @la.heat, :lane => @la.lane + 1, :competition => @la.competition)
      expect(la2.valid?).to eq(true)
    end

    it "can have the same lane in different heats in the same competition" do
      la2 = FactoryGirl.build(:lane_assignment, :heat => @la.heat + 1, :lane => @la.lane, :competition => @la.competition)
      expect(la2.valid?).to eq(true)
    end
  end

  describe "When updating an existing lane assignment" do
    describe "when at NAUCC" do
      before :each do
        FactoryGirl.create(:event_configuration, :with_usa)
      end

      it "can save a new lane" do
        la = FactoryGirl.create(:lane_assignment)
        la.lane = 4
        expect(la.save).to be_truthy
      end
    end
  end

  describe "when creating a lane assignment from a registrant" do
    describe "when at NAUCC" do
      before :each do
        FactoryGirl.create(:event_configuration, :with_usa)
      end
      it "will create the competitor if it doesn't exist" do
        reg = FactoryGirl.create(:registrant)
        competition = FactoryGirl.create(:competition)
        @la = FactoryGirl.build(:lane_assignment, competitor: nil, registrant_id: reg.id, competition: competition)
        expect {
          @la.save
        }.to change(Competitor, :count).by(1)
      end

      it "can assign lane to existing competitor" do
        competition = FactoryGirl.create(:competition)
        competitor = FactoryGirl.create(:event_competitor, competition: competition)
        reg = competitor.members.first.registrant
        @la = FactoryGirl.build(:lane_assignment, competitor: nil, registrant_id: reg.id, competition: competition)
        expect {
          @la.save
        }.to change(Competitor, :count).by(0)
      end
    end

    describe "when at Unicon" do
      it "will create the competitor if it doesn't exist" do
        reg = FactoryGirl.create(:registrant)
        competition = FactoryGirl.create(:competition)
        @la = FactoryGirl.build(:lane_assignment, competitor: nil, registrant_id: reg.id, competition: competition)
        expect {
          @la.save
        }.to change(Competitor, :count).by(0)
      end
    end
  end
end
