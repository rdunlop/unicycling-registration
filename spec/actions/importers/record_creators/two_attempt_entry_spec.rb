require 'spec_helper'

describe Importers::RecordCreators::TwoAttemptEntry do
  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:creator) { described_class.new(competition, admin_user, false) }

  describe "when importing data" do
    let(:row) do
      {
        bib_number: 101,

        minutes_1: 1,
        seconds_1: 34,
        thousands_1: 390,
        status_1: "active",

        minutes_2: 2,
        seconds_2: 24,
        thousands_2: 290,
        status_2: "active"
      }
    end

    it "creates an entry" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      expect do
        creator.save(row, "raw")
      end.to change(TwoAttemptEntry, :count).by(1)

      expect(TwoAttemptEntry.count).to eq(1)
      result = TwoAttemptEntry.first

      expect(result.status_1).to eq("active")
      expect(result.bib_number).to eq(101)
      expect(result.minutes_1).to eq(1)
      expect(result.seconds_1).to eq(34)
      expect(result.thousands_1).to eq(390)

      expect(result.status_2).to eq("active")
      expect(result.minutes_2).to eq(2)
      expect(result.seconds_2).to eq(24)
      expect(result.thousands_2).to eq(290)
    end
  end
end
