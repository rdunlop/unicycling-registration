require 'spec_helper'

describe Importers::CsvExtractor do
  it "can extract csv for normal race results" do
    sample_file = fixture_path + '/sample_time_results_bib_101.txt'
    sample_input = Rack::Test::UploadedFile.new(sample_file, "text/plain")

    subject = described_class.new(sample_input)
    data = subject.extract_csv

    expect(data.count).to eq(1)
  end

  it "can extract csv for lif race results" do
    sample_file = fixture_path + '/800m14.lif'
    sample_input = Rack::Test::UploadedFile.new(sample_file, "text/plain")

    subject = described_class.new(sample_input)
    data = subject.extract_csv

    expect(data.count).to eq(9) # includes header row
  end

  it "can extract csv for lif race results (exact)" do
    sample_file = fixture_path + '/test2.lif'
    sample_input = Rack::Test::UploadedFile.new(sample_file, "text/plain")

    subject = described_class.new(sample_input)
    data = subject.extract_csv

    expect(data.count).to eq(5) # 5 lines, including header
  end

  it "can extract data for timing guys" do
    sample_file = fixture_path + '/sample_chip_data.csv'
    sample_input = Rack::Test::UploadedFile.new(sample_file, "text/plain")

    subject = described_class.new(sample_input, separator: ";")
    data = subject.extract_csv

    expect(data.count).to eq(2) # 2 lines, including header
    expect(data[1].count).to eq(4)
  end

  it "can extract data for swiss data" do
    sample_file = fixture_path + '/swiss_heat_with_dq.tsv'
    sample_input = Rack::Test::UploadedFile.new(sample_file, "text/plain")

    subject = described_class.new(sample_input, separator: "\t")
    data = subject.extract_csv

    expect(data.count).to eq(3) # 2 lines, including header
    expect(data[1].count).to eq(8)
  end
end
