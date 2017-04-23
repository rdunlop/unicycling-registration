require 'spec_helper'
require 'upload'

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

    expect(data.count).to eq(5) # 5 lnes, including header
  end

  it "can convert from lif line to array" do
    arr = described_class.new(nil).convert_line_to_array("2,,2,,,,2:43.85,,8.655,,,,,,")
    expect(arr.count).to eq(15)
  end

  context "with a semi-colon-spaced file" do
    let(:subject) { described_class.new(nil, separator: ";") }

    it "can convert an array of data from the timing guys" do
      arr = subject.convert_line_to_array("22;557;10k-Unl-1 (10:00);02/08/2014 10:13:00;Bruce Lee;4;00:23:28.106;16;00:05:54.972;00:05:54.972;00:05:56.526;00:05:49.218;00:05:47.390;104295;1")
      expect(arr.count).to eq(15)
      expect(arr[1]).to eq("557")
    end
  end
end
