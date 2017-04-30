require 'spec_helper'

describe Importers::RecordCreators::HeatLaneAndTimeResult do
  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:creator) { described_class.new(competition, admin_user, 1) }

  describe "when importing data" do
    let(:row) do
      {
        bib_number: 101,
        minutes: 00,
        seconds: 13,
        thousands: 973,
        lane: 1,
        status: "active",
        status_description: nil,
        raw_time: "00:00:13.973"
      }
    end

    context "when importing heats" do
      it "creates heat result and time result" do
        @competitor = FactoryGirl.create(:event_competitor, competition: competition)
        @reg = @competitor.members.first.registrant
        @reg.update(bib_number: 101)

        expect do
          creator.save(row, "raw")
        end.to change(HeatLaneResult, :count).by(1)

        expect(TimeResult.count).to eq(1)
        result = TimeResult.first
        expect(result).not_to be_disqualified

        expect(result.bib_number).to eq(101)
        expect(result.number_of_laps).to be_nil

        # 0:1:34.39
        expect(result.minutes).to eq(0)
        expect(result.seconds).to eq(13)
        expect(result.thousands).to eq(973)
      end
    end

    context "When importing without heats" do
      let(:creator) { described_class.new(competition, admin_user, 1, heats: false) }

      it "does not create Heat Lane result" do
        @competitor = FactoryGirl.create(:event_competitor, competition: competition)
        @reg = @competitor.members.first.registrant
        @reg.update(bib_number: 101)
        competition.reload
        expect do
          creator.save(row, "Raw")
        end.not_to change(HeatLaneResult, :count)
        expect(TimeResult.count).to eq(1)
      end
    end
  end
end
