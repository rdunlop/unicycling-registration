require 'spec_helper'

describe Importers::Parsers::Swiss do
  context "#extract_file" do
    let(:test_file) { fixture_path + '/swiss_heat.tsv' }
    let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

    let(:importer) { described_class.new(test_file) }

    it "Can read from file" do
      expect(importer.extract_file).to eq(
        [
          ["3", "00:00:13.973", "277", "1", "Monika Sveistrup", "0-10 20\"\tFemale, 20\" Wheel", "Female", "00:00:00.186"],
          ["5", "00:00:14.302", "660", "2", "Eva Maria Prader", "0-10 20\"\tFemale, 20\" Wheel", "Female", "00:00:00.515"]
        ]
      )
    end
  end

  it "can parse a simple time", :aggregate_failures do
    result = described_class.new.process_row(["DNK", "00:00:14.404", "555", "1"])
    expect(result[:lane]).to eq(1)
    expect(result[:bib_number]).to eq(555)
    expect(result[:minutes]).to eq(0)
    expect(result[:seconds]).to eq(14)
    expect(result[:thousands]).to eq(404)
    expect(result[:status]).to eq("active")
  end

  it "can parse complex times" do
    result = described_class.new.process_row(["DNK", "02:45:34.404", "555", "1"])
    expect(result[:minutes]).to eq(165)
    expect(result[:seconds]).to eq(34)
  end

  it "marks dqs properly" do
    result = described_class.new.process_row(["DNK", "disq. Rot", "555", "1"])
    expect(result[:status]).to eq("DQ")
    expect(result[:status_description]).to eq("False Start")
  end

  it "marks Scratched properly" do
    result = described_class.new.process_row(["DNK", "Scratched", "555", "1"])
    expect(result[:status]).to eq("DQ")
    expect(result[:status_description]).to eq("Restart")
  end

  it "can parse a row without a time" do
    result = described_class.new.process_row(["DNK", nil, "555", "1"])
    expect(result[:status]).to eq("DQ")
    expect(result[:status_description]).to eq("No Data")
  end
end
