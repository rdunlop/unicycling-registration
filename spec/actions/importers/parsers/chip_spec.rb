require 'spec_helper'

describe Importers::Parsers::Chip do
  let(:importer) { described_class.new(sample_input, bib_number_column_number, time_column_number, number_of_decimal_places, lap_column_number) }

  let(:test_file) { fixture_path + '/sample_chip_data.csv' }
  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }
  let(:bib_number_column_number) { 0 }
  let(:time_column_number) { 2 }
  let(:number_of_decimal_places) { 2 }
  let(:lap_column_number) { 3 }

  it "reads from file successfully" do
    expect(importer.extract_file).to eq([["101", "fake", "0:1:34.39", "2"]])
  end

  it "has valid headers" do
    expect(importer).to be_valid_file
  end

  it "creates a dq competitor" do
    read_input = importer.process_row(["101", "fake", "0:1:34.39", "2"])
    expect(read_input[:bib_number]).to eq(101)
    expect(read_input[:minutes]).to eq(1)
    expect(read_input[:seconds]).to eq(34)
    expect(read_input[:thousands]).to eq(390)
    expect(read_input[:status]).to be_nil
    expect(read_input[:number_of_laps]).to eq("2")
  end

  context "with bib_number in 2nd column" do
    let(:bib_number_column_number) { 1 }
    let(:time_column_number) { 6 }

    it "can convert an array of data from the timing guys" do
      arr = [
        "22",
        "557",
        "10k-Unl-1 (10:00)",
        "02/08/2014 10:13:00",
        "Bruce Lee",
        "4",
        "00:23:28.106",
        "16",
        "00:05:54.972",
        "00:05:54.972",
        "00:05:56.526",
        "00:05:49.218",
        "00:05:47.390",
        "104295",
        "1"
      ]
      hash = importer.convert_timing_csv_to_hash(arr)
      expect(hash[:bib]).to eq(557)
      expect(hash[:minutes]).to eq(23)
      expect(hash[:seconds]).to eq(28)
      expect(hash[:thousands]).to eq(106)
    end

    it "handles times longer than an hour" do
      arr = [
        "335",
        "499",
        "10k-Std-6 (8:44:30)",
        "02/08/2014 09:04:00",
        "Donghwi Kim",
        "4",
        "01:01:11.773",
        "36",
        "00:16:21.237",
        "00:16:21.237",
        "00:14:10.450",
        "00:15:50.003",
        "00:14:50.083",
        "103885",
        "1"
      ]
      hash = importer.convert_timing_csv_to_hash(arr)
      expect(hash[:bib]).to eq(499)
      expect(hash[:minutes]).to eq(61)
      expect(hash[:seconds]).to eq(11)
      expect(hash[:thousands]).to eq(773)
    end

    it "handles very short times" do
      arr = [
        "1",
        "178",
        "Felix Dietze",
        "DH Glide",
        "2",
        nil, # standardize on a single column count, column 6 for time data
        "00:00:34.201",
        "2",
        "00:00:34.201",
        "00:00:35.339",
        "-",
        "103879"
      ]
      hash = importer.convert_timing_csv_to_hash(arr)
      expect(hash[:bib]).to eq(178)
      expect(hash[:minutes]).to eq(0)
      expect(hash[:seconds]).to eq(34)
      expect(hash[:thousands]).to eq(201)
    end
  end
end
