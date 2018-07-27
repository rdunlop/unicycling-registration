require 'spec_helper'

describe Importers::Parsers::TwoAttemptCsv do
  let(:competition) { FactoryBot.create(:timed_competition) }
  let(:results_displayer) { competition.results_displayer }
  let(:importer) { described_class.new(test_file, results_displayer) }

  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  let(:test_file) { fixture_path + '/sample_muni_downhill_start_times.txt' }

  it "Can read from file" do
    expect(importer.extract_file).to eq(
      [
        ["101", nil, "1", "30", "0", nil, "10", "45", "0"],
        ["102", "DQ", "2", "30", "239", nil, "11", "0", "0"]
      ]
    )
  end

  it "has valid headers" do
    expect(importer).to be_valid_file
  end

  it "returns first row result", :aggregate_failures do
    input_data = importer.process_row(["101", nil, "1", "30", "0", nil, "10", "45", "0"])

    # 101,1,30,0,,10,45,0,
    expect(input_data[:bib_number]).to eq("101")

    expect(input_data[:first_attempt][:minutes]).to eq("1")
    expect(input_data[:first_attempt][:seconds]).to eq("30")
    expect(input_data[:first_attempt][:thousands]).to eq("0")
    expect(input_data[:first_attempt][:status]).to eq("active")

    expect(input_data[:second_attempt][:minutes]).to eq("10")
    expect(input_data[:second_attempt][:seconds]).to eq("45")
    expect(input_data[:second_attempt][:thousands]).to eq("0")
    expect(input_data[:second_attempt][:status]).to eq("active")
  end

  it "returns second row result", :aggregate_failures do
    # 102,2,30,239,DQ,11,0,0,
    input_data = importer.process_row(["102", "DQ", "2", "30", "239", nil, "11", "0", "0"])

    expect(input_data[:bib_number]).to eq("102")

    expect(input_data[:first_attempt][:minutes]).to eq("2")
    expect(input_data[:first_attempt][:seconds]).to eq("30")
    expect(input_data[:first_attempt][:thousands]).to eq("239")
    expect(input_data[:first_attempt][:status]).to eq("DQ")

    expect(input_data[:second_attempt][:minutes]).to eq("11")
    expect(input_data[:second_attempt][:seconds]).to eq("0")
    expect(input_data[:second_attempt][:thousands]).to eq("0")
    expect(input_data[:second_attempt][:status]).to eq("active")
  end

  context "when doing a hours_seconds_import" do
    let(:competition) { FactoryBot.create(:timed_competition, time_entry_columns: "minutes_seconds_hundreds") }

    it "returns facade results", :aggregate_failures do
      # 102,2,30,239,DQ,11,0,0,
      input_data = importer.process_row(["102", "DQ", "2", "30", "23", nil, "11", "0", "0"])

      expect(input_data[:bib_number]).to eq("102")

      expect(input_data[:first_attempt][:minutes]).to eq("2")
      expect(input_data[:first_attempt][:seconds]).to eq("30")
      expect(input_data[:first_attempt][:facade_hundreds]).to eq("23")
      expect(input_data[:first_attempt][:status]).to eq("DQ")

      expect(input_data[:second_attempt][:minutes]).to eq("11")
      expect(input_data[:second_attempt][:seconds]).to eq("0")
      expect(input_data[:second_attempt][:facade_hundreds]).to eq("0")
      expect(input_data[:second_attempt][:status]).to eq("active")
    end
  end
end
