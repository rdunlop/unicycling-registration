require 'spec_helper'

describe Importers::Parsers::UniTimer do
  let(:test_file) { fixture_path + '/uni_timer_start.csv' }
  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  let(:up) { described_class.new }

  it "can process uni_timer files" do
    input_data = described_class.new(sample_input).extract_file
    expect(input_data.count).to eq(4)
    expect(input_data[0]).to eq(["123", "5", "30", "123", "FAULT"])
    expect(input_data[1]).to eq(["234", "5", "30", "123"])
    expect(input_data[2]).to eq(["345", "5", "30", "123"])
    expect(input_data[3]).to eq(["CLEAR_PREVIOUS"])
  end

  it "has valid headers" do
    importer = described_class.new(sample_input)
    expect(importer).to be_valid_file
  end

  it "can process a row of uni_timer data with fault" do
    arr = ["123", "5", "30", "123", "FAULT"]

    hash = up.process_row(arr)

    expect(hash[:bib_number]).to eq("123")
    expect(hash[:minutes]).to eq(5)
    expect(hash[:seconds]).to eq(30)
    expect(hash[:thousands]).to eq(123)
    expect(hash[:fault]).to eq(true)
  end

  it "can process a row of uni_timer data without fault" do
    arr = ["123", "5", "30", "123"]

    hash = up.process_row(arr)

    expect(hash[:bib_number]).to eq("123")
    expect(hash[:minutes]).to eq(5)
    expect(hash[:seconds]).to eq(30)
    expect(hash[:thousands]).to eq(123)
    expect(hash[:fault]).to eq(false)
  end

  it "can process a row of uni_timer data which clears previous" do
    arr = ["CLEAR_PREVIOUS"]

    hash = up.process_row(arr)

    expect(hash[:clear]).to be_truthy
  end
end
