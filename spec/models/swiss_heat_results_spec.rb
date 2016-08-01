require 'spec_helper'

describe SwissHeatResult do
  it "can parse a simple time" do
    result = described_class.from_string("DNK\t00:00:14.404\t555\t1", 14)
    expect(result.heat).to eq(14)
    expect(result.lane).to eq(1)
    expect(result.bib_number).to eq(555)
    expect(result.minutes).to eq(0)
    expect(result.seconds).to eq(14)
    expect(result.thousands).to eq(404)
    expect(result.status).to eq("active")
  end

  it "can parse complex times" do
    result = described_class.from_string("DNK\t02:45:34.404\t555\t1", 14)
    expect(result.minutes).to eq(165)
    expect(result.seconds).to eq(34)
  end

  it "marks dqs properly" do
    result = described_class.from_string("DNK\tdisq. Rot\t555\t1", 14)
    expect(result.status).to eq("DQ")
    expect(result.status_description).to eq("False Start")
  end

  it "marks Scratched properly" do
    result = described_class.from_string("DNK\tScratched\t555\t1", 14)
    expect(result.status).to eq("DQ")
    expect(result.status_description).to eq("Restart")
  end
end
