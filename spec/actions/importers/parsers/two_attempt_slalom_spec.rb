require 'spec_helper'

describe Importers::Parsers::TwoAttemptSlalom do
  let(:iuf_two_attempt_data_file_name) { fixture_path + '/sample_iuf_two_attempt.txt' }
  let(:iuf_two_attempt_data_file) { Rack::Test::UploadedFile.new(iuf_two_attempt_data_file_name, "text/plain") }

  it "extracts the file contents" do
    expect(described_class.new(iuf_two_attempt_data_file).extract_file).to eq(
      [
        ["30", "Hürzeler", "Ramona", "19,64", "19,40", "Switzerland", "23", "w", "IUF-Slalom"]
      ]
    )
  end

  it "has valid headers" do
    importer = described_class.new(iuf_two_attempt_data_file)
    expect(importer).to be_valid_file
  end

  describe "when importing IUF-style data" do
    it "can process a normal single line", :aggregate_failures do
      obj = described_class.new
      raw_line = "30;Hürzeler;Ramona;19,64;19,40;Switzerland;23;w;IUF-Slalom"
      entry = obj.process_row(raw_line.split(";"))
      expect(entry[:minutes_1]).to eq(0)
      expect(entry[:seconds_1]).to eq("19")
      expect(entry[:thousands_1]).to eq(640)
      expect(entry[:status_1]).to eq("active")

      expect(entry[:minutes_2]).to eq(0)
      expect(entry[:seconds_2]).to eq("19")
      expect(entry[:thousands_2]).to eq(400)
      expect(entry[:status_2]).to eq("active")

      expect(entry[:bib_number]).to eq("30")
    end

    it "can process a blank line" do
      obj = described_class.new
      raw_line = "30;Hürzeler;Ramona;;;Switzerland;23;w;IUF-Slalom"
      entry = obj.process_row(raw_line.split(";"))
      expect(entry).to be_nil
    end

    it "can process an abnormal line", :aggregate_failures do
      obj = described_class.new
      raw_line = "30;Hürzeler;Ramona;abgem;disq;Switzerland;23;w;IUF-Slalom"
      entry = obj.process_row(raw_line.split(";"))
      expect(entry[:minutes_1]).to be_nil
      expect(entry[:seconds_1]).to be_nil
      expect(entry[:thousands_1]).to be_nil
      expect(entry[:status_1]).to eq("DQ")

      expect(entry[:minutes_2]).to be_nil
      expect(entry[:seconds_2]).to be_nil
      expect(entry[:thousands_2]).to be_nil
      expect(entry[:status_2]).to eq("DQ")

      expect(entry[:bib_number]).to eq("30")
    end
  end
end
