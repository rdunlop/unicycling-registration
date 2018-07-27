require 'spec_helper'

describe Importers::Parsers::Csv do
  let(:competition) { FactoryBot.create(:timed_competition) }
  let(:results_displayer) { competition.results_displayer }
  let(:importer) { described_class.new(test_file, results_displayer) }

  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  describe "when importing CSV data" do
    let(:test_file) { fixture_path + '/sample_time_results_bib_101.txt' }

    it "reads the line" do
      expect(importer.extract_file).to eq([["101", "0", "1", "2", "300"]])
    end

    it "has valid headers" do
      expect(importer).to be_valid_file
    end

    it "returns competitor data" do
      input_data = importer.process_row(["101", "0", "1", "2", "300"])

      expect(input_data[:bib_number]).to eq("101")
      expect(input_data[:minutes]).to eq("1")
      expect(input_data[:seconds]).to eq("2")
      expect(input_data[:thousands]).to eq("300")
      expect(input_data[:number_of_laps]).to be_nil
      expect(input_data[:status]).to eq("active")
    end

    context "when using a lap-competition" do
      let(:competition) { FactoryBot.create(:timed_laps_competition) }

      it "reads num_laps" do
        importer = described_class.new(test_file, results_displayer)

        input_data = importer.process_row(["101", "0", "1", "2", "300", "4"])

        expect(input_data[:number_of_laps]).to eq("4")
      end
    end

    context "when reading from non-thousands import" do
      let(:competition) { FactoryBot.create(:timed_competition, time_entry_columns: "minutes_seconds_hundreds") }

      it "reads facade_hundreds" do
        importer = described_class.new(test_file, results_displayer)

        input_data = importer.process_row(["101", "0", "1", "2", "30"])

        expect(input_data[:facade_hundreds]).to eq("30")
      end
    end
  end

  describe "when importing dq-results" do
    let(:test_file) { fixture_path + '/sample_time_results_bib_101_dq.txt' }

    it "reads the line" do
      expect(importer.extract_file).to eq([["101", "DQ", "0", "0", "0"]])
    end

    it "returns dq data" do
      input_data = importer.process_row(["101", "DQ", "0", "0", "0"])
      expect(input_data[:status]).to eq("DQ")
    end
  end
end
