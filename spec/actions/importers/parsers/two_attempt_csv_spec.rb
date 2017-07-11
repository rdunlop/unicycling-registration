require 'spec_helper'

describe Importers::Parsers::TwoAttemptCsv do
  let(:importer) { described_class.new(test_file) }

  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  let(:test_file) { fixture_path + '/sample_muni_downhill_start_times.txt' }

  it "Can read from file" do
    expect(importer.extract_file).to eq(
      [
        ["101", "1", "30", "0", nil, "10", "45", "0", nil],
        ["102", "2", "30", "239", "DQ", "11", "0", "0", nil]
      ]
    )
  end

  it "has valid headers" do
    expect(importer).to be_valid_file
  end

  it "returns first row result", :aggregate_failures do
    input_data = importer.process_row(["101", "1", "30", "0", nil, "10", "45", "0"])

    # 101,1,30,0,,10,45,0,
    expect(input_data[:bib_number]).to eq("101")

    expect(input_data[:minutes_1]).to eq("1")
    expect(input_data[:seconds_1]).to eq("30")
    expect(input_data[:thousands_1]).to eq("0")
    expect(input_data[:status_1]).to eq("active")

    expect(input_data[:minutes_2]).to eq("10")
    expect(input_data[:seconds_2]).to eq("45")
    expect(input_data[:thousands_2]).to eq("0")
    expect(input_data[:status_2]).to eq("active")
  end

  it "returns second row result", :aggregate_failures do
    # 102,2,30,239,DQ,11,0,0,
    input_data = importer.process_row(["102", "2", "30", "239", "DQ", "11", "0", "0"])

    expect(input_data[:bib_number]).to eq("102")

    expect(input_data[:minutes_1]).to eq("2")
    expect(input_data[:seconds_1]).to eq("30")
    expect(input_data[:thousands_1]).to eq("239")
    expect(input_data[:status_1]).to eq("DQ")

    expect(input_data[:minutes_2]).to eq("11")
    expect(input_data[:seconds_2]).to eq("0")
    expect(input_data[:thousands_2]).to eq("0")
    expect(input_data[:status_2]).to eq("active")
  end
end
