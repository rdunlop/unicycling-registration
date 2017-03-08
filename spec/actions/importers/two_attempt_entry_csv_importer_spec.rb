require 'spec_helper'

describe Importers::TwoAttemptEntryCsvImporter do
  def create_competitor(competition, bib_number, heat, lane)
    competitor = FactoryGirl.create(:event_competitor, competition: competition)
    reg = competitor.members.first.registrant
    reg.update_attribute(:bib_number, bib_number)
    if heat && lane
      FactoryGirl.create(:lane_assignment, competition: competition, competitor: competitor, heat: heat, lane: lane)
    end
  end

  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:importer) { described_class.new(competition, admin_user) }

  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  describe "when importing CSV data" do
    let(:test_file) { fixture_path + '/sample_muni_downhill_start_times.txt' }

    it "creates a competitor", :aggregate_failures do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)
      @reg2 = FactoryGirl.create(:registrant, bib_number: 102)

      expect do
        importer.process(sample_input, false)
      end.to change(TwoAttemptEntry, :count).by(2)

      expect(TwoAttemptEntry.count).to eq(2)

      # 101,1,30,0,,10,45,0,
      result = TwoAttemptEntry.first
      expect(result.bib_number).to eq(101)
      expect(result.competition).to eq(competition)
      expect(result.is_start_time).to eq(false)

      expect(result.minutes_1).to eq(1)
      expect(result.seconds_1).to eq(30)
      expect(result.thousands_1).to eq(0)
      expect(result.status_1).to eq("active")

      expect(result.minutes_2).to eq(10)
      expect(result.seconds_2).to eq(45)
      expect(result.thousands_2).to eq(0)
      expect(result.status_2).to eq("active")

      # 102,2,30,239,DQ,11,0,0,
      second_result = TwoAttemptEntry.second

      expect(second_result.bib_number).to eq(102)
      expect(second_result.competition).to eq(competition)
      expect(second_result.is_start_time).to eq(false)

      expect(second_result.minutes_1).to eq(2)
      expect(second_result.seconds_1).to eq(30)
      expect(second_result.thousands_1).to eq(239)
      expect(second_result.status_1).to eq("DQ")

      expect(second_result.minutes_2).to eq(11)
      expect(second_result.seconds_2).to eq(0)
      expect(second_result.thousands_2).to eq(0)
      expect(second_result.status_2).to eq("active")
    end
  end
end
