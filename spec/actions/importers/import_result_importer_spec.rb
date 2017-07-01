require 'spec_helper'

describe Importers::ImportResultImporter do
  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:timed_competition, uses_lane_assignments: true) }
  let(:importer) { described_class.new(competition, admin_user) }

  describe "when importing data" do
    let(:processor) do
      double(file_contents: [["row_1"]],
             valid_file?: true,
             process_row: {
               bib_number: 101,
               minutes: 1,
               seconds: 34,
               thousands: 390,
               number_of_laps: 2,
               status: "active"
             })
    end
    it "creates a competitor" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      expect do
        importer.process(false, processor)
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
    let(:processor) { double(valid_file?: false, errors: ["File not found"]) }

    it "returns an error message" do
      @reg = FactoryGirl.create(:registrant, bib_number: 101)

      result = nil
      expect do
        result = importer.process(false, processor)
      end.not_to change(ImportResult, :count)

      expect(result).to be_falsey
      expect(importer.errors).to eq("File not found")
    end
  end
end
