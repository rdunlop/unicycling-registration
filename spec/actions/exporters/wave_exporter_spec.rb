require 'spec_helper'

describe Exporters::WaveExporter do
  let(:competition) { FactoryGirl.create(:competition) }
  let(:competitor) { FactoryGirl.create(:event_competitor, competition: competition, wave: 10) }

  let(:exporter) { described_class.new([competitor]) }

  it "sets the headers" do
    expect(exporter.headers).to eq(["ID", "Wave", "Name"])
  end

  it "has the rows" do
    expect(exporter.rows).to eq(
      [
        [
          competitor.lowest_member_bib_number,
          10,
          competitor.detailed_name
        ]
      ]
    )
  end
end
