require 'spec_helper'

describe Importers::HeatFromFilenameExtractor do
  it "can extract heat from filename" do
    names = ['100m 01.lif', '100m 01.csv', '100m 01.txt']
    for name in names
      heat = described_class.extract_heat(names)
      expect(heat).to eq(1)
    end
  end

  it "fails to extract heat from filename" do
    heat = described_class.extract_heat('100m - no heat.lif')
    expect(heat).to be_nil
  end
end
