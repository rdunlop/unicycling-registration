require 'spec_helper'

describe Importers::Parsers::Tier do
  let(:tier_data_file_name) { file_fixture("sample_tier_assignments.txt") }
  let(:tier_data_file) { Rack::Test::UploadedFile.new(tier_data_file_name, "text/plain") }

  it "extracts the file contents" do
    expect(described_class.new(tier_data_file).extract_file).to eq(
      [
        ["101", "1", "1 lap"],
        ["102", "1", "1 lap"],
        ["103", "2", "2 laps"],
        ["104", "2", "2 laps"]
      ]
    )
  end

  it "has valid headers" do
    importer = described_class.new(tier_data_file)
    expect(importer).to be_valid_file
  end

  it "converts contents to hash" do
    expect(described_class.new.process_row(["101", "1", "1 lap"])).to eq(bib_number: "101", tier_number: "1", tier_description: "1 lap")
  end

  context "with an invalid file type" do
    let(:xls_wave_data_file_name) { file_fixture("invalid_sample_wave_assignments.xlsx") }
    let(:bad_wave_data_file) { Rack::Test::UploadedFile.new(xls_wave_data_file_name, "text/plain") }

    it "returns a good error code" do
      parser = described_class.new(bad_wave_data_file)
      expect(parser).not_to be_valid_file
      expect(parser.errors).to eq(["Unable to read file. Is it it plain-text file? (Any value after quoted field isn't allowed in line 2.)"])
    end
  end
end
