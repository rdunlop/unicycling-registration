require 'spec_helper'

describe Importers::Parsers::Swiss do
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

  describe "when given an invalid row" do
    it "returns nil" do
      expect(described_class.new.process_row(["", "", ""])).to be_nil
    end
  end
end
