require 'spec_helper'

describe Importers::ImportResultImporter do
  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:importer) { described_class.new(competition, admin_user) }

  describe "when importing data" do
    let(:test_file) { fixture_path + '/sample_chip_data.csv' }
    let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }
    let(:processor) do
      double(extract_file: [["row_1"]],
             process_row: {
               bib_number: 101,
               minutes: 1,
               seconds: 34,
               thousands: 390,
               number_of_laps: 2,
               status: "active"
             }
            )
    end
    it "creates a competitor" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      expect do
        importer.process(sample_input, false, processor)
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

  context "when a file is not specified" do
    let(:sample_input) { nil }

    it "returns an error message" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      result = nil
      expect do
        result = importer.process(sample_input, false, nil)
      end.not_to change(ImportResult, :count)

      expect(result).to be_falsey
      expect(importer.errors).to eq("File not found")
    end
  end
end
