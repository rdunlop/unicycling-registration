require 'spec_helper'

describe Importers::Parsers::Lif do
  let(:test_file) { fixture_path + '/800m14.lif' }
  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  it "can process lif files" do
    input_data = described_class.new.extract_file(sample_input)
    expect(input_data.count).to eq(8)
    expect(input_data[0]).to eq(["1", nil, "1", nil, nil, nil, "2:35.19", nil, "2:35.190", nil, nil, nil, nil, nil, nil])
    expect(input_data[7]).to eq(["8", nil, "8", nil, nil, nil, "3:04.36", nil, "29.163", nil, nil, nil, nil, nil, nil])
  end

  let(:up) { described_class.new }

  it "can convert a lif hash to data" do
    arr = [7, nil, 4, nil, nil, nil, "DQ", nil, nil, nil, nil, nil, nil, nil, nil]

    hash = up.convert_lif_to_hash(arr)
    expect(hash.size).to eq(5)
  end

  it "can convert an disqualification into data" do
    arr = [7, '', 4, '', '', '', "DQ", '', '', '', '', '', '', '', '']

    hash = up.convert_lif_to_hash(arr)
    expect(hash[:minutes]).to eq(0)
    expect(hash[:seconds]).to eq(0)
    expect(hash[:thousands]).to eq(0)
    expect(hash[:disqualified]).to eq(true)
  end

  it "can convert a 2014 disqualification into data" do
    arr = ["DQ", 0, 1, 'Miklowiski', 'Ty', 'Burnsville', '', '', '', '', '', '16:09:09.369', 'M', '', '', '', '']

    hash = up.convert_lif_to_hash(arr)
    expect(hash[:minutes]).to eq(0)
    expect(hash[:seconds]).to eq(0)
    expect(hash[:thousands]).to eq(0)
    expect(hash[:disqualified]).to eq(true)
  end

  it "can convert a 2014 DNS into data" do
    arr = ['DNS', 0, 4, 'Rosen', 'Matthew', 'Bloomington Jefferson', '', '', '', '', '', '18:47:30.471', 'M', '', '', '', '']

    hash = up.convert_lif_to_hash(arr)
    expect(hash[:minutes]).to eq(0)
    expect(hash[:seconds]).to eq(0)
    expect(hash[:thousands]).to eq(0)
    expect(hash[:disqualified]).to eq(true)
  end

  it "can convert an array of data into minutes, seconds, thousands, dq" do
    arr = [3, '', 7, '', '', '', "32.490", '', 12.142, '', '', '', '', '', '']

    hash = up.convert_lif_to_hash(arr)
    expect(hash[:lane]).to eq(7)
    expect(hash[:minutes]).to eq(0)
    expect(hash[:seconds]).to eq(32)
    expect(hash[:thousands]).to eq(490)
    expect(hash[:disqualified]).to eq(false)
  end
  it "can convert an array of data into minutes, seconds, thousands, dq" do
    arr = [3, '', 7, '', '', '', "1:32.490", '', 12.142, '', '', '', '', '', '']

    hash = up.convert_lif_to_hash(arr)
    expect(hash[:lane]).to eq(7)
    expect(hash[:minutes]).to eq(1)
    expect(hash[:seconds]).to eq(32)
    expect(hash[:thousands]).to eq(490)
    expect(hash[:disqualified]).to eq(false)
  end
end
