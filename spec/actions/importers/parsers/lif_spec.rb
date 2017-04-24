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
end
