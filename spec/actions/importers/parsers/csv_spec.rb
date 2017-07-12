require 'spec_helper'

describe Importers::Parsers::Csv do
  let(:importer) { described_class.new(test_file) }

  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  describe "when importing CSV data" do
    let(:test_file) { fixture_path + '/sample_time_results_bib_101.txt' }

    it "reads the line" do
      expect(importer.extract_file).to eq([["101", "1", "2", "300", "0"]])
    end

    it "has valid headers" do
      expect(importer).to be_valid_file
    end

    it "returns competitor data" do
      input_data = importer.process_row(["101", "1", "2", "300", "0"])

      expect(input_data[:bib_number]).to eq("101")
      expect(input_data[:minutes]).to eq("1")
      expect(input_data[:seconds]).to eq("2")
      expect(input_data[:thousands]).to eq("300")
      expect(input_data[:number_of_laps]).to be_nil
      expect(input_data[:status]).to eq("active")
    end

    it "reads num_laps, if configured" do
      importer = described_class.new(test_file, read_num_laps: true)

      input_data = importer.process_row(["101", "1", "2", "300", "0", "4"])

      expect(input_data[:number_of_laps]).to eq("4")
    end
  end

  describe "when importing dq-results" do
    let(:test_file) { fixture_path + '/sample_time_results_bib_101_dq.txt' }

    it "reads the line" do
      expect(importer.extract_file).to eq([["101", "0", "0", "0", "DQ"]])
    end

    it "returns dq data" do
      input_data = importer.process_row(["101", "0", "0", "0", "DQ"])
      expect(input_data[:status]).to eq("DQ")
    end
  end
end
