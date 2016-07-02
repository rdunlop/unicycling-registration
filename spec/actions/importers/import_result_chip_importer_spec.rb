require 'spec_helper'

describe ImportResultChipImporter do
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

  describe "when importing chip_results" do
    let(:test_file) { fixture_path + '/sample_chip_data.csv' }
    let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }
    let(:bib_number_column_number) { 0 }
    let(:time_column_number) { 2 }
    let(:number_of_decimal_places) { 2 }
    let(:lap_column_number) { 3 }

    it "creates a dq competitor" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      expect do
        importer.process(sample_input, bib_number_column_number, time_column_number, number_of_decimal_places, lap_column_number)
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

    context "when a file is not specified" do
      let(:sample_input) { nil }

      it "returns an error message" do
        @reg = FactoryGirl.create(:registrant, bib_number: 101)

        result = nil
        expect do
          result = importer.process(sample_input, bib_number_column_number, time_column_number, number_of_decimal_places, lap_column_number)
        end.not_to change(ImportResult, :count)

        expect(result).to be_falsey
        expect(importer.errors).to eq("File not found")
      end
    end
  end
end
