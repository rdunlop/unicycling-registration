require 'spec_helper'

describe Exporters::WaveExporter do
  let(:competition) { FactoryGirl.create(:competition) }
  let(:competitor) { FactoryGirl.create(:event_competitor, competition: competition, wave: 10) }

  let(:exporter) { described_class.new([competitor]) }

  it "sets the headers" do
    expect(exporter.headers).to eq(["Id", "Wave", "Name", "Age", "Gender", "Age Group", "Best Time"])
  end

  it "has the rows" do
    expect(exporter.rows).to eq(
      [
        [
          competitor.lowest_member_bib_number,
          10,
          competitor.detailed_name,
          competitor.age,
          competitor.gender,
          competitor.age_group_entry_description,
          competitor.best_time
        ]
      ]
    )
  end
end
