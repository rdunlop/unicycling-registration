require 'spec_helper'

describe Exporters::TierExporter do
  let(:competition) { FactoryBot.create(:tier_competition) }
  let(:competitor) { FactoryBot.create(:event_competitor, competition: competition, tier_number: 2, tier_description: "(2/3 Laps)") }

  let(:exporter) { described_class.new([competitor]) }

  it "sets the headers" do
    expect(exporter.headers).to eq(["Id", "Tier", "Tier Description", "Name", "Age", "Gender"])
  end

  it "has the rows" do
    expect(exporter.rows).to eq(
      [
        [
          competitor.lowest_member_bib_number,
          2,
          "(2/3 Laps)",
          competitor.detailed_name,
          competitor.age,
          competitor.gender
        ]
      ]
    )
  end
end
