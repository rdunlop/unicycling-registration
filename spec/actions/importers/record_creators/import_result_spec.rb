require 'spec_helper'

describe Importers::RecordCreators::ImportResult do
  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:creator) { described_class.new(competition, admin_user, false) }

  describe "when importing data" do
    let(:row) do
      {
        bib_number: 101,
        minutes: 1,
        seconds: 34,
        thousands: 390,
        number_of_laps: 2,
        status: "active"
      }
    end
    it "creates a competitor" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      expect do
        creator.save(row, ["raw"])
      end.to change(ImportResult, :count).by(1)

      expect(ImportResult.count).to eq(1)
      result = ImportResult.first
      expect(result).not_to be_disqualified

      expect(result.bib_number).to eq(101)
      expect(result.number_of_laps).to eq(2)

      # 0:1:34.39
      expect(result.minutes).to eq(1)
      expect(result.seconds).to eq(34)
      expect(result.thousands).to eq(390)
    end
  end
end
