require 'spec_helper'
require 'upload'

describe Upload do
  it "can convert a lif hash to data" do
    up = Upload.new

    arr = [7, nil, 4, nil, nil, nil, "DQ", nil, nil, nil, nil, nil, nil, nil, nil]

    hash = up.convert_lif_to_hash(arr)
    expect(hash.size).to eq(5)
  end

  it "can print a lif array" do
    up = Upload.new

    arr = [7, nil, 4, nil, nil, nil, "DQ", nil, nil, nil, nil, nil, nil, nil, nil]

    expect(up.convert_array_to_string(arr)).to eq("[7,,4,,,,DQ,,,,,,,,,]")
  end

  it "can convert an disqualification into data" do
    up = Upload.new

    arr = [7, '', 4, '', '', '', "DQ", '', '', '', '', '', '', '', '']

    hash = up.convert_lif_to_hash(arr)
    expect(hash[:minutes]).to eq(0)
    expect(hash[:seconds]).to eq(0)
    expect(hash[:thousands]).to eq(0)
    expect(hash[:disqualified]).to eq(true)
  end

  it "can convert a 2014 disqualification into data" do
    up = Upload.new

    arr = ["DQ", 0, 1, 'Miklowiski', 'Ty', 'Burnsville', '', '', '', '', '', '16:09:09.369', 'M', '', '', '', '']

    hash = up.convert_lif_to_hash(arr)
    expect(hash[:minutes]).to eq(0)
    expect(hash[:seconds]).to eq(0)
    expect(hash[:thousands]).to eq(0)
    expect(hash[:disqualified]).to eq(true)
  end

  it "can convert a 2014 DNS into data" do
    up = Upload.new

    arr = ['DNS', 0, 4, 'Rosen', 'Matthew', 'Bloomington Jefferson', '', '', '', '', '', '18:47:30.471', 'M', '', '', '', '']

    hash = up.convert_lif_to_hash(arr)
    expect(hash[:minutes]).to eq(0)
    expect(hash[:seconds]).to eq(0)
    expect(hash[:thousands]).to eq(0)
    expect(hash[:disqualified]).to eq(true)
  end

  it "can convert an array of data into minutes, seconds, thousands, dq" do
    up = Upload.new

    arr = [3, '', 7, '', '', '', "32.490", '', 12.142, '', '', '', '', '', '']

    hash = up.convert_lif_to_hash(arr)
    expect(hash[:lane]).to eq(7)
    expect(hash[:minutes]).to eq(0)
    expect(hash[:seconds]).to eq(32)
    expect(hash[:thousands]).to eq(490)
    expect(hash[:disqualified]).to eq(false)
  end
  it "can convert an array of data into minutes, seconds, thousands, dq" do
    up = Upload.new

    arr = [3, '', 7, '', '', '', "1:32.490", '', 12.142, '', '', '', '', '', '']

    hash = up.convert_lif_to_hash(arr)
    expect(hash[:lane]).to eq(7)
    expect(hash[:minutes]).to eq(1)
    expect(hash[:seconds]).to eq(32)
    expect(hash[:thousands]).to eq(490)
    expect(hash[:disqualified]).to eq(false)
  end

  it "can convert an array of data from the timing guys" do
    up = Upload.new(';')

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
    hash = up.convert_timing_csv_to_hash(arr)
    expect(hash[:bib]).to eq(557)
    expect(hash[:minutes]).to eq(23)
    expect(hash[:seconds]).to eq(28)
    expect(hash[:thousands]).to eq(106)
  end

  it "handles times longer than an hour" do
    up = Upload.new(';')

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
    hash = up.convert_timing_csv_to_hash(arr)
    expect(hash[:bib]).to eq(499)
    expect(hash[:minutes]).to eq(61)
    expect(hash[:seconds]).to eq(11)
    expect(hash[:thousands]).to eq(773)
  end

  it "handles very short times" do
    up = Upload.new(';')

    arr = [
      "1",
      "178",
      "Felix Dietze",
      "DH Glide",
      "2",
      "00:00:34.201",
      "2",
      "00:00:34.201",
      "00:00:35.339",
      "-",
      "103879"
    ]
    hash = up.convert_timing_csv_to_hash(arr)
    expect(hash[:bib]).to eq(178)
    expect(hash[:minutes]).to eq(0)
    expect(hash[:seconds]).to eq(34)
    expect(hash[:thousands]).to eq(201)
  end
end
