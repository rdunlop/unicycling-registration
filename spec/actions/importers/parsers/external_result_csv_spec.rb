require 'spec_helper'

describe Importers::Parsers::ExternalResultCsv do
  let(:importer) { described_class.new }

  let(:test_file) { fixture_path + '/external_results.csv' }
  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  it "can process external result csv file" do
    input_data = importer.extract_file(sample_input)
    expect(input_data.count).to eq(4)

    expect(input_data[0]).to eq(["101", "27.60616904"])
    expect(input_data[1]).to eq(["102", "24.16784013"])
    expect(input_data[2]).to eq(["103", "23.51619451"])
    expect(input_data[3]).to eq(["104", "62.36747621"])
  end

  it "can convert a row" do
    result = importer.process_row(["101", "27.60616904"])

    expect(result).to eq(
      bib_number: "101",
      points: "27.60616904",
      details: nil,
      status: "active"
    )
  end
end
