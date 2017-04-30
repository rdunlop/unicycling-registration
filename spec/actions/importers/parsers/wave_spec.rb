require 'spec_helper'

describe Importers::Parsers::Wave do
  let(:wave_data_file_name) { fixture_path + '/sample_wave_assignments.txt' }
  let(:wave_data_file) { Rack::Test::UploadedFile.new(wave_data_file_name, "text/plain") }

  it "extracts the file contents" do
    expect(described_class.new.extract_file(wave_data_file)).to eq(
      [
        ["101", "1"],
        ["102", "1"],
        ["103", "2"],
        ["104", "2"]
      ]
    )
  end

  it "converts contents to hash" do
    expect(described_class.new.process_row(["101", "1"])).to eq(bib_number: "101", wave: "1")
  end
end
