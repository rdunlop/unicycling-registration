require 'spec_helper'

describe Importers::Parsers::Wave do
  let(:wave_data_file_name) { fixture_path + '/sample_wave_assignments.txt' }
  let(:wave_data_file) { Rack::Test::UploadedFile.new(wave_data_file_name, "text/plain") }

  it "extracts the file contents" do
    expect(described_class.new(wave_data_file).extract_file).to eq(
      [
        ["101", "1"],
        ["102", "1"],
        ["103", "2"],
        ["104", "2"]
      ]
    )
  end

  it "has valid headers" do
    importer = described_class.new(wave_data_file)
    expect(importer).to be_valid_file
  end

  it "converts contents to hash" do
    expect(described_class.new.process_row(["101", "1"])).to eq(bib_number: "101", wave: "1")
  end

  context "with an invalid file type" do
    let(:xls_wave_data_file_name) { fixture_path + '/invalid_sample_wave_assignments.xlsx' }
    let(:bad_wave_data_file) { Rack::Test::UploadedFile.new(xls_wave_data_file_name, "text/plain") }

    it "returns a good error code" do
      parser = described_class.new(bad_wave_data_file)
      expect(parser.valid_file?).to be_falsey
      expect(parser.errors).to eq(["Unable to read file. Is it it plain-text file? (Unclosed quoted field on line 1.)"])
    end
  end
end
