require 'spec_helper'

describe Importers::ImportResultChipImporter do
  let(:importer) { described_class.new(bib_number_column_number, time_column_number, number_of_decimal_places, lap_column_number) }

  let(:test_file) { fixture_path + '/sample_chip_data.csv' }
  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }
  let(:bib_number_column_number) { 0 }
  let(:time_column_number) { 2 }
  let(:number_of_decimal_places) { 2 }
  let(:lap_column_number) { 3 }

  it "reads from file successfully" do
    expect(importer.extract_file(sample_input)).to eq([["101", "fake", "0:1:34.39", "2"]])
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
end
